import { pool } from '../config/database.js';

let serverInvitationIdColumnExists;

async function hasServerInvitationIdColumn() {
  if (serverInvitationIdColumnExists !== undefined) {
    return serverInvitationIdColumnExists;
  }

  const result = await pool.query(
    `SELECT 1
     FROM information_schema.columns
     WHERE table_name = 'server_invitations' AND column_name = 'id'
     LIMIT 1`
  );

  serverInvitationIdColumnExists = result.rows.length > 0;
  return serverInvitationIdColumnExists;
}

export const serverController = {
  // Create a new server
  async createServer(req, res) {
    const client = await pool.connect();
    try {
      const { name, description } = req.body;
      const userId = req.user.userId;

      // Import validators
      const { validators } = await import('../utils/validators.js');

      // Validate server name
      const nameValidation = validators.validateName(name, 'Server name');
      if (!nameValidation.valid) {
        return res.status(400).json({
          success: false,
          message: nameValidation.error
        });
      }

      // Validate description
      const descValidation = validators.validateDescription(description);
      if (!descValidation.valid) {
        return res.status(400).json({
          success: false,
          message: descValidation.error
        });
      }

      await client.query('BEGIN');

      // ... rest of function
      // Create server
      const serverResult = await client.query(
        `INSERT INTO servers (name, description, created_by) 
         VALUES ($1, $2, $3) 
         RETURNING id, name, description, created_by, created_at`,
        [name, description || null, userId]
      );

      const server = serverResult.rows[0];

      // Add creator as admin member
      await client.query(
        `INSERT INTO server_members (server_id, user_id, role) 
         VALUES ($1, $2, $3)`,
        [server.id, userId, 'admin']
      );

      // Auto-create a default "General" channel so expenses can be added immediately
      await client.query(
        `INSERT INTO channels (server_id, name, description)
         VALUES ($1, $2, $3)`,
        [server.id, 'General', 'Default channel for expenses']
      );

      await client.query('COMMIT');

      res.status(201).json({
        success: true,
        message: 'Server created successfully',
        data: {
          id: server.id,
          name: server.name,
          description: server.description,
          createdBy: server.created_by,
          createdAt: server.created_at,
          role: 'admin'
        }
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Create server error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    } finally {
      client.release();
    }
  },

  // Get all servers the user is part of
  async getMyServers(req, res) {
    try {
      const userId = req.user.userId;

      const result = await pool.query(
        `SELECT s.id, s.name, s.description, s.created_by, s.is_locked, s.created_at,
                sm.role, sm.joined_at,
                u.username as creator_username,
                COUNT(DISTINCT sm2.user_id) as member_count
         FROM servers s
         JOIN server_members sm ON s.id = sm.server_id
         LEFT JOIN users u ON s.created_by = u.id
         LEFT JOIN server_members sm2 ON s.id = sm2.server_id
         WHERE sm.user_id = $1
         GROUP BY s.id, sm.role, sm.joined_at, u.username
         ORDER BY s.created_at DESC`,
        [userId]
      );

      res.json({
        success: true,
        data: {
          servers: result.rows.map(server => ({
            id: server.id,
            name: server.name,
            description: server.description,
            createdBy: server.created_by,
            creatorUsername: server.creator_username,
            isLocked: server.is_locked,
            role: server.role,
            memberCount: parseInt(server.member_count),
            joinedAt: server.joined_at,
            createdAt: server.created_at
          })),
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Get servers error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get server details with members
  async getServerDetails(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      // Check if user is a member
      const memberCheck = await pool.query(
        'SELECT role FROM server_members WHERE server_id = $1 AND user_id = $2',
        [id, userId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(403).json({
          success: false,
          message: 'You are not a member of this server'
        });
      }

      // Get server details
      const serverResult = await pool.query(
        `SELECT s.*, u.username as creator_username, u.full_name as creator_name
         FROM servers s
         LEFT JOIN users u ON s.created_by = u.id
         WHERE s.id = $1`,
        [id]
      );

      if (serverResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Server not found'
        });
      }

      const server = serverResult.rows[0];

      // Get all members
      const membersResult = await pool.query(
        `SELECT sm.user_id, sm.role, sm.joined_at,
                u.username, u.full_name, u.profile_picture_url, u.upi_id
         FROM server_members sm
         JOIN users u ON sm.user_id = u.id
         WHERE sm.server_id = $1
         ORDER BY sm.role DESC, sm.joined_at ASC`,
        [id]
      );

      res.json({
        success: true,
        data: {
          server: {
            id: server.id,
            name: server.name,
            description: server.description,
            createdBy: server.created_by,
            creatorUsername: server.creator_username,
            creatorName: server.creator_name,
            isLocked: server.is_locked,
            createdAt: server.created_at
          },
          members: membersResult.rows.map(member => ({
            userId: member.user_id,
            username: member.username,
            fullName: member.full_name,
            profilePicture: member.profile_picture_url,
            upiId: member.upi_id, // Visible to all server members
            role: member.role,
            joinedAt: member.joined_at
          })),
          yourRole: memberCheck.rows[0].role
        }
      });
    } catch (error) {
      console.error('Get server details error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Invite a user to server
  async inviteUser(req, res) {
    try {
      const { serverId, userId: inviteeId } = req.body;
      const inviterId = req.user.userId;
      const hasInvitationId = await hasServerInvitationIdColumn();

      // Check if inviter is a member
      const memberCheck = await pool.query(
        'SELECT role FROM server_members WHERE server_id = $1 AND user_id = $2',
        [serverId, inviterId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(403).json({
          success: false,
          message: 'You are not a member of this server'
        });
      }

      // Check if invitee exists
      const userCheck = await pool.query(
        'SELECT id, username FROM users WHERE id = $1 AND is_active = true',
        [inviteeId]
      );

      if (userCheck.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      // Check if already a member
      const alreadyMember = await pool.query(
        'SELECT 1 FROM server_members WHERE server_id = $1 AND user_id = $2',
        [serverId, inviteeId]
      );

      if (alreadyMember.rows.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'User is already a member of this server'
        });
      }

      // Check for pending invitation
      const pendingInvite = await pool.query(
        `SELECT ${hasInvitationId ? 'id' : 'server_id AS id'} FROM server_invitations 
         WHERE server_id = $1 AND invitee_id = $2 AND status = 'pending'`,
        [serverId, inviteeId]
      );

      if (pendingInvite.rows.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Invitation already sent to this user'
        });
      }

      // Create invitation
      const result = await pool.query(
        `INSERT INTO server_invitations (server_id, inviter_id, invitee_id, status)
         VALUES ($1, $2, $3, 'pending')
         RETURNING ${hasInvitationId ? 'id' : 'server_id AS id'}, created_at`,
        [serverId, inviterId, inviteeId]
      );

      const invitationId = result.rows[0].id;

      // Create notification
      const serverInfo = await pool.query(
        'SELECT name FROM servers WHERE id = $1',
        [serverId]
      );

      await pool.query(
        `INSERT INTO notifications (user_id, type, title, message, related_id)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          inviteeId,
          'invitation',
          'Server Invitation',
          `${req.user.username} invited you to join "${serverInfo.rows[0].name}"`,
          invitationId
        ]
      );

      res.status(201).json({
        success: true,
        message: 'Invitation sent successfully',
        data: {
          invitationId,
          invitee: userCheck.rows[0].username,
          createdAt: result.rows[0].created_at
        }
      });
    } catch (error) {
      console.error('Invite user error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get user's invitations
  async getMyInvitations(req, res) {
    try {
      const userId = req.user.userId;
      const hasInvitationId = await hasServerInvitationIdColumn();

      const result = await pool.query(
        `SELECT ${hasInvitationId ? 'si.id' : 'si.server_id AS id'}, si.server_id, si.status, si.created_at,
                s.name as server_name, s.description as server_description,
                u.username as inviter_username, u.full_name as inviter_name
         FROM server_invitations si
         JOIN servers s ON si.server_id = s.id
         JOIN users u ON si.inviter_id = u.id
         WHERE si.invitee_id = $1 AND si.status = 'pending'
         ORDER BY si.created_at DESC`,
        [userId]
      );

      res.json({
        success: true,
        data: {
          invitations: result.rows.map(inv => ({
            id: inv.id,
            serverId: inv.server_id,
            serverName: inv.server_name,
            serverDescription: inv.server_description,
            inviterUsername: inv.inviter_username,
            inviterName: inv.inviter_name,
            status: inv.status,
            createdAt: inv.created_at
          })),
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Get invitations error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Respond to invitation
  async respondToInvitation(req, res) {
    const client = await pool.connect();
    try {
      const { id } = req.params;
      const { action } = req.body; // 'accept' or 'reject'
      const userId = req.user.userId;
      const hasInvitationId = await hasServerInvitationIdColumn();
      const invitationLookupColumn = hasInvitationId ? 'id' : 'server_id';

      await client.query('BEGIN');

      // Get invitation
      const inviteResult = await client.query(
        `SELECT * FROM server_invitations 
         WHERE ${invitationLookupColumn} = $1 AND invitee_id = $2 AND status = 'pending'`,
        [id, userId]
      );

      if (inviteResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({
          success: false,
          message: 'Invitation not found or already responded'
        });
      }

      const invitation = inviteResult.rows[0];
      const publicInvitationId = hasInvitationId ? invitation.id : invitation.server_id;

      if (action === 'accept') {
        // Add user to server
        await client.query(
          `INSERT INTO server_members (server_id, user_id, role)
           VALUES ($1, $2, 'member')`,
          [invitation.server_id, userId]
        );

        // Update invitation status
        await client.query(
          `UPDATE server_invitations 
           SET status = 'accepted', responded_at = CURRENT_TIMESTAMP
           WHERE ${invitationLookupColumn} = $1 AND invitee_id = $2 AND status = 'pending'`,
          [id, userId]
        );
      } else if (action === 'reject') {
        // Update invitation status
        await client.query(
          `UPDATE server_invitations 
           SET status = 'rejected', responded_at = CURRENT_TIMESTAMP
           WHERE ${invitationLookupColumn} = $1 AND invitee_id = $2 AND status = 'pending'`,
          [id, userId]
        );
      } else {
        await client.query('ROLLBACK');
        return res.status(400).json({
          success: false,
          message: 'Invalid action. Use "accept" or "reject"'
        });
      }

      // Remove the original invitation notification after it has been handled
      await client.query(
        `DELETE FROM notifications
         WHERE user_id = $1 AND related_id = $2 AND type = 'invitation'`,
        [userId, publicInvitationId]
      );

      await client.query('COMMIT');

      res.json({
        success: true,
        message: `Invitation ${action}ed successfully`
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Respond to invitation error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    } finally {
      client.release();
    }
  },

  // Leave server
  async leaveServer(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      // Check if user is creator
      const serverCheck = await pool.query(
        'SELECT created_by FROM servers WHERE id = $1',
        [id]
      );

      if (serverCheck.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Server not found'
        });
      }

      if (serverCheck.rows[0].created_by === userId) {
        return res.status(400).json({
          success: false,
          message: 'Server creator cannot leave. Delete the server instead.'
        });
      }

      // Remove member
      const result = await pool.query(
        'DELETE FROM server_members WHERE server_id = $1 AND user_id = $2',
        [id, userId]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'You are not a member of this server'
        });
      }

      res.json({
        success: true,
        message: 'Left server successfully'
      });
    } catch (error) {
      console.error('Leave server error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Delete server (creator only)
  async deleteServer(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      // Check if user is creator
      const serverCheck = await pool.query(
        'SELECT created_by FROM servers WHERE id = $1',
        [id]
      );

      if (serverCheck.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Server not found'
        });
      }

      if (serverCheck.rows[0].created_by !== userId) {
        return res.status(403).json({
          success: false,
          message: 'Only the server creator can delete the server'
        });
      }

      // Delete server (cascade will delete members, channels, etc.)
      await pool.query('DELETE FROM servers WHERE id = $1', [id]);

      res.json({
        success: true,
        message: 'Server deleted successfully'
      });
    } catch (error) {
      console.error('Delete server error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  async getReminderSettings(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      const memberCheck = await pool.query(
        'SELECT role FROM server_members WHERE server_id = $1 AND user_id = $2',
        [id, userId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(403).json({
          success: false,
          message: 'You are not a member of this server'
        });
      }

      const serverResult = await pool.query(
        `SELECT reminder_enabled, reminder_interval_days
         FROM servers
         WHERE id = $1`,
        [id]
      );

      if (serverResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Server not found'
        });
      }

      res.json({
        success: true,
        data: {
          reminderEnabled: serverResult.rows[0].reminder_enabled ?? true,
          reminderIntervalDays: serverResult.rows[0].reminder_interval_days ?? 7,
          canEdit: memberCheck.rows[0].role === 'admin',
        }
      });
    } catch (error) {
      console.error('Get reminder settings error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  async updateReminderSettings(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;
      const { reminderEnabled, reminderIntervalDays } = req.body;

      const memberCheck = await pool.query(
        'SELECT role FROM server_members WHERE server_id = $1 AND user_id = $2',
        [id, userId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(403).json({
          success: false,
          message: 'You are not a member of this server'
        });
      }

      if (memberCheck.rows[0].role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Only admins can update reminder settings'
        });
      }

      const result = await pool.query(
        `UPDATE servers
         SET reminder_enabled = $1,
             reminder_interval_days = $2
         WHERE id = $3
         RETURNING reminder_enabled, reminder_interval_days`,
        [reminderEnabled ?? true, reminderIntervalDays ?? 7, id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Server not found'
        });
      }

      res.json({
        success: true,
        message: 'Reminder settings updated',
        data: {
          reminderEnabled: result.rows[0].reminder_enabled,
          reminderIntervalDays: result.rows[0].reminder_interval_days,
        }
      });
    } catch (error) {
      console.error('Update reminder settings error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },
  async sendReminders(req, res) {
    try {
      const { id } = req.params;
      const { reminderThreshold } = req.body;
      const userId = req.user.userId;

      // Check if user is admin
      const memberCheck = await pool.query(
        'SELECT role FROM server_members WHERE server_id = $1 AND user_id = $2',
        [id, userId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(403).json({
          success: false,
          message: 'You are not a member of this server'
        });
      }

      if (memberCheck.rows[0].role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Only admins can send reminders'
        });
      }

      // Import reminderService
      const { reminderService } = await import('../services/reminderService.js');

      const result = await reminderService.sendBalanceReminders(
        id,
        { reminderThreshold: reminderThreshold || 0, cooldownDays: 1 }
      );

      res.json({
        success: true,
        message: result.message,
        data: {
          remindersSent: result.remindersSent,
          totalDebtors: result.totalDebtors
        }
      });
    } catch (error) {
      console.error('Send reminders error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get users who need reminders
  async getUsersNeedingReminders(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      // Check if user is member
      const memberCheck = await pool.query(
        'SELECT role FROM server_members WHERE server_id = $1 AND user_id = $2',
        [id, userId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(403).json({
          success: false,
          message: 'You are not a member of this server'
        });
      }

      const { reminderService } = await import('../services/reminderService.js');

      const result = await reminderService.getUsersNeedingReminders(id, 100);

      res.json(result);
    } catch (error) {
      console.error('Get users needing reminders error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  }
};

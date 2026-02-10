import { pool } from '../config/database.js';

export const channelController = {
  // Create a channel in a server
 async createChannel(req, res) {
    try {
      const { serverId, name, description } = req.body;
      const userId = req.user.userId;

      // Import validators
      const { validators } = await import('../utils/validators.js');

      // Validate channel name
      const nameValidation = validators.validateName(name, 'Channel name');
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

      // Check if user is a member of the server
      // ... rest of function

      // Check if user is a member of the server
      const memberCheck = await pool.query(
        'SELECT role FROM server_members WHERE server_id = $1 AND user_id = $2',
        [serverId, userId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(403).json({
          success: false,
          message: 'You are not a member of this server'
        });
      }

      // Create channel
      const result = await pool.query(
        `INSERT INTO channels (server_id, name, description)
         VALUES ($1, $2, $3)
         RETURNING id, server_id, name, description, created_at`,
        [serverId, name, description || null]
      );

      const channel = result.rows[0];

      res.status(201).json({
        success: true,
        message: 'Channel created successfully',
        data: {
          id: channel.id,
          serverId: channel.server_id,
          name: channel.name,
          description: channel.description,
          createdAt: channel.created_at
        }
      });
    } catch (error) {
      console.error('Create channel error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get all channels in a server
  async getServerChannels(req, res) {
    try {
      const { serverId } = req.params;
      const userId = req.user.userId;

      // Check if user is a member
      const memberCheck = await pool.query(
        'SELECT id FROM server_members WHERE server_id = $1 AND user_id = $2',
        [serverId, userId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(403).json({
          success: false,
          message: 'You are not a member of this server'
        });
      }

      // Get channels with expense count
      const result = await pool.query(
        `SELECT c.id, c.name, c.description, c.created_at,
                COUNT(e.id) as expense_count,
                COALESCE(SUM(e.total_amount), 0) as total_amount
         FROM channels c
         LEFT JOIN expenses e ON c.id = e.channel_id
         WHERE c.server_id = $1
         GROUP BY c.id
         ORDER BY c.created_at ASC`,
        [serverId]
      );

      res.json({
        success: true,
        data: {
          channels: result.rows.map(channel => ({
            id: channel.id,
            name: channel.name,
            description: channel.description,
            expenseCount: parseInt(channel.expense_count),
            totalAmount: parseFloat(channel.total_amount),
            createdAt: channel.created_at
          })),
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Get channels error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Delete a channel
  async deleteChannel(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      // Get channel and check permissions
      const channelResult = await pool.query(
        `SELECT c.server_id, sm.role
         FROM channels c
         JOIN server_members sm ON c.server_id = sm.server_id
         WHERE c.id = $1 AND sm.user_id = $2`,
        [id, userId]
      );

      if (channelResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Channel not found or you are not a member'
        });
      }

      // Only admins can delete channels
      if (channelResult.rows[0].role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Only admins can delete channels'
        });
      }

      // Delete channel (cascade will delete associated expenses)
      await pool.query('DELETE FROM channels WHERE id = $1', [id]);

      res.json({
        success: true,
        message: 'Channel deleted successfully'
      });
    } catch (error) {
      console.error('Delete channel error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  }
};
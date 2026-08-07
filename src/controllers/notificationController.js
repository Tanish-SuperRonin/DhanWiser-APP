import { pool } from '../config/database.js';

export const notificationController = {
  // Get all notifications for current user (paginated)
  async getMyNotifications(req, res) {
    try {
      const { reminderService } = await import('../services/reminderService.js');
      await reminderService.processAutomaticReminders();

      const userId = req.user.userId;
      const { unreadOnly } = req.query;
      const page = Math.max(1, parseInt(req.query.page) || 1);
      const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 50));
      const offset = (page - 1) * limit;

      // Build WHERE clause
      let whereClause = 'WHERE user_id = $1';
      const params = [userId];

      if (unreadOnly === 'true') {
        whereClause += ` AND is_read = false`;
      }

      // Get total count
      const countResult = await pool.query(
        `SELECT COUNT(*) FROM notifications ${whereClause}`,
        params
      );
      const total = parseInt(countResult.rows[0].count);
      const totalPages = Math.ceil(total / limit);

      // Get paginated notifications
      const result = await pool.query(
        `SELECT id, type, title, message, is_read, related_id, created_at
         FROM notifications
         ${whereClause}
         ORDER BY created_at DESC
         LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
        [...params, limit, offset]
      );

      // Get unread count (always, for badge)
      const unreadCount = await pool.query(
        'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false',
        [userId]
      );

      res.json({
        success: true,
        data: {
          notifications: result.rows.map(notif => ({
            id: notif.id,
            type: notif.type,
            title: notif.title,
            message: notif.message,
            isRead: notif.is_read,
            relatedId: notif.related_id,
            createdAt: notif.created_at
          })),
          unreadCount: parseInt(unreadCount.rows[0].count),
          totalCount: total,
          pagination: {
            page,
            limit,
            total,
            totalPages,
            hasMore: page < totalPages
          }
        }
      });
    } catch (error) {
      console.error('Get notifications error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Mark notification as read
  async markAsRead(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      // Update notification
      const result = await pool.query(
        `UPDATE notifications 
         SET is_read = true 
         WHERE id = $1 AND user_id = $2
         RETURNING id, is_read`,
        [id, userId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Notification not found'
        });
      }

      res.json({
        success: true,
        message: 'Notification marked as read'
      });
    } catch (error) {
      console.error('Mark as read error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Mark all notifications as read
  async markAllAsRead(req, res) {
    try {
      const userId = req.user.userId;

      const result = await pool.query(
        `UPDATE notifications 
         SET is_read = true 
         WHERE user_id = $1 AND is_read = false
         RETURNING id`,
        [userId]
      );

      res.json({
        success: true,
        message: `Marked ${result.rows.length} notifications as read`,
        data: {
          updatedCount: result.rows.length
        }
      });
    } catch (error) {
      console.error('Mark all as read error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Delete a notification
  async deleteNotification(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      const result = await pool.query(
        'DELETE FROM notifications WHERE id = $1 AND user_id = $2',
        [id, userId]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Notification not found'
        });
      }

      res.json({
        success: true,
        message: 'Notification deleted successfully'
      });
    } catch (error) {
      console.error('Delete notification error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Delete all read notifications
  async deleteAllRead(req, res) {
    try {
      const userId = req.user.userId;

      const result = await pool.query(
        'DELETE FROM notifications WHERE user_id = $1 AND is_read = true RETURNING id',
        [userId]
      );

      res.json({
        success: true,
        message: `Deleted ${result.rows.length} read notifications`,
        data: {
          deletedCount: result.rows.length
        }
      });
    } catch (error) {
      console.error('Delete all read error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get unread count (quick check for badge)
  async getUnreadCount(req, res) {
    try {
      const { reminderService } = await import('../services/reminderService.js');
      await reminderService.processAutomaticReminders();

      const userId = req.user.userId;

      const result = await pool.query(
        'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false',
        [userId]
      );

      res.json({
        success: true,
        data: {
          unreadCount: parseInt(result.rows[0].count)
        }
      });
    } catch (error) {
      console.error('Get unread count error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get notifications by type
  async getNotificationsByType(req, res) {
    try {
      const userId = req.user.userId;
      const { type } = req.params;

      // Valid types: 'invitation', 'settlement_request', 'settlement_approved', 'settlement_rejected', 'expense_added', 'payment_reminder'
      const validTypes = ['invitation', 'settlement_request', 'settlement_approved', 'settlement_rejected', 'expense_added', 'payment_reminder'];

      if (!validTypes.includes(type)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid notification type'
        });
      }

      const result = await pool.query(
        `SELECT id, type, title, message, is_read, related_id, created_at
         FROM notifications
         WHERE user_id = $1 AND type = $2
         ORDER BY created_at DESC`,
        [userId, type]
      );

      res.json({
        success: true,
        data: {
          notifications: result.rows.map(notif => ({
            id: notif.id,
            type: notif.type,
            title: notif.title,
            message: notif.message,
            isRead: notif.is_read,
            relatedId: notif.related_id,
            createdAt: notif.created_at
          })),
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Get notifications by type error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },
  // Send payment reminders (at the end of serverController object)
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

      // Import reminderService at the top of the file
      const { reminderService } = await import('../services/reminderService.js');

      const result = await reminderService.sendBalanceReminders(
        id, 
        reminderThreshold || 100
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

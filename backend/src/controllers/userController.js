import { pool } from '../config/database.js';

export const userController = {
  // Get current user's profile
  async getMyProfile(req, res) {
    try {
      const userId = req.user.userId; // From JWT token

      const result = await pool.query(
        `SELECT id, username, email, full_name, upi_id, profile_picture_url, created_at 
         FROM users 
         WHERE id = $1 AND is_active = true`,
        [userId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const user = result.rows[0];

      res.json({
        success: true,
        data: {
          id: user.id,
          username: user.username,
          email: user.email,
          fullName: user.full_name,
          upiId: user.upi_id,
          profilePicture: user.profile_picture_url,
          createdAt: user.created_at
        }
      });
    } catch (error) {
      console.error('Get profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Update current user's profile
  async updateMyProfile(req, res) {
    try {
      const userId = req.user.userId;
      const { fullName, upiId, profilePicture } = req.body;

      // Build dynamic update query
      const updates = [];
      const values = [];
      let paramCount = 1;

      if (fullName !== undefined) {
        updates.push(`full_name = $${paramCount}`);
        values.push(fullName);
        paramCount++;
      }

      if (upiId !== undefined) {
        updates.push(`upi_id = $${paramCount}`);
        values.push(upiId);
        paramCount++;
      }

      if (profilePicture !== undefined) {
        updates.push(`profile_picture_url = $${paramCount}`);
        values.push(profilePicture);
        paramCount++;
      }

      if (updates.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No fields to update'
        });
      }

      // Add updated_at
      updates.push(`updated_at = CURRENT_TIMESTAMP`);
      values.push(userId);

      const query = `
        UPDATE users 
        SET ${updates.join(', ')}
        WHERE id = $${paramCount}
        RETURNING id, username, email, full_name, upi_id, profile_picture_url, updated_at
      `;

      const result = await pool.query(query, values);
      const user = result.rows[0];

      res.json({
        success: true,
        message: 'Profile updated successfully',
        data: {
          id: user.id,
          username: user.username,
          email: user.email,
          fullName: user.full_name,
          upiId: user.upi_id,
          profilePicture: user.profile_picture_url,
          updatedAt: user.updated_at
        }
      });
    } catch (error) {
      console.error('Update profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get any user's public profile by ID
  async getUserById(req, res) {
    try {
      const { id } = req.params;

      const result = await pool.query(
        `SELECT id, username, full_name, profile_picture_url, created_at 
         FROM users 
         WHERE id = $1 AND is_active = true`,
        [id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const user = result.rows[0];

      res.json({
        success: true,
        data: {
          id: user.id,
          username: user.username,
          fullName: user.full_name,
          profilePicture: user.profile_picture_url,
          createdAt: user.created_at
          // Note: email and upiId are private, not shown here
        }
      });
    } catch (error) {
      console.error('Get user error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Search users globally by username
  async searchUsers(req, res) {
    try {
      const { query } = req.query;

      if (!query || query.trim().length < 2) {
        return res.status(400).json({
          success: false,
          message: 'Search query must be at least 2 characters'
        });
      }

      const result = await pool.query(
        `SELECT id, username, full_name, profile_picture_url 
         FROM users 
         WHERE username ILIKE $1 AND is_active = true
         LIMIT 20`,
        [`%${query}%`]
      );

      res.json({
        success: true,
        data: {
          users: result.rows.map(user => ({
            id: user.id,
            username: user.username,
            fullName: user.full_name,
            profilePicture: user.profile_picture_url
          })),
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Search users error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  }
};
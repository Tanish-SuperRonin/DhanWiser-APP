import { pool } from '../config/database.js';

export const settlementController = {
  // Initiate a settlement (payer marks they've paid)
  async initiateSettlement(req, res) {
    try {
      const { serverId, receiverId, amount, notes } = req.body;
      const payerId = req.user.userId;

      // Import validators
      const { validators } = await import('../utils/validators.js');

      // Validate amount
      const amountValidation = validators.validateSettlementAmount(amount);
      if (!amountValidation.valid) {
        return res.status(400).json({
          success: false,
          message: amountValidation.error
        });
      }

      // Validate notes
      const notesValidation = validators.validateDescription(notes);
      if (!notesValidation.valid) {
        return res.status(400).json({
          success: false,
          message: notesValidation.error
        });
      }

      // Verify both users are members of the server
      const memberCheck = await pool.query(
        `SELECT user_id FROM server_members 
         WHERE server_id = $1 AND user_id IN ($2, $3)`,
        [serverId, payerId, receiverId]
      );

      if (memberCheck.rows.length !== 2) {
        return res.status(403).json({
          success: false,
          message: 'Both users must be members of this server'
        });
      }

      // Cannot settle with yourself
      if (payerId === receiverId) {
        return res.status(400).json({
          success: false,
          message: 'Cannot create settlement with yourself'
        });
      }

      // Create settlement
      const result = await pool.query(
        `INSERT INTO settlements (server_id, payer_id, receiver_id, amount, status, notes)
         VALUES ($1, $2, $3, $4, 'pending', $5)
         RETURNING id, server_id, payer_id, receiver_id, amount, status, notes, initiated_at`,
        [serverId, payerId, receiverId, amount, notes || null]
      );

      const settlement = result.rows[0];

      // Get receiver's UPI ID for the payer to use
      const receiverInfo = await pool.query(
        'SELECT username, full_name, upi_id FROM users WHERE id = $1',
        [receiverId]
      );

      // Create notification for receiver
      const payerInfo = await pool.query(
        'SELECT username FROM users WHERE id = $1',
        [payerId]
      );

      await pool.query(
        `INSERT INTO notifications (user_id, type, title, message, related_id)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          receiverId,
          'settlement_request',
          'Settlement Request',
          `${payerInfo.rows[0].username} has marked a payment of ₹${amount} to you. Please verify and approve.`,
          settlement.id
        ]
      );

      res.status(201).json({
        success: true,
        message: 'Settlement initiated successfully',
        data: {
          id: settlement.id,
          serverId: settlement.server_id,
          payerId: settlement.payer_id,
          receiverId: settlement.receiver_id,
          receiverInfo: {
            username: receiverInfo.rows[0].username,
            fullName: receiverInfo.rows[0].full_name,
            upiId: receiverInfo.rows[0].upi_id
          },
          amount: parseFloat(settlement.amount),
          status: settlement.status,
          notes: settlement.notes,
          initiatedAt: settlement.initiated_at
        }
      });
    } catch (error) {
      console.error('Initiate settlement error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get settlements for a server
  async getServerSettlements(req, res) {
    try {
      const { serverId } = req.params;
      const userId = req.user.userId;
      const { status } = req.query; // Optional filter: 'pending', 'approved', 'rejected'

      // Verify membership
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

      // Build query
      let query = `
        SELECT s.id, s.amount, s.status, s.notes, s.initiated_at, s.approved_at,
               u1.id as payer_id, u1.username as payer_username, u1.full_name as payer_name,
               u2.id as receiver_id, u2.username as receiver_username, u2.full_name as receiver_name
        FROM settlements s
        JOIN users u1 ON s.payer_id = u1.id
        JOIN users u2 ON s.receiver_id = u2.id
        WHERE s.server_id = $1
      `;

      const params = [serverId];

      if (status) {
        query += ` AND s.status = $2`;
        params.push(status);
      }

      query += ` ORDER BY s.initiated_at DESC`;

      const result = await pool.query(query, params);

      res.json({
        success: true,
        data: {
          settlements: result.rows.map(settlement => ({
            id: settlement.id,
            payer: {
              id: settlement.payer_id,
              username: settlement.payer_username,
              fullName: settlement.payer_name
            },
            receiver: {
              id: settlement.receiver_id,
              username: settlement.receiver_username,
              fullName: settlement.receiver_name
            },
            amount: parseFloat(settlement.amount),
            status: settlement.status,
            notes: settlement.notes,
            initiatedAt: settlement.initiated_at,
            approvedAt: settlement.approved_at
          })),
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Get settlements error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get pending settlements for current user (where they're the receiver)
  async getMyPendingSettlements(req, res) {
    try {
      const userId = req.user.userId;

      const result = await pool.query(
        `SELECT s.id, s.server_id, s.amount, s.notes, s.initiated_at,
                srv.name as server_name,
                u.id as payer_id, u.username as payer_username, u.full_name as payer_name
         FROM settlements s
         JOIN servers srv ON s.server_id = srv.id
         JOIN users u ON s.payer_id = u.id
         WHERE s.receiver_id = $1 AND s.status = 'pending'
         ORDER BY s.initiated_at DESC`,
        [userId]
      );

      res.json({
        success: true,
        data: {
          settlements: result.rows.map(settlement => ({
            id: settlement.id,
            serverId: settlement.server_id,
            serverName: settlement.server_name,
            payer: {
              id: settlement.payer_id,
              username: settlement.payer_username,
              fullName: settlement.payer_name
            },
            amount: parseFloat(settlement.amount),
            notes: settlement.notes,
            initiatedAt: settlement.initiated_at
          })),
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Get pending settlements error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Approve settlement (receiver confirms payment received)
  async approveSettlement(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      // Get settlement
      const settlementResult = await pool.query(
        'SELECT * FROM settlements WHERE id = $1',
        [id]
      );

      if (settlementResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Settlement not found'
        });
      }

      const settlement = settlementResult.rows[0];

      // Only receiver can approve
      if (settlement.receiver_id !== userId) {
        return res.status(403).json({
          success: false,
          message: 'Only the receiver can approve this settlement'
        });
      }

      // Check if already processed
      if (settlement.status !== 'pending') {
        return res.status(400).json({
          success: false,
          message: `Settlement already ${settlement.status}`
        });
      }

      // Update settlement status
      await pool.query(
        `UPDATE settlements 
         SET status = 'approved', approved_at = CURRENT_TIMESTAMP
         WHERE id = $1`,
        [id]
      );

      // Create notification for payer
      await pool.query(
        `INSERT INTO notifications (user_id, type, title, message, related_id)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          settlement.payer_id,
          'settlement_approved',
          'Settlement Approved',
          `Your payment of ₹${settlement.amount} has been confirmed.`,
          id
        ]
      );

      res.json({
        success: true,
        message: 'Settlement approved successfully'
      });
    } catch (error) {
      console.error('Approve settlement error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Reject settlement (receiver says payment not received)
  async rejectSettlement(req, res) {
    try {
      const { id } = req.params;
      const { reason } = req.body;
      const userId = req.user.userId;

      // Get settlement
      const settlementResult = await pool.query(
        'SELECT * FROM settlements WHERE id = $1',
        [id]
      );

      if (settlementResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Settlement not found'
        });
      }

      const settlement = settlementResult.rows[0];

      // Only receiver can reject
      if (settlement.receiver_id !== userId) {
        return res.status(403).json({
          success: false,
          message: 'Only the receiver can reject this settlement'
        });
      }

      // Check if already processed
      if (settlement.status !== 'pending') {
        return res.status(400).json({
          success: false,
          message: `Settlement already ${settlement.status}`
        });
      }

      // Update settlement status
      const noteWithReason = settlement.notes 
        ? `${settlement.notes} | Rejection reason: ${reason || 'Not specified'}`
        : `Rejection reason: ${reason || 'Not specified'}`;

      await pool.query(
        `UPDATE settlements 
         SET status = 'rejected', approved_at = CURRENT_TIMESTAMP, notes = $1
         WHERE id = $2`,
        [noteWithReason, id]
      );

      // Create notification for payer
      await pool.query(
        `INSERT INTO notifications (user_id, type, title, message, related_id)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          settlement.payer_id,
          'settlement_rejected',
          'Settlement Rejected',
          `Your payment of ₹${settlement.amount} was not confirmed. Reason: ${reason || 'Not specified'}`,
          id
        ]
      );

      res.json({
        success: true,
        message: 'Settlement rejected'
      });
    } catch (error) {
      console.error('Reject settlement error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get settlement history (for audit/reference)
  async getSettlementHistory(req, res) {
    try {
      const { serverId } = req.params;
      const userId = req.user.userId;

      // Verify membership
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

      // Get approved settlements only
      const result = await pool.query(
        `SELECT s.id, s.amount, s.notes, s.initiated_at, s.approved_at,
                u1.username as payer_username, u1.full_name as payer_name,
                u2.username as receiver_username, u2.full_name as receiver_name
         FROM settlements s
         JOIN users u1 ON s.payer_id = u1.id
         JOIN users u2 ON s.receiver_id = u2.id
         WHERE s.server_id = $1 AND s.status = 'approved'
         ORDER BY s.approved_at DESC`,
        [serverId]
      );

      // Calculate total settled amount
      const totalSettled = result.rows.reduce((sum, s) => sum + parseFloat(s.amount), 0);

      res.json({
        success: true,
        data: {
          settlements: result.rows.map(s => ({
            id: s.id,
            payer: {
              username: s.payer_username,
              fullName: s.payer_name
            },
            receiver: {
              username: s.receiver_username,
              fullName: s.receiver_name
            },
            amount: parseFloat(s.amount),
            notes: s.notes,
            initiatedAt: s.initiated_at,
            approvedAt: s.approved_at
          })),
          totalSettled,
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Get settlement history error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  }
};
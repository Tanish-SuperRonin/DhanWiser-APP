import { pool } from '../config/database.js';

export const expenseController = {
  // Add an expense
  async addExpense(req, res) {
    const client = await pool.connect();
    try {
      const { channelId, title, description, totalAmount, expenseDate, participants } = req.body;
      const userId = req.user.userId;

      await client.query('BEGIN');

      // Get channel and verify membership
      const channelResult = await client.query(
        `SELECT c.server_id, sm.user_id
         FROM channels c
         JOIN server_members sm ON c.server_id = sm.server_id
         WHERE c.id = $1 AND sm.user_id = $2`,
        [channelId, userId]
      );

      if (channelResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(403).json({
          success: false,
          message: 'Channel not found or you are not a member'
        });
      }

      const serverId = channelResult.rows[0].server_id;

      // Create expense
      const expenseResult = await client.query(
        `INSERT INTO expenses (channel_id, server_id, created_by, title, description, total_amount, expense_date)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING id, channel_id, server_id, created_by, title, description, total_amount, expense_date, created_at`,
        [channelId, serverId, userId, title, description || null, totalAmount, expenseDate]
      );

      const expense = expenseResult.rows[0];

      // Add participants
      // participants format: [{ userId: 1, amountPaid: 100, amountOwed: 50 }, ...]
      for (const participant of participants) {
        await client.query(
          `INSERT INTO expense_participants (expense_id, user_id, amount_paid, amount_owed)
           VALUES ($1, $2, $3, $4)`,
          [expense.id, participant.userId, participant.amountPaid || 0, participant.amountOwed || 0]
        );
      }

      await client.query('COMMIT');

      // Get full expense details
      const fullExpense = await pool.query(
        `SELECT e.*, u.username as created_by_username,
                json_agg(json_build_object(
                  'userId', ep.user_id,
                  'username', u2.username,
                  'amountPaid', ep.amount_paid,
                  'amountOwed', ep.amount_owed
                )) as participants
         FROM expenses e
         JOIN users u ON e.created_by = u.id
         LEFT JOIN expense_participants ep ON e.id = ep.expense_id
         LEFT JOIN users u2 ON ep.user_id = u2.id
         WHERE e.id = $1
         GROUP BY e.id, u.username`,
        [expense.id]
      );

      res.status(201).json({
        success: true,
        message: 'Expense added successfully',
        data: fullExpense.rows[0]
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Add expense error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    } finally {
      client.release();
    }
  },

  // Get expenses in a channel
  async getChannelExpenses(req, res) {
    try {
      const { channelId } = req.params;
      const userId = req.user.userId;

      // Verify membership
      const memberCheck = await pool.query(
        `SELECT sm.user_id
         FROM channels c
         JOIN server_members sm ON c.server_id = sm.server_id
         WHERE c.id = $1 AND sm.user_id = $2`,
        [channelId, userId]
      );

      if (memberCheck.rows.length === 0) {
        return res.status(403).json({
          success: false,
          message: 'You do not have access to this channel'
        });
      }

      // Get expenses with participants
      const result = await pool.query(
        `SELECT e.id, e.title, e.description, e.total_amount, e.expense_date, e.created_at,
                u.id as created_by_id, u.username as created_by_username,
                json_agg(json_build_object(
                  'userId', ep.user_id,
                  'username', u2.username,
                  'fullName', u2.full_name,
                  'amountPaid', ep.amount_paid,
                  'amountOwed', ep.amount_owed
                )) as participants
         FROM expenses e
         JOIN users u ON e.created_by = u.id
         LEFT JOIN expense_participants ep ON e.id = ep.expense_id
         LEFT JOIN users u2 ON ep.user_id = u2.id
         WHERE e.channel_id = $1
         GROUP BY e.id, u.id, u.username
         ORDER BY e.expense_date DESC, e.created_at DESC`,
        [channelId]
      );

      res.json({
        success: true,
        data: {
          expenses: result.rows.map(expense => ({
            id: expense.id,
            title: expense.title,
            description: expense.description,
            totalAmount: parseFloat(expense.total_amount),
            expenseDate: expense.expense_date,
            createdBy: {
              id: expense.created_by_id,
              username: expense.created_by_username
            },
            participants: expense.participants.map(p => ({
              userId: p.userId,
              username: p.username,
              fullName: p.fullName,
              amountPaid: parseFloat(p.amountPaid),
              amountOwed: parseFloat(p.amountOwed)
            })),
            createdAt: expense.created_at
          })),
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Get channel expenses error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Get all expenses in a server
  async getServerExpenses(req, res) {
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

      // Get all expenses with channel info
      const result = await pool.query(
        `SELECT e.id, e.title, e.description, e.total_amount, e.expense_date, e.created_at,
                c.id as channel_id, c.name as channel_name,
                u.id as created_by_id, u.username as created_by_username,
                json_agg(json_build_object(
                  'userId', ep.user_id,
                  'username', u2.username,
                  'fullName', u2.full_name,
                  'amountPaid', ep.amount_paid,
                  'amountOwed', ep.amount_owed
                )) as participants
         FROM expenses e
         JOIN channels c ON e.channel_id = c.id
         JOIN users u ON e.created_by = u.id
         LEFT JOIN expense_participants ep ON e.id = ep.expense_id
         LEFT JOIN users u2 ON ep.user_id = u2.id
         WHERE e.server_id = $1
         GROUP BY e.id, c.id, c.name, u.id, u.username
         ORDER BY e.expense_date DESC, e.created_at DESC`,
        [serverId]
      );

      res.json({
        success: true,
        data: {
          expenses: result.rows.map(expense => ({
            id: expense.id,
            title: expense.title,
            description: expense.description,
            totalAmount: parseFloat(expense.total_amount),
            expenseDate: expense.expense_date,
            channel: {
              id: expense.channel_id,
              name: expense.channel_name
            },
            createdBy: {
              id: expense.created_by_id,
              username: expense.created_by_username
            },
            participants: expense.participants.map(p => ({
              userId: p.userId,
              username: p.username,
              fullName: p.fullName,
              amountPaid: parseFloat(p.amountPaid),
              amountOwed: parseFloat(p.amountOwed)
            })),
            createdAt: expense.created_at
          })),
          count: result.rows.length
        }
      });
    } catch (error) {
      console.error('Get server expenses error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Calculate balances in a server
  async getServerBalances(req, res) {
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

      // Calculate net balances for each user
      const result = await pool.query(
        `SELECT 
           ep.user_id,
           u.username,
           u.full_name,
           SUM(ep.amount_paid) as total_paid,
           SUM(ep.amount_owed) as total_owed,
           SUM(ep.amount_paid - ep.amount_owed) as net_balance
         FROM expense_participants ep
         JOIN expenses e ON ep.expense_id = e.id
         JOIN users u ON ep.user_id = u.id
         WHERE e.server_id = $1
         GROUP BY ep.user_id, u.username, u.full_name
         ORDER BY net_balance DESC`,
        [serverId]
      );

      // Simplify settlements (who should pay whom)
      const balances = result.rows.map(row => ({
        userId: row.user_id,
        username: row.username,
        fullName: row.full_name,
        totalPaid: parseFloat(row.total_paid),
        totalOwed: parseFloat(row.total_owed),
        netBalance: parseFloat(row.net_balance)
      }));

      // Calculate suggested settlements
      const settlements = calculateOptimalSettlements(balances);

      res.json({
        success: true,
        data: {
          balances,
          suggestedSettlements: settlements
        }
      });
    } catch (error) {
      console.error('Get balances error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  }
};

// Helper function to calculate optimal settlements
function calculateOptimalSettlements(balances) {
  const settlements = [];
  
  // Separate debtors (negative balance) and creditors (positive balance)
  const debtors = balances.filter(b => b.netBalance < -0.01).map(b => ({ ...b }));
  const creditors = balances.filter(b => b.netBalance > 0.01).map(b => ({ ...b }));

  let i = 0, j = 0;

  while (i < debtors.length && j < creditors.length) {
    const debt = Math.abs(debtors[i].netBalance);
    const credit = creditors[j].netBalance;
    const amount = Math.min(debt, credit);

    if (amount > 0.01) {
      settlements.push({
        from: {
          userId: debtors[i].userId,
          username: debtors[i].username
        },
        to: {
          userId: creditors[j].userId,
          username: creditors[j].username
        },
        amount: parseFloat(amount.toFixed(2))
      });
    }

    debtors[i].netBalance += amount;
    creditors[j].netBalance -= amount;

    if (Math.abs(debtors[i].netBalance) < 0.01) i++;
    if (Math.abs(creditors[j].netBalance) < 0.01) j++;
  }

  return settlements;
}
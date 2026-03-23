import { pool } from '../config/database.js';

export const reminderService = {
  // Send reminders for pending balances
  async sendBalanceReminders(serverId, reminderThreshold = 100) {
    try {
      // Calculate net balances for the server
      const balances = await pool.query(
        `SELECT 
           ep.user_id,
           u.username,
           u.full_name,
           SUM(ep.amount_paid - ep.amount_owed) as net_balance
         FROM expense_participants ep
         JOIN expenses e ON ep.expense_id = e.id
         JOIN users u ON ep.user_id = u.id
         WHERE e.server_id = $1
         GROUP BY ep.user_id, u.username, u.full_name
         HAVING SUM(ep.amount_paid - ep.amount_owed) < 0`,
        [serverId]
      );

      const debtors = balances.rows.filter(b => Math.abs(parseFloat(b.net_balance)) >= reminderThreshold);

      if (debtors.length === 0) {
        return {
          success: true,
          message: 'No reminders needed',
          remindersSent: 0
        };
      }

      // Get server name
      const serverInfo = await pool.query(
        'SELECT name FROM servers WHERE id = $1',
        [serverId]
      );

      const serverName = serverInfo.rows[0]?.name || 'Unknown Server';

      // Send notifications to debtors
      let remindersSent = 0;

      for (const debtor of debtors) {
        const amountOwed = Math.abs(parseFloat(debtor.net_balance));

        // Check if we already sent a reminder recently (within last 24 hours)
        const recentReminder = await pool.query(
          `SELECT id FROM notifications 
           WHERE user_id = $1 
           AND type = 'payment_reminder' 
           AND created_at > NOW() - INTERVAL '24 hours'
           ORDER BY created_at DESC
           LIMIT 1`,
          [debtor.user_id]
        );

        // Skip if reminder was sent recently
        if (recentReminder.rows.length > 0) {
          continue;
        }

        // Create reminder notification
        await pool.query(
          `INSERT INTO notifications (user_id, type, title, message, related_id)
           VALUES ($1, $2, $3, $4, $5)`,
          [
            debtor.user_id,
            'payment_reminder',
            'Payment Reminder',
            `You have pending dues of ₹${amountOwed.toFixed(2)} in "${serverName}". Please settle your balance soon.`,
            serverId
          ]
        );

        remindersSent++;
      }

      return {
        success: true,
        message: `Sent ${remindersSent} reminders`,
        remindersSent,
        totalDebtors: debtors.length
      };
    } catch (error) {
      console.error('Send reminders error:', error);
      throw error;
    }
  },

  // Send reminder for a specific user in a server
  async sendIndividualReminder(serverId, userId) {
    try {
      // Calculate user's balance
      const balance = await pool.query(
        `SELECT 
           SUM(ep.amount_paid - ep.amount_owed) as net_balance
         FROM expense_participants ep
         JOIN expenses e ON ep.expense_id = e.id
         WHERE e.server_id = $1 AND ep.user_id = $2
         GROUP BY ep.user_id`,
        [serverId, userId]
      );

      if (balance.rows.length === 0) {
        return {
          success: false,
          message: 'No balance found for this user'
        };
      }

      const netBalance = parseFloat(balance.rows[0].net_balance);

      // Only send reminder if user owes money
      if (netBalance >= 0) {
        return {
          success: false,
          message: 'User does not owe money'
        };
      }

      const amountOwed = Math.abs(netBalance);

      // Get server name
      const serverInfo = await pool.query(
        'SELECT name FROM servers WHERE id = $1',
        [serverId]
      );

      const serverName = serverInfo.rows[0]?.name || 'Unknown Server';

      // Create notification
      await pool.query(
        `INSERT INTO notifications (user_id, type, title, message, related_id)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          userId,
          'payment_reminder',
          'Payment Reminder',
          `You have pending dues of ₹${amountOwed.toFixed(2)} in "${serverName}". Please settle your balance.`,
          serverId
        ]
      );

      return {
        success: true,
        message: 'Reminder sent successfully',
        amountOwed
      };
    } catch (error) {
      console.error('Send individual reminder error:', error);
      throw error;
    }
  },

  // Get users who need reminders in a server
  async getUsersNeedingReminders(serverId, reminderThreshold = 100) {
    try {
      const result = await pool.query(
        `SELECT 
           ep.user_id,
           u.username,
           u.full_name,
           SUM(ep.amount_paid - ep.amount_owed) as net_balance,
           MAX(n.created_at) as last_reminder_sent
         FROM expense_participants ep
         JOIN expenses e ON ep.expense_id = e.id
         JOIN users u ON ep.user_id = u.id
         LEFT JOIN notifications n ON n.user_id = ep.user_id 
           AND n.type = 'payment_reminder' 
           AND n.created_at > NOW() - INTERVAL '7 days'
         WHERE e.server_id = $1
         GROUP BY ep.user_id, u.username, u.full_name
         HAVING SUM(ep.amount_paid - ep.amount_owed) < $2`,
        [serverId, -reminderThreshold]
      );

      return {
        success: true,
        data: result.rows.map(row => ({
          userId: row.user_id,
          username: row.username,
          fullName: row.full_name,
          amountOwed: Math.abs(parseFloat(row.net_balance)),
          lastReminderSent: row.last_reminder_sent
        }))
      };
    } catch (error) {
      console.error('Get users needing reminders error:', error);
      throw error;
    }
  }
};
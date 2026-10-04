import { pool } from '../config/database.js';

export const reminderService = {
  async processAutomaticReminders() {
    const serversResult = await pool.query(
      `SELECT id, name, reminder_enabled, reminder_interval_days
       FROM servers
       WHERE reminder_enabled = true`
    );

    let totalSent = 0;

    for (const server of serversResult.rows) {
      const result = await this.sendBalanceReminders(server.id, {
        reminderThreshold: 0,
        cooldownDays: server.reminder_interval_days || 7,
      });
      totalSent += result.remindersSent || 0;
    }

    return {
      success: true,
      remindersSent: totalSent,
      serversChecked: serversResult.rows.length,
    };
  },

  async sendBalanceReminders(
      serverId,
      { reminderThreshold = 0, cooldownDays = 1 } = {}
    ) {
    try {
      const balances = await this._getOutstandingBalances(serverId);
      const debtors = balances.filter(
        (balance) =>
          balance.balance < -0.01 &&
          Math.abs(balance.balance) >= reminderThreshold
      );

      if (debtors.length === 0) {
        return {
          success: true,
          message: 'No reminders needed',
          remindersSent: 0,
          totalDebtors: 0,
        };
      }

      const serverInfo = await pool.query(
        'SELECT name FROM servers WHERE id = $1',
        [serverId]
      );
      const serverName = serverInfo.rows[0]?.name || 'Unknown Group';

      let remindersSent = 0;

      for (const debtor of debtors) {
        const recentReminder = await pool.query(
          `SELECT id
           FROM notifications
           WHERE user_id = $1
             AND type = 'payment_reminder'
             AND related_id = $2
             AND created_at > NOW() - ($3::text || ' days')::interval
           ORDER BY created_at DESC
           LIMIT 1`,
          [debtor.userId, serverId, cooldownDays]
        );

        if (recentReminder.rows.length > 0) {
          continue;
        }

        await pool.query(
          `INSERT INTO notifications (user_id, type, title, message, related_id)
           VALUES ($1, $2, $3, $4, $5)`,
          [
            debtor.userId,
            'payment_reminder',
            'Payment Due Reminder',
            `You still owe ₹${Math.abs(debtor.balance).toFixed(2)} in "${serverName}". Please settle up.`,
            serverId,
          ]
        );

        remindersSent++;
      }

      return {
        success: true,
        message: `Sent ${remindersSent} reminders`,
        remindersSent,
        totalDebtors: debtors.length,
      };
    } catch (error) {
      console.error('Send reminders error:', error);
      throw error;
    }
  },

  async getUsersNeedingReminders(serverId, reminderThreshold = 0) {
    try {
      const balances = await this._getOutstandingBalances(serverId);

      const users = await Promise.all(
        balances
          .filter(
            (balance) =>
              balance.balance < -0.01 &&
              Math.abs(balance.balance) >= reminderThreshold
          )
          .map(async (balance) => {
            const recentReminder = await pool.query(
              `SELECT created_at
               FROM notifications
               WHERE user_id = $1
                 AND type = 'payment_reminder'
                 AND related_id = $2
               ORDER BY created_at DESC
               LIMIT 1`,
              [balance.userId, serverId]
            );

            return {
              userId: balance.userId,
              username: balance.username,
              fullName: balance.fullName,
              amountOwed: Math.abs(balance.balance),
              lastReminderSent: recentReminder.rows[0]?.created_at || null,
            };
          })
      );

      return {
        success: true,
        data: users,
      };
    } catch (error) {
      console.error('Get users needing reminders error:', error);
      throw error;
    }
  },

  async _getOutstandingBalances(serverId) {
    const result = await pool.query(
      `WITH expense_balances AS (
         SELECT
           ep.user_id,
           u.username,
           u.full_name,
           SUM(ep.amount_paid) AS total_paid,
           SUM(ep.amount_owed) AS total_owed
         FROM expense_participants ep
         JOIN expenses e ON ep.expense_id = e.id
         JOIN users u ON ep.user_id = u.id
         WHERE e.server_id = $1
         GROUP BY ep.user_id, u.username, u.full_name
       ),
       settlement_balances AS (
         SELECT
           user_id,
           SUM(amount) AS total_settled
         FROM (
           SELECT payer_id AS user_id, amount
           FROM settlements
           WHERE server_id = $1 AND status = 'approved'

           UNION ALL

           SELECT receiver_id AS user_id, -amount
           FROM settlements
           WHERE server_id = $1 AND status = 'approved'
         ) combined
         GROUP BY user_id
       )
       SELECT
         eb.user_id,
         eb.username,
         eb.full_name,
         (eb.total_paid - eb.total_owed + COALESCE(sb.total_settled, 0)) AS balance
       FROM expense_balances eb
       LEFT JOIN settlement_balances sb ON eb.user_id = sb.user_id`,
      [serverId]
    );

    return result.rows.map((row) => ({
      userId: row.user_id,
      username: row.username,
      fullName: row.full_name,
      balance: parseFloat(row.balance),
    }));
  },
};

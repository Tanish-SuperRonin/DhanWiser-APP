import dns from 'dns';
dns.setDefaultResultOrder('ipv4first');
import 'dotenv/config';
import app from './src/app.js';
import { pool } from './src/config/database.js';
import { reminderService } from './src/services/reminderService.js';

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', async () => {
  console.log(`
+---------------------------------------+
|     DhanWiser API Server              |
|  Port: ${PORT}
|  Environment: ${process.env.NODE_ENV}
+---------------------------------------+
  `);

  try {
    const res = await pool.query('SELECT NOW()');
    console.log('Database connected at:', res.rows[0].now);
    await pool.query(
      'ALTER TABLE settlements ADD COLUMN IF NOT EXISTS proof_image TEXT'
    );
    console.log('Settlement proof column ready');
    await pool.query(
      'ALTER TABLE servers ADD COLUMN IF NOT EXISTS reminder_enabled BOOLEAN DEFAULT true'
    );
    await pool.query(
      'ALTER TABLE servers ADD COLUMN IF NOT EXISTS reminder_interval_days INTEGER DEFAULT 7'
    );
    console.log('Reminder settings columns ready');
    await reminderService.processAutomaticReminders();

    setInterval(async () => {
      try {
        await reminderService.processAutomaticReminders();
      } catch (error) {
        console.error('Automatic reminder job failed:', error.message);
      }
    }, 60 * 60 * 1000);
  } catch (err) {
    console.error('Database connection failed:', err.message);
    process.exit(1);
  }
});

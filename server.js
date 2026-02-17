import 'dotenv/config';
import app from './src/app.js';
import { pool } from './src/config/database.js';
import { initializeDatabase } from './src/config/initDb.js';

const PORT = process.env.PORT || 5000;

// Start server first, then connect to database
app.listen(PORT, '0.0.0.0', async () => {
  console.log(`
╔═══════════════════════════════════════╗
║     🚀 DhanWiser API Server          ║
╠═══════════════════════════════════════╣
║  Port: ${PORT}                        
║  Environment: ${process.env.NODE_ENV}
║  Health: http://localhost:${PORT}/health
╚═══════════════════════════════════════╝
  `);

  // Test database connection
  try {
    const res = await pool.query('SELECT NOW()');
    console.log('✅ Database connected at:', res.rows[0].now);

    // Initialize database tables (safe - uses CREATE TABLE IF NOT EXISTS)
    await initializeDatabase();
  } catch (err) {
    console.error('❌ Database connection failed:', err.message);
    process.exit(1);
  }
});
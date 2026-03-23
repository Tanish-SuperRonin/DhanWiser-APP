import 'dotenv/config';
import app from './src/app.js';
import { pool } from './src/config/database.js';

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', async () => {
  console.log(`
╔═══════════════════════════════════════╗
║     🚀 DhanWiser API Server          ║
╠═══════════════════════════════════════╣
║  Port: ${PORT}                        
║  Environment: ${process.env.NODE_ENV}
╚═══════════════════════════════════════╝
  `);

  try {
    const res = await pool.query('SELECT NOW()');
    console.log('✅ Database connected at:', res.rows[0].now);
  } catch (err) {
    console.error('❌ Database connection failed:', err.message);
    process.exit(1);
  }
});
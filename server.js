import 'dotenv/config';
import app from './src/app.js';
import { pool } from './src/config/database.js';


const PORT = process.env.PORT || 5000;

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Database connection failed:', err);
    process.exit(1);
  } else {
    console.log('✅ Database connected at:', res.rows[0].now);
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════╗
║     🚀 DhanWiser API Server          ║
╠═══════════════════════════════════════╣
║  Port: ${PORT}                        
║  Environment: ${process.env.NODE_ENV}
║  Health: http://localhost:${PORT}/health
╚═══════════════════════════════════════╝
  `);
});
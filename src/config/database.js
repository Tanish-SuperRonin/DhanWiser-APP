import { Pool } from 'pg';

if (!process.env.DATABASE_URL) {
  throw new Error('❌ DATABASE_URL is required');
}

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }, // required for Supabase
  family: 4, // ✅ FORCE IPv4 (this fixes your error)
});

pool.on('connect', () => {
  console.log('Database connected successfully');
});

pool.on('error', (err) => {
  console.error('Database connection error:', err);
});
import { Pool, types } from 'pg';

// Postgres BIGINT/BIGSERIAL values are returned as strings by default.
// The app expects numeric IDs, so normalize them at the DB boundary.
types.setTypeParser(20, (value) => parseInt(value, 10));

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

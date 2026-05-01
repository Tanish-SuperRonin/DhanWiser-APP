import { Pool } from 'pg';

const useConnectionString = Boolean(process.env.DATABASE_URL);
const shouldUseSsl =
  process.env.DB_SSL === 'true' || process.env.DB_SSL === '1';

export const pool = new Pool(
  useConnectionString
      ? {
          connectionString: process.env.DATABASE_URL,
          ssl: shouldUseSsl ? { rejectUnauthorized: false } : undefined,
        }
      : {
          host: process.env.DB_HOST,
          port: Number(process.env.DB_PORT),
          database: process.env.DB_NAME,
          user: process.env.DB_USER,
          password: process.env.DB_PASSWORD,
          ssl: shouldUseSsl ? { rejectUnauthorized: false } : undefined,
        }
    );

pool.on('connect', () => {
  console.log('Database connected successfully');
});

pool.on('error', (err) => {
  console.error('Database connection error:', err);
});

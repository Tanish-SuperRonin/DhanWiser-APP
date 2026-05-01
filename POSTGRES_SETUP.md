# DhanWiser PostgreSQL Database Setup Guide

## Step 1: Install PostgreSQL

### Windows
1. Download from [postgresql.org](https://www.postgresql.org/download/windows/)
2. Run installer and follow wizard
3. Choose a password for `postgres` user (save this!)
4. Keep default port (5432)

### macOS
```bash
brew install postgresql@15
brew services start postgresql@15
```

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

## Step 2: Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database for DhanWiser
CREATE DATABASE dhanwiser;

# Connect to the new database
\c dhanwiser

# Verify connection
\dt  -- lists tables (should be empty)
```

Or using command line directly:
```bash
createdb -U postgres dhanwiser
```

## Step 3: Load Schema

### Option A: Using psql (Recommended)

```bash
# Navigate to project directory
cd c:\Users\shahm\Downloads\DhanWiser-APP-git

# Import schema
psql -U postgres -d dhanwiser -f supabase_schema.sql
```

### Option B: Using pgAdmin (GUI)

1. Open pgAdmin
2. Right-click on "Databases" → "Create" → "Database"
3. Name it `dhanwiser`
4. Click "Tools" → "Query Tool"
5. Open `supabase_schema.sql`
6. Execute the SQL

### Option C: Manual Paste

```bash
# Connect to database
psql -U postgres -d dhanwiser

# Paste contents of supabase_schema.sql and execute
```

## Step 4: Verify Schema Creation

```bash
# Connect to your database
psql -U postgres -d dhanwiser

# List all tables
\dt

# You should see:
# - audit_logs
# - channels
# - expense_participants
# - expenses
# - notifications
# - server_members
# - servers
# - settlements
# - users

# List functions
\df

# List views
\dv

# Exit psql
\q
```

## Step 5: Update Backend Configuration

Update your `.env` file:

```env
# Database Configuration
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/dhanwiser
DB_HOST=localhost
DB_PORT=5432
DB_NAME=dhanwiser
DB_USER=postgres
DB_PASSWORD=your_password_here
DB_SSL=false

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_here_make_it_long_and_random
JWT_EXPIRY=7d

# Server Configuration
PORT=3000
NODE_ENV=development
```

## Step 6: Test Database Connection

Create a test file `test-connection.js`:

```javascript
import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false  // Set to true for remote databases
});

pool.query('SELECT NOW()', (err, result) => {
  if (err) {
    console.error('Connection failed:', err);
  } else {
    console.log('✓ Database connected successfully!');
    console.log('Current time:', result.rows[0]);
  }
  pool.end();
});
```

Run it:
```bash
node test-connection.js
```

## Step 7: Install Backend Dependencies

```bash
npm install
npm run dev
```

Check logs for "Database connected" message.

## Step 8: Create Test Data (Optional)

```bash
psql -U postgres -d dhanwiser

-- Insert test user
INSERT INTO users (username, email, password_hash, full_name, upi_id)
VALUES ('testuser', 'test@example.com', 'hashed_password_here', 'Test User', 'test@upi');

-- Verify insert
SELECT * FROM users;

-- Exit
\q
```

## Useful PostgreSQL Commands

```bash
# Connect to database
psql -U postgres -d dhanwiser

# List databases
\l

# List tables in current database
\dt

# Describe table structure
\d users

# Show indexes
\di

# Show views
\dv

# Show functions
\df

# Show triggers
SELECT * FROM information_schema.triggers;

# Run SQL file
\i /path/to/file.sql

# Export database
pg_dump -U postgres dhanwiser > backup.sql

# Restore database
psql -U postgres -d dhanwiser < backup.sql

# Drop database
DROP DATABASE dhanwiser;

# Exit psql
\q
```

## Troubleshooting

### ❌ "role 'postgres' does not exist"
**Solution**: Create the role first
```bash
createuser -U postgres postgres
```

### ❌ "permission denied" error
**Solution**: On Linux, use sudo
```bash
sudo -u postgres psql -d dhanwiser -f supabase_schema.sql
```

### ❌ "Database does not exist"
**Solution**: Create database first
```bash
createdb -U postgres dhanwiser
```

### ❌ Connection timeout
**Solution**: Check if PostgreSQL is running
```bash
# Windows
Get-Service PostgreSQL*

# Linux
sudo systemctl status postgresql

# macOS
brew services list
```

### ❌ "cannot connect to server"
**Solution**: Verify connection details in `.env`
- Host should be `localhost` (not `127.0.0.1` for pgAdmin)
- Port should be `5432`
- Database name should be correct

### ❌ "column does not exist" when running queries
**Solution**: Verify schema was imported completely
```bash
psql -U postgres -d dhanwiser -c "SELECT COUNT(*) FROM users;"
```

## Backup & Restore

### Backup Database
```bash
# Backup to SQL file
pg_dump -U postgres dhanwiser > backup_2024.sql

# Backup to custom format (more efficient)
pg_dump -U postgres -F c dhanwiser > backup_2024.dump
```

### Restore Database
```bash
# From SQL file
psql -U postgres -d dhanwiser < backup_2024.sql

# From custom format
pg_restore -U postgres -d dhanwiser backup_2024.dump
```

## Performance Tips

### Create Indexes for Frequent Queries
Indexes are already created in the schema, but you can add more:

```sql
-- Example: Index for settlement queries
CREATE INDEX idx_settlements_payer_receiver 
ON settlements(payer_id, receiver_id, status);
```

### Check Index Usage
```sql
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Analyze Query Performance
```sql
EXPLAIN ANALYZE
SELECT * FROM expenses 
WHERE created_by = 1 
ORDER BY expense_date DESC 
LIMIT 10;
```

## Authentication Note

The schema includes comments about RLS (Row Level Security) policies. These are commented out because standard PostgreSQL doesn't have an `auth` schema. 

If you want to implement authorization:
- **Option 1**: Implement JWT validation in your Node.js backend
- **Option 2**: Use Supabase (which includes built-in auth)
- **Option 3**: Use a PostgRES extension for authentication

The recommended approach is **Option 1** (JWT in backend).

## Next Steps

1. ✅ Import schema using `supabase_schema.sql`
2. ✅ Update `.env` with database credentials
3. ✅ Test backend connection
4. ✅ Create sample data
5. ✅ Deploy to production (with proper backups)

## Production Deployment Checklist

- [ ] Enable SSL connections
- [ ] Set up automated backups
- [ ] Configure connection pooling
- [ ] Monitor database performance
- [ ] Set up replication (optional)
- [ ] Enable query logging
- [ ] Configure firewall rules
- [ ] Use strong passwords
- [ ] Restrict user permissions

---

**Resources**:
- [PostgreSQL Official Docs](https://www.postgresql.org/docs/)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
- [Node.js pg Documentation](https://node-postgres.com/)

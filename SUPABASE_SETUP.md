# DhanWiser Supabase Database Setup Guide

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Fill in project details:
   - **Project Name**: DhanWiser
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose closest to your users (e.g., `ap-south-1` for India)
4. Click "Create new project" and wait for it to initialize (5-10 minutes)

## Step 2: Get Connection Details

Once your project is ready:

1. Go to **Settings** → **Database**
2. Copy your connection details:
   - **Host**: `[project-ref].supabase.co`
   - **Port**: `5432`
   - **Database**: `postgres`
   - **User**: `postgres`
   - **Password**: The password you created

3. Get your **API Keys** from **Settings** → **API**:
   - **Project URL**: Your Supabase URL
   - **anon key**: Public key for client
   - **service_role key**: Secret key for backend

## Step 3: Update Your .env File

Create or update your `.env` file in the root directory with these variables:

```env
# Supabase Configuration
SUPABASE_URL=https://[project-ref].supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# Database Configuration
DATABASE_URL=postgresql://postgres:[password]@[project-ref].supabase.co:5432/postgres
DB_HOST=[project-ref].supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=your_database_password

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_here_make_it_long_and_random

# Server Configuration
PORT=3000
NODE_ENV=development
```

## Step 4: Create the Database Schema

### Option A: Using Supabase Dashboard (Easiest)

1. Go to your Supabase project dashboard
2. Click **SQL Editor** on the left sidebar
3. Click **+ New Query**
4. Copy the entire contents of `supabase_schema.sql`
5. Paste it into the SQL editor
6. Click **Run** (or press `Ctrl+Enter`)
7. Wait for all queries to execute successfully ✓

### Option B: Using Command Line

If you have the Supabase CLI installed:

```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Login to Supabase
supabase login

# Push the schema
supabase db push

# Or manually run the SQL file
psql "postgresql://postgres:password@host:5432/postgres" -f supabase_schema.sql
```

### Option C: Using pgAdmin or psql

```bash
# Connect to your database
psql "postgresql://postgres:[password]@[project-ref].supabase.co:5432/postgres"

# Then paste the contents of supabase_schema.sql and run
```

## Step 5: Verify Schema Creation

After running the SQL, verify everything was created:

1. Go to **Table Editor** in Supabase dashboard
2. You should see these tables:
   - ✓ `users`
   - ✓ `servers`
   - ✓ `server_members`
   - ✓ `channels`
   - ✓ `expenses`
   - ✓ `expense_participants`
   - ✓ `settlements`
   - ✓ `notifications`
   - ✓ `audit_logs`

3. Check that indexes and views are created:
   - Go to **SQL Editor** → **Saved Queries** (they should show in functions/views)

## Step 6: Update Backend Connection

Update your backend database configuration file (likely `src/config/database.js`):

```javascript
import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false // Required for Supabase
  }
});

// Test connection
pool.query('SELECT NOW()', (err, result) => {
  if (err) {
    console.error('Database connection failed:', err);
  } else {
    console.log('Database connected successfully:', result.rows[0]);
  }
});

export default pool;
```

## Step 7: Update Flutter App (if using Supabase client library)

Install Supabase Flutter package:

```bash
flutter pub add supabase
```

Update your auth/services to use Supabase client:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://[project-ref].supabase.co';
const supabaseAnonKey = 'your_anon_key_here';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}
```

## Step 8: Database Backups

Enable automatic backups in Supabase:

1. Go to **Settings** → **Backups**
2. Enable **Automatic Backups**
3. Choose backup frequency (daily/weekly recommended)

## Table Relationships Overview

```
users (1) ──── (N) servers (as creator)
  │                  │
  │                  ├──── (N) server_members
  │                  ├──── (N) channels
  │                  ├──── (N) settlements
  │                  └──── (N) expenses
  │
  ├──── (N) server_members
  ├──── (N) expense_participants
  ├──── (N) settlements
  └──── (N) notifications

channels (1) ──── (N) expenses
  │
  └──── (N) expense_participants

expenses (1) ──── (N) expense_participants
```

## Key Features of This Schema

✅ **Automatic Timestamps**: `created_at` and `updated_at` automatically managed
✅ **Constraints**: Data validation (amounts > 0, unique emails, etc.)
✅ **Indexes**: Performance optimization for common queries
✅ **Views**: Pre-calculated user balances by server
✅ **Functions**: Automatic trigger updates
✅ **RLS**: Row-level security policies (optional)
✅ **Referential Integrity**: Foreign keys with CASCADE delete

## Common Issues & Solutions

### ❌ Connection Refused Error
**Solution**: Check your firewall settings and ensure SSL is configured correctly

### ❌ Database Doesn't Appear in Table Editor
**Solution**: Refresh the page or disconnect/reconnect to Supabase

### ❌ Foreign Key Constraint Error
**Solution**: Ensure you're inserting data in correct order (parent tables first)

### ❌ JWT Authentication Issues
**Solution**: Update your JWT secret in `.env` and restart the server

## Next Steps

1. ✅ Create test data to verify schema works
2. ✅ Update backend connection strings
3. ✅ Run your application against the new database
4. ✅ Set up monitoring and backups
5. ✅ Configure Row-Level Security policies as needed

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Supabase CLI Guide](https://supabase.com/docs/guides/cli)
- [Row-Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

---

**Need Help?** Check Supabase Discord community or GitHub issues.

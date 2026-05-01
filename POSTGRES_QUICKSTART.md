# 🚀 DhanWiser PostgreSQL Quick Start

This guide will get you up and running with PostgreSQL in less than 10 minutes.

## Prerequisites

- **PostgreSQL 12+** installed on your machine
- **Node.js 16+** installed
- **npm** or **yarn** package manager

## ⚡ Quick Setup (5 minutes)

### 1. Create Database

```bash
# Open PostgreSQL prompt
psql -U postgres

# Create database
CREATE DATABASE dhanwiser;

# Exit
\q
```

### 2. Import Schema

```bash
# From your project root directory
psql -U postgres -d dhanwiser -f supabase_schema.sql
```

### 3. Configure Backend

```bash
# Copy environment template
copy .env.example .env

# Edit .env with your database password
# DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/dhanwiser
```

### 4. Start Backend

```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

You should see: ✓ **Database connected successfully**

## 📝 Detailed Steps

### Step 1: Install PostgreSQL

**Windows:**
- Download: https://www.postgresql.org/download/windows/
- Run installer, remember the postgres password
- Add PostgreSQL to PATH (installer does this)

**macOS:**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Linux (Ubuntu):**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### Step 2: Verify Installation

```bash
# Check PostgreSQL version
psql --version

# Should output: psql (PostgreSQL) 12.0 (or higher)
```

### Step 3: Create Database & Load Schema

**Option A: Command Line (Fastest)**
```bash
# Create database
createdb -U postgres dhanwiser

# Import schema
psql -U postgres -d dhanwiser -f supabase_schema.sql
```

**Option B: Interactive (pgAdmin GUI)**
1. Open pgAdmin
2. Right-click Databases → Create → Database
3. Name: `dhanwiser`
4. Tools → Query Tool
5. Open file: `supabase_schema.sql`
6. Click Execute

### Step 4: Verify Schema

```bash
# Connect to database
psql -U postgres -d dhanwiser

# List tables (should show 9 tables)
\dt

# Expected output:
#  user_balances_by_server

# List views
\dv

# Exit
\q
```

### Step 5: Update Environment

Create `.env` file in project root:

```env
# Database
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/dhanwiser
DB_HOST=localhost
DB_PORT=5432
DB_NAME=dhanwiser
DB_USER=postgres
DB_PASSWORD=your_password_here
DB_SSL=false

# Server
PORT=3000
NODE_ENV=development

# JWT (Generate a random secret)
JWT_SECRET=generate_random_string_here_at_least_32_chars
JWT_EXPIRY=7d
```

### Step 6: Install & Run

```bash
# Navigate to project
cd DhanWiser-APP-git

# Install dependencies
npm install

# Start backend
npm run dev
```

**Expected output:**
```
✓ Database connected successfully
Server running on port 3000
```

## ✅ Verify Everything Works

### Test 1: Database Connection

```bash
psql -U postgres -d dhanwiser -c "SELECT COUNT(*) FROM users;"
```

Should output: `(0 rows)`

### Test 2: Backend Connection

```bash
# Terminal 1: Start backend
npm run dev

# Terminal 2: Test API
curl http://localhost:3000/api/v1/health

# Should return: {"status": "ok"}
```

### Test 3: Create Test Data

```bash
psql -U postgres -d dhanwiser
```

Then run:
```sql
-- Create test user
INSERT INTO users (username, email, password_hash, full_name)
VALUES ('testuser', 'test@example.com', 'hashed_pass', 'Test User');

-- Verify
SELECT * FROM users;

-- Exit
\q
```

## 🐛 Troubleshooting

### Error: "database does not exist"
```bash
# Create it first
createdb -U postgres dhanwiser
```

### Error: "role 'postgres' does not exist"
```bash
# Check available roles
psql -l

# Or use different user
psql -U postgres_username
```

### Error: Connection refused on port 5432
```bash
# Check if PostgreSQL is running
# Windows: Services → PostgreSQL
# macOS: brew services list
# Linux: sudo systemctl status postgresql
```

### Can't connect after setup
```bash
# Verify connection details
echo $DATABASE_URL

# Test connection
psql postgresql://postgres:password@localhost:5432/dhanwiser
```

## 📊 Common Tasks

### Backup Database
```bash
pg_dump -U postgres dhanwiser > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
psql -U postgres -d dhanwiser < backup_20240501.sql
```

### Delete Database
```bash
dropdb -U postgres dhanwiser
```

### View All Databases
```bash
psql -U postgres -l
```

### Check Table Sizes
```bash
psql -U postgres -d dhanwiser -c "
  SELECT tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) 
  FROM pg_tables 
  WHERE schemaname = 'public';
"
```

## 🔐 Security Notes

- **Never** commit `.env` to git
- **Always** use strong passwords
- **Change** `postgres` password in production
- **Restrict** database access via firewall
- **Enable** SSL for remote connections
- **Backup** regularly and test restores

## 📚 Documentation Files

- **`supabase_schema.sql`** - Database schema (run once)
- **`POSTGRES_SETUP.md`** - Detailed PostgreSQL setup
- **`MIGRATION_CHECKLIST.md`** - Full migration checklist
- **`USEFUL_QUERIES.sql`** - Common SQL queries
- **`.env.example`** - Environment template

## 🎯 Next Steps

1. ✅ Set up PostgreSQL database
2. ✅ Import schema
3. ✅ Configure backend
4. ✅ Run backend server
5. ✅ Test database queries
6. ✅ Connect Flutter app
7. ✅ Start development!

## 💡 Tips

- Use `psql -U postgres -d dhanwiser` for quick database access
- Use `npm run dev` for development with auto-reload
- Check `USEFUL_QUERIES.sql` for backend query examples
- Review `POSTGRES_SETUP.md` for advanced configuration

## 🆘 Need Help?

1. Check the error message carefully
2. Review **Troubleshooting** section above
3. Read `POSTGRES_SETUP.md` for detailed docs
4. Check PostgreSQL logs: `var/log/postgresql/`

---

**Ready?** Run: `npm run dev` and start building! 🎉

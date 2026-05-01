# DhanWiser PostgreSQL Migration Checklist

## Pre-Migration Preparation

- [ ] **Backup Current Database**
  - Export current database to SQL file: `pg_dump -U postgres olddb > backup.sql`
  - Save backup file in secure location
  - Document current database size and row counts

- [ ] **Document Current Schema**
  - List all tables currently in use
  - Document all relationships and constraints
  - Export data for verification

- [ ] **Test Environment Setup**
  - Create test PostgreSQL database: `createdb -U postgres dhanwiser_test`
  - Apply schema to test environment
  - Run full test suite against test database

## PostgreSQL Setup

- [ ] **Install PostgreSQL**
  - Windows: Download from postgresql.org
  - macOS: `brew install postgresql@15`
  - Linux: `sudo apt install postgresql postgresql-contrib`
  - Note: Save postgres user password

- [ ] **Create Production Database**
  - Create database: `createdb -U postgres dhanwiser`
  - Note connection details:
    - Host: `localhost` (or your server IP)
    - Port: `5432`
    - Database: `dhanwiser`
    - User: `postgres`
    - Password: Your chosen password

- [ ] **Generate Security Credentials**
  - Create strong database password
  - Generate JWT_SECRET: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`
  - Store in `.env` file securely

## Database Schema Migration

- [ ] **Run SQL Schema**
  - Open terminal/command prompt
  - Navigate to project directory
  - Run: `psql -U postgres -d dhanwiser -f supabase_schema.sql`
  - Or connect to psql and paste contents manually
  - Wait for all queries to execute successfully
  - Verify no error messages

- [ ] **Verify Schema**
  - [ ] Connect to database: `psql -U postgres -d dhanwiser`
  - [ ] List tables: `\dt` - should show 9 tables
  - [ ] Verify users table: `\d users`
  - [ ] Check indexes: `\di`
  - [ ] Verify views: `\dv` - should show `user_balances_by_server`
  - [ ] Check triggers: Query `information_schema.triggers`
  - [ ] Exit: `\q`

- [ ] **Test Constraints**
  - Try inserting invalid data (should fail)
  - Test unique constraints on username, email
  - Test foreign key constraints
  - Verify cascade deletes work correctly

## Backend Configuration

- [ ] **Update .env File**
  ```env
  DATABASE_URL=postgresql://postgres:your_password@localhost:5432/dhanwiser
  DB_HOST=localhost
  DB_PORT=5432
  DB_NAME=dhanwiser
  DB_USER=postgres
  DB_PASSWORD=your_password_here
  DB_SSL=false
  
  JWT_SECRET=generated_random_key_here
  JWT_EXPIRY=7d
  
  PORT=3000
  NODE_ENV=development
  ```

- [ ] **Install Dependencies**
  ```bash
  npm install
  ```

- [ ] **Test Database Connection**
  - Start backend: `npm run dev`
  - Check logs for "Database connected successfully"
  - No connection errors should appear
  - Backend should be listening on PORT 3000

- [ ] **Test Connectivity**
  - Try running a simple query from backend
  - Verify data can be read and written
  - Check for any constraint violations

## Data Migration (If Transferring Existing Data)

- [ ] **Export Old Data**
  - Export user data
  - Export server data
  - Export all related records
  - Verify export is complete

- [ ] **Prepare Migration Script**
  - Create data transformation scripts if needed
  - Handle any schema differences
  - Test with small dataset first

- [ ] **Migrate Data**
  - Start with `users` table
  - Then `servers` and `server_members`
  - Then `channels`
  - Then `expenses` and `expense_participants`
  - Finally `settlements` and `notifications`
  - Verify record counts match original

- [ ] **Verify Data Integrity**
  - Check all foreign keys are valid
  - Spot-check random records
  - Verify calculations (balances, totals)
  - Check for orphaned records

## Environment Configuration

- [ ] **Update .env Variables**
  ```env
  # PostgreSQL connection
  DATABASE_URL=postgresql://postgres:password@localhost:5432/dhanwiser
  DB_HOST=localhost
  DB_PORT=5432
  DB_NAME=dhanwiser
  DB_USER=postgres
  DB_PASSWORD=your_password_here
  DB_SSL=false
  
  # Server config
  PORT=3000
  NODE_ENV=production
  
  # JWT
  JWT_SECRET=your_random_secret_key
  JWT_EXPIRY=7d
  
  # CORS
  CORS_ORIGIN=http://localhost:3000
  ```

- [ ] **Update CORS Settings**
  - Update allowed origins if needed
  - Test cross-origin requests from Flutter app

- [ ] **SSL Configuration**
  - For local development: `DB_SSL=false`
  - For production: Set `DB_SSL=true` and provide SSL certificates

## API Testing

- [ ] **Test Authentication**
  - [ ] User registration works
  - [ ] User login works
  - [ ] JWT tokens generated correctly
  - [ ] Refresh token works

- [ ] **Test User Operations**
  - [ ] Get user profile
  - [ ] Update user profile
  - [ ] Upload profile picture
  - [ ] Verify unique username/email

- [ ] **Test Server Operations**
  - [ ] Create server
  - [ ] Add members to server
  - [ ] Create channel in server
  - [ ] Delete server (cascade delete works)

- [ ] **Test Expense Operations**
  - [ ] Create expense
  - [ ] Add expense participants
  - [ ] Update expense
  - [ ] Delete expense

- [ ] **Test Settlement Operations**
  - [ ] Create settlement
  - [ ] Update settlement status
  - [ ] Verify calculations

- [ ] **Test Notifications**
  - [ ] Create notification
  - [ ] Mark as read
  - [ ] Retrieve user notifications

## Flutter App Updates

- [ ] **Update Backend URL**
  - Update API base URL to your backend server
  - For local testing: `http://localhost:3000/api/v1`
  - For production: Your domain/server URL
  - Test API connections work correctly
  - Verify all endpoints work

- [ ] **Test Authentication Flow**
  - Login with existing user
  - Create new account
  - Verify JWT tokens work
  - Test token refresh

- [ ] **Test Data Operations**
  - Load expenses
  - Create new expense
  - View settlements
  - Send notifications

- [ ] **Build & Test APK**
  ```bash
  flutter build apk
  flutter build ios
  ```

## Production Deployment

- [ ] **Set Node Environment**
  - Set `NODE_ENV=production` in `.env`

- [ ] **Production Database Settings**
  - Update connection to production PostgreSQL server
  - Set up automated backups: `pg_dump -U postgres dhanwiser > backup_$(date +%Y%m%d).sql`
  - Enable connection pooling (e.g., pgBouncer)
  - Set `DB_SSL=true` for remote connections
  - Configure firewall to restrict database access

- [ ] **Security**
  - Update JWT_SECRET to production value
  - Update all API keys and secrets
  - Enable HTTPS for backend API
  - Set CORS to production domains only
  - Enable rate limiting
  - Disable verbose logging

- [ ] **Monitoring & Backups**
  - Set up automated daily backups
  - Test backup restoration procedure
  - Set up error logging/monitoring
  - Monitor database performance
  - Configure alerts for disk space

- [ ] **Final Testing**
  - Run full regression test suite
  - Test with production-like data volume
  - Test performance and response times
  - Verify all integrations work
  - Load test the backend

- [ ] **Deployment**
  - Deploy backend to production server
  - Deploy mobile app to app stores
  - Monitor error logs for first 24 hours
  - Get user feedback
  - Be ready for quick rollback if needed

## Post-Migration

- [ ] **Monitoring**
  - Check database performance metrics: `SELECT * FROM pg_stat_statements;`
  - Monitor API response times
  - Review error logs daily
  - Set up alerts for slow queries
  - Monitor disk space usage

- [ ] **Cleanup**
  - Archive old database backup
  - Update documentation
  - Remove old database configuration
  - Delete test databases if not needed
  - Notify stakeholders of successful migration

- [ ] **Documentation**
  - Update README with PostgreSQL setup info
  - Document new connection process
  - Create runbooks for common tasks
  - Document backup/restore procedures
  - Document monitoring setup

## Rollback Plan (If Needed)

- [ ] **Keep Old Database Accessible**
  - Don't delete old database immediately
  - Keep backups for at least 30 days
  - Document rollback procedure: `psql -U postgres -d dhanwiser < backup.sql`

- [ ] **Rollback Steps**
  1. Update `DATABASE_URL` to old database connection
  2. Restart backend services
  3. Roll back app version if needed
  4. Notify users of incident
  5. Restore from backup if data was corrupted

## Verification Checklist

After everything is live:

- [ ] All users can log in
- [ ] Create expense works
- [ ] Settlements work correctly
- [ ] Notifications are sent
- [ ] Performance is acceptable
- [ ] No error logs
- [ ] Mobile app connects successfully
- [ ] Data is correctly displayed

## Important Notes

- **Never** share database password
- **Never** commit `.env` file to version control
- Always use parameterized queries to prevent SQL injection
- Keep database backups in secure location
- Test all changes in development environment first
- Have backup plan ready before migration
- Document any custom code or modifications
- Keep PostgreSQL and dependencies updated
- Use strong passwords for database user
- Restrict network access to database (firewall)

---

**Timeline Estimate**: 2-4 hours depending on data volume and complexity

**Support**: Check Supabase docs or raise GitHub issue if stuck

# Connect Render Backend to Supabase - Step by Step

## Step 1: Get Supabase Connection Details

1. Go to your **Supabase Dashboard**
2. Click **Settings** (bottom left) → **Database**
3. Find the connection string section
4. Copy these details:

**Connection String (most important):**
```
postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres
```

Or scroll down to find:
- **Host**: `[something].supabase.co`
- **Port**: `5432`
- **Database**: `postgres`
- **User**: `postgres`
- **Password**: (the one you set when creating Supabase project)

⚠️ **IMPORTANT**: Save all these details - you'll need them on Render!

---

## Step 2: Configure Environment Variables on Render

### Via Render Dashboard:

1. Go to **[render.com](https://render.com)**
2. Click on your **Backend Service** (the Express.js app)
3. Go to **Settings** (top right)
4. Scroll down to **Environment**
5. Click **Edit Environment**

Add these variables:

```
DATABASE_URL=postgresql://postgres:[YOUR_PASSWORD]@[YOUR_HOST]:5432/postgres
DB_HOST=[YOUR_HOST]
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=[YOUR_PASSWORD]
DB_SSL=true
JWT_SECRET=generate_random_string_here
JWT_EXPIRY=7d
NODE_ENV=production
PORT=10000
```

**Replace:**
- `[YOUR_PASSWORD]` - Your Supabase database password
- `[YOUR_HOST]` - Your Supabase host (the `.supabase.co` part)

6. Click **Save Changes**
7. Render will **automatically redeploy** your app

---

## Step 3: Verify Database Connection String Format

Your connection string should look like:

```
postgresql://postgres:abc123xyz@abc123xyz.supabase.co:5432/postgres
```

**Anatomy:**
- `postgresql://` - database type
- `postgres` - username
- `abc123xyz` - password
- `abc123xyz.supabase.co` - host
- `5432` - port
- `postgres` - database name

---

## Step 4: Update Backend Configuration (if needed)

Check your `src/config/database.js` file looks like this:

```javascript
import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false  // Required for Supabase
  }
});

// Test connection
pool.query('SELECT NOW()', (err, result) => {
  if (err) {
    console.error('Database connection failed:', err);
  } else {
    console.log('✓ Database connected to Supabase');
  }
});

export default pool;
```

**Key things:**
- Uses `DATABASE_URL` from environment
- Has `ssl: { rejectUnauthorized: false }` (required for Supabase)

---

## Step 5: Verify Connection Works

### Option A: Check Render Logs

1. Go to your **Render Backend Service**
2. Click **Logs** (top right)
3. Look for this message:
   ```
   ✓ Database connected to Supabase
   ```

✅ If you see this → **Connection successful!**
❌ If you see an error → Check Step 6 below

### Option B: Test API Endpoint

Open your browser:
```
https://your-render-app.onrender.com/api/v1/health
```

Should return:
```json
{"status": "ok"}
```

---

## Step 6: Troubleshooting

### ❌ Error: "Connection refused"
**Check:**
- [ ] Password is correct
- [ ] Host includes `.supabase.co`
- [ ] `DB_SSL=true` is set
- [ ] Port is `5432`

### ❌ Error: "password authentication failed"
**Solution:** Your password might have special characters. Encode it properly.

If your password is: `abc@123#xyz`

Use: `postgresql://postgres:abc%40123%23xyz@host:5432/postgres`

Special characters to encode:
- `@` → `%40`
- `#` → `%23`
- `:` → `%3A`
- `/` → `%2F`
- `?` → `%3F`

### ❌ Error: "host not found"
**Check:**
- Host is spelled correctly
- It includes `.supabase.co`
- No extra spaces or characters

### ❌ Error: "no PostgreSQL user session" or "role doesn't exist"
**Check:**
- User is `postgres` (not your email)
- Database is `postgres` (not your project name)

---

## Step 7: Quick Connection Check Command

To test if you can connect from Render shell:

```bash
# SSH into Render
# Then run:
psql postgresql://postgres:YOUR_PASSWORD@YOUR_HOST:5432/postgres -c "SELECT NOW();"
```

If successful, you'll see the current timestamp ✅

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Can't connect from Render | Check if Supabase firewall allows `0.0.0.0/0` (all IPs) |
| SSL error | Make sure `DB_SSL=true` is set |
| Password errors | URL encode special characters using %XX format |
| `postgres` user doesn't exist | Use the default `postgres` user, not your email |
| Connection pool exhausted | Increase pool size in Render environment |

---

## Step 8: Production Best Practices

### On Render:
1. ✅ Set `NODE_ENV=production`
2. ✅ Use strong `JWT_SECRET`
3. ✅ Enable `DB_SSL=true`
4. ✅ Don't log sensitive data
5. ✅ Set up automatic deployments

### On Supabase:
1. ✅ Database backups enabled (automatic)
2. ✅ Firewalls configured (if needed)
3. ✅ Monitor database usage

---

## Complete .env for Render

Copy this template to Render Environment:

```env
# Supabase Database
DATABASE_URL=postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres
DB_HOST=[HOST]
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=[PASSWORD]
DB_SSL=true

# Server
PORT=10000
NODE_ENV=production

# JWT (generate random: https://randomkeygen.com/)
JWT_SECRET=your_random_secret_here_minimum_32_chars
JWT_EXPIRY=7d

# CORS (your Flutter app URL)
CORS_ORIGIN=https://your-app-domain.com
```

---

## Verify Setup is Complete

- [ ] Supabase database is created with tables
- [ ] Environment variables added to Render
- [ ] Backend code uses `DATABASE_URL`
- [ ] SSL is enabled (`DB_SSL=true`)
- [ ] Render app has redeployed
- [ ] Logs show "Database connected"
- [ ] API health check returns `{"status": "ok"}`

---

## Next Steps

1. ✅ Add environment variables to Render
2. ✅ Check Render logs for connection message
3. ✅ Test API endpoint in browser
4. ✅ Update Flutter app to use Render backend URL
5. ✅ Deploy Flutter app

---

## Support

If you still have issues:

1. Check Render logs: `Logs` button on service page
2. Verify Supabase connection string format
3. Check special characters are URL encoded
4. Make sure password doesn't have unencoded `@` or `#`
5. Verify Supabase project is running (check Supabase dashboard)

---

**Everything set up?** Your backend on Render is now connected to your Supabase database! 🎉

# 30-Second Render + Supabase Setup

## What You Need from Supabase

Go to **Supabase Dashboard** → **Settings** → **Database**

Copy your connection string. It looks like:
```
postgresql://postgres:YOUR_PASSWORD@xxxx.supabase.co:5432/postgres
```

---

## Add to Render (2 minutes)

1. Open your **Render Service**
2. Go **Settings** → **Environment**
3. Click **Edit Environment**
4. Add this ONE variable:

```
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@xxxx.supabase.co:5432/postgres
```

Replace `YOUR_PASSWORD` and `xxxx.supabase.co` with your actual values.

5. Also add:
```
DB_SSL=true
NODE_ENV=production
JWT_SECRET=abc123def456ghi789jkl012mno345pqr
```

6. Click **Save** → Render auto-deploys

---

## Verify It Works

### Check Logs:
1. Go to your **Render Service**
2. Click **Logs** tab
3. Look for: `✓ Database connected`

✅ **Success!** Your backend is connected to Supabase.

---

## If Logs Show Error:

**Copy the error message** and check this table:

| Error | Fix |
|-------|-----|
| "password authentication failed" | Check password is correct in connection string |
| "host not found" | Check host includes `.supabase.co` |
| "no route to host" | Set `DB_SSL=true` in environment |
| "role 'postgres' does not exist" | Use `postgres` user (not your email) |

---

## That's It! 

Your backend on Render is now talking to your Supabase database. 🚀

Next: Update your Flutter app to use your Render backend URL.

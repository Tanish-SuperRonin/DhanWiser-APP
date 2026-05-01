# Finding Your Supabase Connection Details

## Step 1: Open Supabase Dashboard

1. Go to [supabase.com](https://supabase.com)
2. Log in to your account
3. Click on your **DhanWiser** project

---

## Step 2: Get Connection String

**Location:** Bottom left corner → **Settings** → **Database**

You should see a section that says:

```
Connection string
Pick a connection method
```

### Option A: URI (Recommended for Render)

Look for something that says **URI** and copy the full string:

```
postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres
```

---

## Step 3: Understanding Your Connection String

Your string will look like:

```
postgresql://postgres:my_password_123@abcdef123.supabase.co:5432/postgres
                      ↑               ↑                    ↑    ↑
                      |               |                    |    |
                    username       password              host  port
```

**Breaking it down:**
- `postgresql://` → Database type
- `postgres` → Username (always this)
- `my_password_123` → Your Supabase database password
- `abcdef123.supabase.co` → Your Supabase host
- `5432` → Default PostgreSQL port
- `postgres` → Database name

---

## Step 4: Use on Render

Copy the ENTIRE connection string and add to Render:

**On Render Settings → Environment:**
```
DATABASE_URL=postgresql://postgres:my_password_123@abcdef123.supabase.co:5432/postgres
```

---

## If String Has Special Characters

**Example:** Password is `abc@123#xyz`

Your connection string looks like:
```
postgresql://postgres:abc@123#xyz@abcdef123.supabase.co:5432/postgres
```

❌ This will BREAK because `@` and `#` confuse the parser.

**Solution:** URL-encode the password:
- `@` becomes `%40`
- `#` becomes `%23`
- `:` becomes `%3A`

**Corrected:**
```
postgresql://postgres:abc%40123%23xyz@abcdef123.supabase.co:5432/postgres
```

**URL Encoding Chart:**
```
@  → %40
#  → %23
:  → %3A
/  → %2F
?  → %3F
&  → %26
=  → %3D
%  → %25
```

---

## Step 5: Verify Connection String Format

Your connection string should:
- ✅ Start with `postgresql://`
- ✅ Have `postgres` as username
- ✅ Include your password
- ✅ Include `.supabase.co` domain
- ✅ Have `:5432` port
- ✅ End with `/postgres`

**Good example:**
```
postgresql://postgres:mypassword@project123.supabase.co:5432/postgres
```

**Bad examples:**
```
postgresql://user@gmail.com:password@host:5432/postgres  ❌ Wrong user
postgresql://postgres:password@supabase.co:5432/postgres  ❌ Missing project ID
postgresql://postgres:pass@word@host:5432/postgres        ❌ @ not encoded
```

---

## Need Help Finding It?

Still can't find your connection string? Do this:

1. **Supabase Dashboard** → Your Project
2. Look at **top of page** - should say: `Project: DhanWiser` (or your project name)
3. **Left sidebar** → Click **Settings** (gear icon)
4. **Settings menu** → Click **Database**
5. Scroll to **"Connection string"** section
6. Select **URI** option
7. **Copy** the entire text

---

## Quick Copy-Paste for Render

After copying from Supabase, go to:

**Render Dashboard → Your Backend Service → Settings → Environment**

Paste:
```
DATABASE_URL=PASTE_YOUR_CONNECTION_STRING_HERE
```

Plus add:
```
DB_SSL=true
NODE_ENV=production
```

Save and done! ✅

---

## Test Connection Works

After setting environment variables on Render:

1. Wait 2-3 minutes for redeploy
2. Go to **Logs** tab
3. Look for: `✓ Database connected`

If you see it → Everything works! 🎉

---

**Still stuck?** Check that:
- [ ] Connection string starts with `postgresql://`
- [ ] You copied the ENTIRE string (no spaces before/after)
- [ ] Special characters are URL-encoded if needed
- [ ] Host ends with `.supabase.co`
- [ ] Render has redeployed (check Logs tab)

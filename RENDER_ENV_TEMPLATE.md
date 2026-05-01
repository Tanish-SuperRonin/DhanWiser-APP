# Render Environment Variables Template

Copy and paste these into your **Render Settings → Environment**

---

## Minimum Required (must have)

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@YOUR_HOST.supabase.co:5432/postgres
DB_SSL=true
NODE_ENV=production
JWT_SECRET=generate_a_random_string_here_at_least_32_characters
PORT=10000
```

---

## Complete Configuration (recommended)

```env
# =====================================================
# DATABASE - Supabase
# =====================================================
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@YOUR_HOST.supabase.co:5432/postgres
DB_HOST=YOUR_HOST.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=YOUR_PASSWORD
DB_SSL=true

# =====================================================
# SERVER
# =====================================================
PORT=10000
NODE_ENV=production

# =====================================================
# JWT AUTHENTICATION
# =====================================================
# Generate random: https://randomkeygen.com/ or use: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
JWT_SECRET=your_random_secret_here_minimum_32_characters
JWT_EXPIRY=7d
JWT_REFRESH_SECRET=your_refresh_secret_minimum_32_characters
JWT_REFRESH_EXPIRE=30d

# =====================================================
# CORS - Allow your Flutter app
# =====================================================
CORS_ORIGIN=https://your-app-domain.com,http://localhost:3000

# =====================================================
# LOGGING
# =====================================================
LOG_LEVEL=info

# =====================================================
# API
# =====================================================
API_VERSION=v1
API_PREFIX=/api/v1
```

---

## How to Fill It In

### Find Your Supabase Details:

1. **Supabase Dashboard** → Your Project
2. **Settings** → **Database** (bottom left)
3. Copy the **URI** connection string:
   ```
   postgresql://postgres:PASSWORD@HOST.supabase.co:5432/postgres
   ```

### Extract from connection string:

If your string is:
```
postgresql://postgres:my_password_123@abc123def456.supabase.co:5432/postgres
```

Then:
- `YOUR_PASSWORD` = `my_password_123`
- `YOUR_HOST` = `abc123def456`

### Generate JWT_SECRET:

**Option 1:** Use this command (in your terminal):
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**Option 2:** Use online: https://randomkeygen.com/
- Copy the "SHA 1 Hashed Password" (or any random-looking string)

---

## Step-by-Step in Render

1. **Render Dashboard** → Click your **Backend Service**
2. **Settings** tab (top right)
3. Scroll down to **Environment** section
4. Click **Edit Environment**
5. Paste the variables above
6. Replace `YOUR_PASSWORD` and `YOUR_HOST` with actual values
7. Click **Save**
8. Render will redeploy automatically
9. Check **Logs** for "✓ Database connected" message

---

## Special Characters in Password?

If your Supabase password is: `abc@123#xyz`

### In DATABASE_URL, encode it:
```
DATABASE_URL=postgresql://postgres:abc%40123%23xyz@host:5432/postgres
```

### In DB_PASSWORD, use as-is:
```
DB_PASSWORD=abc@123#xyz
```

---

## Encoding Table

Use this if your password has these characters:

| Character | Code |
|-----------|------|
| `@` | `%40` |
| `#` | `%23` |
| `:` | `%3A` |
| `/` | `%2F` |
| `?` | `%3F` |
| `&` | `%26` |
| `=` | `%3D` |
| ` ` (space) | `%20` |

---

## Verification

After saving, check:
- [ ] All variables appear in "Environment" section
- [ ] No typos in values
- [ ] Render is redeploying (you'll see "Deploying..." status)
- [ ] After 2-3 minutes, status changes to "Live"
- [ ] Logs show "✓ Database connected"

---

## If Connection Fails

1. Check **Logs** for error message
2. Verify DATABASE_URL format:
   ```
   postgresql://postgres:password@host:5432/postgres
   ```
3. Make sure `DB_SSL=true` is set
4. Verify password doesn't have unencoded `@`
5. Check Supabase project is running

---

## Minimal Working Example

```env
DATABASE_URL=postgresql://postgres:secure_password_123@proj12345.supabase.co:5432/postgres
DB_SSL=true
NODE_ENV=production
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
PORT=10000
```

---

## For Development (Local Machine)

```env
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/dhanwiser
DB_HOST=localhost
DB_PORT=5432
DB_NAME=dhanwiser
DB_USER=postgres
DB_PASSWORD=your_password
DB_SSL=false
NODE_ENV=development
JWT_SECRET=dev_secret_key_any_random_string
PORT=3000
```

---

## Remember

- ✅ Use `DATABASE_URL` (easiest method)
- ✅ Set `DB_SSL=true` for Supabase
- ✅ Generate random `JWT_SECRET`
- ✅ Don't commit `.env` files to git
- ✅ Render redeploys automatically on save
- ✅ Check logs to verify connection

---

**All set?** Save these variables and check your logs! 🚀

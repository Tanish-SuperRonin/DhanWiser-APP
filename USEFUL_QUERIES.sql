-- DhanWiser Useful Supabase SQL Queries
-- These are common queries you might use in your backend

-- =====================================================
-- USER QUERIES
-- =====================================================

-- Get user by username with all info
SELECT * FROM users WHERE username = $1 AND is_active = true;

-- Get user profile without sensitive data
SELECT id, username, full_name, profile_picture_url, upi_id, created_at 
FROM users WHERE id = $1 AND is_active = true;

-- Search users by username or name
SELECT id, username, full_name, profile_picture_url
FROM users 
WHERE (username ILIKE $1 OR full_name ILIKE $1) AND is_active = true
LIMIT 10;

-- =====================================================
-- SERVER QUERIES
-- =====================================================

-- Get all servers for a user
SELECT s.id, s.name, s.description, s.is_locked, sm.role, sm.joined_at, s.created_at,
       COUNT(DISTINCT sm2.user_id) as member_count
FROM servers s
JOIN server_members sm ON s.id = sm.server_id
LEFT JOIN server_members sm2 ON s.id = sm2.server_id
WHERE sm.user_id = $1
GROUP BY s.id, sm.role, sm.joined_at
ORDER BY s.created_at DESC;

-- Get server details with members
SELECT s.id, s.name, s.description, s.is_locked, s.created_by,
       json_agg(json_build_object(
         'userId', sm.user_id,
         'username', u.username,
         'fullName', u.full_name,
         'role', sm.role,
         'joinedAt', sm.joined_at
       )) as members
FROM servers s
LEFT JOIN server_members sm ON s.id = sm.server_id
LEFT JOIN users u ON sm.user_id = u.id
WHERE s.id = $1
GROUP BY s.id;

-- Get all members of a server
SELECT sm.user_id, u.username, u.full_name, u.profile_picture_url, 
       u.upi_id, sm.role, sm.joined_at
FROM server_members sm
JOIN users u ON sm.user_id = u.id
WHERE sm.server_id = $1
ORDER BY sm.joined_at DESC;

-- =====================================================
-- CHANNEL QUERIES
-- =====================================================

-- Get all channels in a server
SELECT c.id, c.name, c.description, c.created_at,
       COUNT(DISTINCT e.id) as expense_count,
       COALESCE(SUM(e.total_amount), 0) as total_amount
FROM channels c
LEFT JOIN expenses e ON c.id = e.channel_id
WHERE c.server_id = $1
GROUP BY c.id
ORDER BY c.created_at DESC;

-- =====================================================
-- EXPENSE QUERIES
-- =====================================================

-- Get expenses in a channel with participants
SELECT e.id, e.title, e.description, e.total_amount, e.expense_date, e.created_at,
       json_build_object(
         'id', u.id,
         'username', u.username,
         'fullName', u.full_name
       ) as created_by,
       json_agg(json_build_object(
         'userId', ep.user_id,
         'username', u2.username,
         'fullName', u2.full_name,
         'amountPaid', ep.amount_paid,
         'amountOwed', ep.amount_owed
       )) as participants
FROM expenses e
JOIN users u ON e.created_by = u.id
LEFT JOIN expense_participants ep ON e.id = ep.expense_id
LEFT JOIN users u2 ON ep.user_id = u2.id
WHERE e.channel_id = $1
GROUP BY e.id, u.id, u.username, u.full_name
ORDER BY e.expense_date DESC;

-- Get user's expenses in a server (what they owe or what's owed to them)
SELECT e.id, e.title, e.total_amount, e.expense_date, e.created_at,
       ep.amount_paid, ep.amount_owed,
       (ep.amount_paid - ep.amount_owed) as net_balance
FROM expenses e
JOIN expense_participants ep ON e.id = ep.expense_id
WHERE e.server_id = $1 AND ep.user_id = $2
ORDER BY e.expense_date DESC;

-- =====================================================
-- BALANCE & SETTLEMENT QUERIES
-- =====================================================

-- Get user balance summary in a server
SELECT sm.user_id, u.username, u.full_name,
       COALESCE(SUM(CASE WHEN ep.amount_paid > 0 THEN ep.amount_paid ELSE 0 END), 0) as total_paid,
       COALESCE(SUM(CASE WHEN ep.amount_owed > 0 THEN ep.amount_owed ELSE 0 END), 0) as total_owed,
       COALESCE(SUM(CASE WHEN s.status = 'approved' THEN s.amount ELSE 0 END), 0) as settled,
       COALESCE(SUM(CASE WHEN ep.amount_paid > 0 THEN ep.amount_paid ELSE 0 END), 0) - 
       COALESCE(SUM(CASE WHEN ep.amount_owed > 0 THEN ep.amount_owed ELSE 0 END), 0) as balance
FROM server_members sm
JOIN users u ON sm.user_id = u.id
LEFT JOIN expense_participants ep ON ep.user_id = sm.user_id 
  AND ep.expense_id IN (SELECT id FROM expenses WHERE server_id = sm.server_id)
LEFT JOIN settlements s ON s.server_id = sm.server_id AND s.receiver_id = sm.user_id AND s.status = 'approved'
WHERE sm.server_id = $1
GROUP BY sm.user_id, u.username, u.full_name;

-- Get who owes whom in a server (simplified balance)
SELECT 
  ep.user_id,
  u.username,
  u.full_name,
  COALESCE(SUM(ep.amount_owed), 0) - COALESCE(SUM(ep.amount_paid), 0) as balance
FROM expense_participants ep
JOIN users u ON ep.user_id = u.id
WHERE ep.expense_id IN (SELECT id FROM expenses WHERE server_id = $1)
GROUP BY ep.user_id, u.username, u.full_name
HAVING SUM(ep.amount_owed) > SUM(ep.amount_paid)
ORDER BY balance DESC;

-- Get settlement history between two users
SELECT s.id, s.amount, s.status, s.notes, s.initiated_at, s.approved_at,
       json_build_object('id', p.id, 'username', p.username) as payer,
       json_build_object('id', r.id, 'username', r.username) as receiver
FROM settlements s
JOIN users p ON s.payer_id = p.id
JOIN users r ON s.receiver_id = r.id
WHERE s.server_id = $1 
  AND ((s.payer_id = $2 AND s.receiver_id = $3) OR (s.payer_id = $3 AND s.receiver_id = $2))
ORDER BY s.initiated_at DESC;

-- Get pending settlements for a user
SELECT s.id, s.amount, s.notes, s.initiated_at,
       json_build_object('id', p.id, 'username', p.username, 'fullName', p.full_name) as payer,
       json_build_object('id', r.id, 'username', r.username, 'fullName', r.full_name) as receiver
FROM settlements s
JOIN users p ON s.payer_id = p.id
JOIN users r ON s.receiver_id = r.id
WHERE s.server_id = $1 AND s.status = 'pending'
  AND (s.payer_id = $2 OR s.receiver_id = $2)
ORDER BY s.initiated_at DESC;

-- =====================================================
-- NOTIFICATION QUERIES
-- =====================================================

-- Get unread notifications for user
SELECT * FROM notifications 
WHERE user_id = $1 AND is_read = false
ORDER BY created_at DESC
LIMIT 50;

-- Get all notifications for user (paginated)
SELECT * FROM notifications 
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Count unread notifications
SELECT COUNT(*) as unread_count FROM notifications 
WHERE user_id = $1 AND is_read = false;

-- =====================================================
-- ANALYTICS QUERIES
-- =====================================================

-- Get server statistics
SELECT s.id, s.name,
       COUNT(DISTINCT sm.user_id) as member_count,
       COUNT(DISTINCT c.id) as channel_count,
       COUNT(DISTINCT e.id) as expense_count,
       COALESCE(SUM(e.total_amount), 0) as total_expense_amount,
       COUNT(DISTINCT se.id) as settlement_count
FROM servers s
LEFT JOIN server_members sm ON s.id = sm.server_id
LEFT JOIN channels c ON s.id = c.server_id
LEFT JOIN expenses e ON s.id = e.server_id
LEFT JOIN settlements se ON s.id = se.server_id
WHERE s.id = $1
GROUP BY s.id, s.name;

-- Get most active members in a server
SELECT sm.user_id, u.username, u.full_name,
       COUNT(DISTINCT e.id) as expenses_created,
       COUNT(DISTINCT ep.expense_id) as expenses_participated
FROM server_members sm
JOIN users u ON sm.user_id = u.id
LEFT JOIN expenses e ON e.created_by = sm.user_id AND e.server_id = sm.server_id
LEFT JOIN expense_participants ep ON ep.user_id = sm.user_id 
  AND ep.expense_id IN (SELECT id FROM expenses WHERE server_id = sm.server_id)
WHERE sm.server_id = $1
GROUP BY sm.user_id, u.username, u.full_name
ORDER BY (COUNT(DISTINCT e.id) + COUNT(DISTINCT ep.expense_id)) DESC;

-- Get monthly expense trend
SELECT 
  DATE_TRUNC('month', e.expense_date)::DATE as month,
  COUNT(*) as expense_count,
  COALESCE(SUM(e.total_amount), 0) as total_amount,
  COUNT(DISTINCT e.created_by) as participants
FROM expenses e
WHERE e.server_id = $1
GROUP BY DATE_TRUNC('month', e.expense_date)
ORDER BY month DESC;

-- =====================================================
-- AUDIT & MAINTENANCE QUERIES
-- =====================================================

-- Find users with no activity
SELECT id, username, email, last_login_at, created_at
FROM users 
WHERE last_login_at IS NULL OR last_login_at < CURRENT_TIMESTAMP - INTERVAL '30 days'
ORDER BY last_login_at DESC;

-- Find orphaned records (should not exist with proper cascading)
SELECT COUNT(*) as orphaned_expense_participants
FROM expense_participants ep
WHERE NOT EXISTS (SELECT 1 FROM expenses WHERE id = ep.expense_id);

-- Get table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- =====================================================
-- NOTES
-- =====================================================
-- $1, $2, $3, etc. are placeholders for parameterized queries
-- Always use parameterized queries to prevent SQL injection
-- Remember to escape user input on the backend before using in queries
-- ILIKE is PostgreSQL's case-insensitive LIKE operator
-- json_agg and json_build_object are PostgreSQL functions for JSON output
-- Use LIMIT and OFFSET for pagination in production

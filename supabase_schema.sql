-- DhanWiser Supabase Schema Migration
-- This file contains all tables needed for the DhanWiser application

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  upi_id VARCHAR(100),
  profile_picture_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP
);

-- Create index for faster lookups
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- =====================================================
-- SERVERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS servers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  created_by BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  is_locked BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_servers_created_by ON servers(created_by);

-- =====================================================
-- SERVER MEMBERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS server_members (
  server_id BIGINT NOT NULL REFERENCES servers(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (server_id, user_id)
);

CREATE INDEX idx_server_members_user_id ON server_members(user_id);
CREATE INDEX idx_server_members_server_id ON server_members(server_id);

-- =====================================================
-- CHANNELS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS channels (
  id BIGSERIAL PRIMARY KEY,
  server_id BIGINT NOT NULL REFERENCES servers(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_channels_server_id ON channels(server_id);
CREATE UNIQUE INDEX idx_channels_server_name ON channels(server_id, name);

-- =====================================================
-- EXPENSES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS expenses (
  id BIGSERIAL PRIMARY KEY,
  channel_id BIGINT NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
  server_id BIGINT NOT NULL REFERENCES servers(id) ON DELETE CASCADE,
  created_by BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount > 0),
  expense_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_expenses_channel_id ON expenses(channel_id);
CREATE INDEX idx_expenses_server_id ON expenses(server_id);
CREATE INDEX idx_expenses_created_by ON expenses(created_by);
CREATE INDEX idx_expenses_expense_date ON expenses(expense_date);

-- =====================================================
-- EXPENSE PARTICIPANTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS expense_participants (
  id BIGSERIAL PRIMARY KEY,
  expense_id BIGINT NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount_paid DECIMAL(10, 2) DEFAULT 0 CHECK (amount_paid >= 0),
  amount_owed DECIMAL(10, 2) DEFAULT 0 CHECK (amount_owed >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(expense_id, user_id)
);

CREATE INDEX idx_expense_participants_expense_id ON expense_participants(expense_id);
CREATE INDEX idx_expense_participants_user_id ON expense_participants(user_id);

-- =====================================================
-- SETTLEMENTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS settlements (
  id BIGSERIAL PRIMARY KEY,
  server_id BIGINT NOT NULL REFERENCES servers(id) ON DELETE CASCADE,
  payer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  notes TEXT,
  proof_image TEXT,
  initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  approved_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT no_self_settlement CHECK (payer_id != receiver_id)
);

CREATE INDEX idx_settlements_server_id ON settlements(server_id);
CREATE INDEX idx_settlements_payer_id ON settlements(payer_id);
CREATE INDEX idx_settlements_receiver_id ON settlements(receiver_id);
CREATE INDEX idx_settlements_status ON settlements(status);

-- =====================================================
-- NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  related_id BIGINT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- =====================================================
-- AUDIT LOG TABLE (Optional but recommended)
-- =====================================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  action VARCHAR(100) NOT NULL,
  table_name VARCHAR(50) NOT NULL,
  record_id BIGINT,
  changes JSONB,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- =====================================================
-- VIEWS FOR CALCULATIONS
-- =====================================================

-- View to get user balances in a server
CREATE OR REPLACE VIEW user_balances_by_server AS
SELECT 
  sm.user_id,
  sm.server_id,
  u.username,
  u.full_name,
  COALESCE(SUM(CASE WHEN ep.amount_paid > 0 THEN ep.amount_paid ELSE 0 END), 0) as total_paid,
  COALESCE(SUM(CASE WHEN ep.amount_owed > 0 THEN ep.amount_owed ELSE 0 END), 0) as total_owed,
  COALESCE(SUM(CASE WHEN s.status = 'approved' AND s.receiver_id = sm.user_id THEN s.amount ELSE 0 END), 0) as total_settled,
  COALESCE(SUM(CASE WHEN ep.amount_paid > 0 THEN ep.amount_paid ELSE 0 END), 0) - 
  COALESCE(SUM(CASE WHEN ep.amount_owed > 0 THEN ep.amount_owed ELSE 0 END), 0) as balance
FROM server_members sm
JOIN users u ON sm.user_id = u.id
LEFT JOIN expense_participants ep ON ep.user_id = sm.user_id 
  AND ep.expense_id IN (SELECT id FROM expenses WHERE server_id = sm.server_id)
LEFT JOIN settlements s ON s.server_id = sm.server_id AND s.receiver_id = sm.user_id
GROUP BY sm.user_id, sm.server_id, u.username, u.full_name;

-- =====================================================
-- FUNCTIONS FOR AUTOMATIC TIMESTAMP UPDATES
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_servers_updated_at BEFORE UPDATE ON servers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_server_members_updated_at BEFORE UPDATE ON server_members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_channels_updated_at BEFORE UPDATE ON channels
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expense_participants_updated_at BEFORE UPDATE ON expense_participants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_settlements_updated_at BEFORE UPDATE ON settlements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) - Optional
-- =====================================================
-- Note: RLS policies below are commented out for standard PostgreSQL.
-- If using Supabase or another auth system, uncomment and adjust accordingly.

-- Uncomment below if you have an auth schema with uid() function:
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE server_members ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE settlements ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
--
-- CREATE POLICY "Users can view own profile" ON users
--   FOR SELECT USING (id = auth.uid()::bigint);
--
-- CREATE POLICY "Users can view own notifications" ON notifications
--   FOR SELECT USING (user_id = auth.uid()::bigint);

-- =====================================================
-- DATA TYPES SUMMARY
-- =====================================================
-- BIGSERIAL: 64-bit auto-incrementing integer (suitable for IDs)
-- VARCHAR(n): String with max length n
-- TEXT: Unlimited text (used for base64 encoded images, JSON, etc.)
-- DECIMAL(10, 2): Fixed-point decimal for monetary values
-- BOOLEAN: True/False
-- DATE: Date only (YYYY-MM-DD)
-- TIMESTAMP: Date and time with timezone
-- JSONB: JSON binary format for flexible data storage

-- =====================================================
-- NOTES
-- =====================================================
-- 1. All foreign keys use ON DELETE CASCADE to maintain referential integrity
-- 2. Indexes are created on commonly queried columns for better performance
-- 3. Constraints check data validity (e.g., amounts > 0, status enum values)
-- 4. Views and functions help with calculations and maintainability
-- 5. Updated_at timestamps automatically update on record changes
-- 6. RLS policies ensure data privacy (can be customized based on requirements)

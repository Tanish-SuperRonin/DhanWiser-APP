import { pool } from '../config/database.js';
import { authService } from '../services/authService.js';

export const authController = {
  // Signup
  async signup(req, res) {
    try {
      const { username, email, password, fullName, upiId } = req.body;

      // Check if user exists
      const userExists = await pool.query(
        'SELECT * FROM users WHERE email = $1 OR username = $2',
        [email, username]
      );

      if (userExists.rows.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'User already exists with this email or username'
        });
      }

      // Hash password
      const hashedPassword = await authService.hashPassword(password);

      // Create user
      const result = await pool.query(
        `INSERT INTO users (username, email, password_hash, full_name, upi_id) 
         VALUES ($1, $2, $3, $4, $5) 
         RETURNING id, username, email, full_name, upi_id, created_at`,
        [username, email, hashedPassword, fullName, upiId || null]
      );

      const user = result.rows[0];

      // Generate tokens
      const accessToken = authService.generateAccessToken(user.id, user.username);
      const refreshToken = authService.generateRefreshToken(user.id);

      // Store refresh token
      await authService.storeRefreshToken(user.id, refreshToken);

      res.status(201).json({
        success: true,
        message: 'User created successfully',
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            fullName: user.full_name,
            upiId: user.upi_id
          },
          accessToken,
          refreshToken
        }
      });
    } catch (error) {
      console.error('Signup error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during signup',
        error: error.message
      });
    }
  },

  // Login
  async login(req, res) {
    try {
      const { email, password } = req.body;

      // Find user
      const result = await pool.query(
        'SELECT * FROM users WHERE email = $1 AND is_active = true',
        [email]
      );

      if (result.rows.length === 0) {
        return res.status(401).json({
          success: false,
          message: 'Invalid credentials'
        });
      }

      const user = result.rows[0];

      // Verify password
      const isValidPassword = await authService.comparePassword(
        password,
        user.password_hash
      );

      if (!isValidPassword) {
        return res.status(401).json({
          success: false,
          message: 'Invalid credentials'
        });
      }

      // Generate tokens
      const accessToken = authService.generateAccessToken(user.id, user.username);
      const refreshToken = authService.generateRefreshToken(user.id);

      // Store refresh token
      await authService.storeRefreshToken(user.id, refreshToken);

      res.json({
        success: true,
        message: 'Login successful',
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            fullName: user.full_name,
            upiId: user.upi_id
          },
          accessToken,
          refreshToken
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during login',
        error: error.message
      });
    }
  },

  // Refresh token
  async refreshToken(req, res) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          message: 'Refresh token required'
        });
      }

      // Verify refresh token
      const decoded = await authService.verifyRefreshToken(refreshToken);

      if (!decoded) {
        return res.status(401).json({
          success: false,
          message: 'Invalid or expired refresh token'
        });
      }

      // Get user
      const result = await pool.query(
        'SELECT id, username FROM users WHERE id = $1',
        [decoded.userId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const user = result.rows[0];

      // Generate new access token
      const accessToken = authService.generateAccessToken(user.id, user.username);

      res.json({
        success: true,
        data: { accessToken }
      });
    } catch (error) {
      console.error('Refresh token error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  },

  // Logout
  async logout(req, res) {
    try {
      const { refreshToken } = req.body;

      if (refreshToken) {
        // Delete refresh token
        await pool.query(
          'DELETE FROM refresh_tokens WHERE token = $1',
          [refreshToken]
        );
      }

      res.json({
        success: true,
        message: 'Logged out successfully'
      });
    } catch (error) {
      console.error('Logout error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error',
        error: error.message
      });
    }
  }
};
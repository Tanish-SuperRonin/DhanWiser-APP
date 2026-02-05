import express from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.js';
import userRoutes from './routes/users.js';  // ADD THIS LINE
import serverRoutes from './routes/servers.js';
import channelRoutes from './routes/channels.js';    
import expenseRoutes from './routes/expenses.js';    
import settlementRoutes from './routes/settlements.js';
import notificationRoutes from './routes/notifications.js';


const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/api/servers', serverRoutes);
app.use('/api/channels', channelRoutes);    // ADD THIS
app.use('/api/expenses', expenseRoutes);    // ADD THIS
app.use('/api/settlements', settlementRoutes);
app.use('/api/notifications', notificationRoutes);

// Request logging (development)
if (process.env.NODE_ENV === 'development') {
  app.use((req, res, next) => {
    console.log(`${req.method} ${req.path}`);
    next();
  });
}

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    success: true, 
    message: 'DhanWiser API is running',
    timestamp: new Date().toISOString()
  });
});

// Test route
app.get('/test', (req, res) => {
  res.json({ message: 'Test route works!' });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);  

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

export default app;

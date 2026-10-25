const express = require('express');
const cors = require('cors');
const { errorHandler } = require('./middleware/errorMiddleware');

// Import routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const taskRoutes = require('./routes/taskRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const statisticsRoutes = require('./routes/statisticsRoutes');
const emailLogRoutes = require('./routes/emailLogRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/statistics', statisticsRoutes);
app.use('/api/email-logs', emailLogRoutes);

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'Task Manager API is running', version: '1.0.0' });
});

// Error handler (phải đặt cuối cùng)
app.use(errorHandler);

module.exports = app;

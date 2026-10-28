const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { tokenBlacklist } = require('../controllers/authController');

/**
 * Middleware xác thực JWT token
 * Gắn req.user cho các route cần đăng nhập
 */
const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Không có token xác thực. Vui lòng đăng nhập.' });
    }

    const token = authHeader.split(' ')[1];

    // Kiểm tra token đã bị blacklist (đã logout)
    if (tokenBlacklist.has(token)) {
      return res.status(401).json({ message: 'Token đã hết hiệu lực. Vui lòng đăng nhập lại.' });
    }

    // Xác minh token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Lấy thông tin user
    const user = await User.findById(decoded.id);
    if (!user) {
      return res.status(401).json({ message: 'Tài khoản không tồn tại' });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token đã hết hạn. Vui lòng đăng nhập lại.' });
    }
    return res.status(401).json({ message: 'Token không hợp lệ' });
  }
};

module.exports = { protect };

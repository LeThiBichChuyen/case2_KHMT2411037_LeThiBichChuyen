const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Set lưu token đã logout (blacklist đơn giản in-memory)
// Production nên dùng Redis
const tokenBlacklist = new Set();

// Tạo JWT token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

/**
 * @desc    Đăng ký tài khoản mới
 * @route   POST /api/auth/register
 * @access  Public
 */
const register = async (req, res, next) => {
  try {
    const { fullName, email, password } = req.body;

    // Kiểm tra email đã tồn tại
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ message: 'Email đã được sử dụng' });
    }

    // Tạo user mới (password sẽ được hash bởi pre-save hook)
    const user = await User.create({
      fullName,
      email,
      passwordHash: password,
    });

    const token = generateToken(user._id);

    res.status(201).json({
      message: 'Đăng ký tài khoản thành công',
      token,
      user,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Đăng nhập
 * @route   POST /api/auth/login
 * @access  Public
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Tìm user và lấy passwordHash
    const user = await User.findOne({ email: email.toLowerCase() }).select('+passwordHash');
    if (!user) {
      return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng' });
    }

    // Kiểm tra mật khẩu
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng' });
    }

    const token = generateToken(user._id);

    res.json({
      message: 'Đăng nhập thành công',
      token,
      user,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Đăng xuất (vô hiệu hóa token)
 * @route   POST /api/auth/logout
 * @access  Private
 */
const logout = (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (token) {
    tokenBlacklist.add(token);
  }
  res.json({ message: 'Đăng xuất thành công' });
};

/**
 * @desc    Lấy thông tin người dùng hiện tại
 * @route   GET /api/auth/me
 * @access  Private
 */
const getMe = async (req, res) => {
  res.json({ user: req.user });
};

/**
 * @desc    Cập nhật thông tin cá nhân
 * @route   PUT /api/auth/me
 * @access  Private
 */
const updateMe = async (req, res, next) => {
  try {
    const { fullName, avatarUrl } = req.body;

    const updateData = {};
    if (fullName !== undefined) updateData.fullName = fullName;
    if (avatarUrl !== undefined) updateData.avatarUrl = avatarUrl;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    );

    res.json({
      message: 'Cập nhật thông tin thành công',
      user,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Đổi mật khẩu
 * @route   PUT /api/auth/change-password
 * @access  Private
 */
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    // Lấy user kèm passwordHash
    const user = await User.findById(req.user._id).select('+passwordHash');

    // Xác minh mật khẩu hiện tại
    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      return res.status(400).json({ message: 'Mật khẩu hiện tại không đúng' });
    }

    // Cập nhật mật khẩu mới (pre-save hook sẽ hash)
    user.passwordHash = newPassword;
    await user.save();

    res.json({ message: 'Đổi mật khẩu thành công' });
  } catch (error) {
    next(error);
  }
};

module.exports = { register, login, logout, getMe, updateMe, changePassword, tokenBlacklist };

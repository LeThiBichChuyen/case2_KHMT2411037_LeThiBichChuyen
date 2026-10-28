const { body } = require('express-validator');

const registerValidator = [
  body('fullName')
    .trim()
    .notEmpty().withMessage('Họ tên không được để trống')
    .isLength({ min: 2 }).withMessage('Họ tên phải có ít nhất 2 ký tự'),

  body('email')
    .trim()
    .notEmpty().withMessage('Email không được để trống')
    .isEmail().withMessage('Email không hợp lệ')
    .normalizeEmail(),

  body('password')
    .notEmpty().withMessage('Mật khẩu không được để trống')
    .isLength({ min: 6 }).withMessage('Mật khẩu phải có ít nhất 6 ký tự'),
];

const loginValidator = [
  body('email')
    .trim()
    .notEmpty().withMessage('Email không được để trống')
    .isEmail().withMessage('Email không hợp lệ')
    .normalizeEmail(),

  body('password')
    .notEmpty().withMessage('Mật khẩu không được để trống'),
];

const updateProfileValidator = [
  body('fullName')
    .optional()
    .trim()
    .isLength({ min: 2 }).withMessage('Họ tên phải có ít nhất 2 ký tự'),
];

const changePasswordValidator = [
  body('currentPassword')
    .notEmpty().withMessage('Mật khẩu hiện tại không được để trống'),

  body('newPassword')
    .notEmpty().withMessage('Mật khẩu mới không được để trống')
    .isLength({ min: 6 }).withMessage('Mật khẩu mới phải có ít nhất 6 ký tự'),

  body('confirmPassword')
    .notEmpty().withMessage('Xác nhận mật khẩu không được để trống')
    .custom((value, { req }) => {
      if (value !== req.body.newPassword) {
        throw new Error('Xác nhận mật khẩu không khớp');
      }
      return true;
    }),
];

module.exports = {
  registerValidator,
  loginValidator,
  updateProfileValidator,
  changePasswordValidator,
};

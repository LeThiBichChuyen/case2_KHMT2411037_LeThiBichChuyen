const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const EmailLog = require('../models/EmailLog');
const emailService = require('../services/emailService');

router.use(protect);

// POST /api/email-logs/:id/retry
router.post('/:id/retry', async (req, res, next) => {
  try {
    const log = await EmailLog.findById(req.params.id);
    if (!log) return res.status(404).json({ message: 'Không tìm thấy log email' });
    if (log.attempts >= 3) {
      return res.status(400).json({ message: 'Đã đạt giới hạn thử gửi lại' });
    }

    await emailService.retryEmail(log);
    res.json({ message: 'Đang thử gửi lại email' });
  } catch (error) {
    next(error);
  }
});

module.exports = router;

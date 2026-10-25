const TaskShare = require('../models/TaskShare');
const TaskActivity = require('../models/TaskActivity');
const notificationService = require('../services/notificationService');
const emailService = require('../services/emailService');
const User = require('../models/User');

// GET /api/tasks/:id/shares
const getShares = async (req, res, next) => {
  try {
    const shares = await TaskShare.find({ taskId: req.params.id }).populate('userId', 'fullName email');
    res.json({ shares });
  } catch (error) {
    next(error);
  }
};

// POST /api/tasks/:id/shares
const addShares = async (req, res, next) => {
  try {
    const { shares } = req.body; // [{userId, permission}]
    const task = req.task;
    const results = [];

    for (const share of shares) {
      const user = await User.findById(share.userId);
      if (!user) continue;

      const existing = await TaskShare.findOne({ taskId: task._id, userId: share.userId });
      if (existing) {
        existing.permission = share.permission;
        await existing.save();
        results.push(existing);
      } else {
        const newShare = await TaskShare.create({
          taskId: task._id,
          userId: share.userId,
          permission: share.permission,
          sharedBy: req.user._id,
        });
        results.push(newShare);

        await notificationService.create({
          userId: user._id,
          taskId: task._id,
          type: 'task_shared',
          title: 'Công việc được chia sẻ với bạn',
          message: `Bạn được chia sẻ công việc: ${task.title} với quyền ${share.permission}`,
        });
        await emailService.sendTaskSharedEmail(user.email, task, req.user, share.permission);
      }
    }

    await TaskActivity.create({
      taskId: task._id,
      userId: req.user._id,
      action: 'shared',
      details: { shares },
    });

    res.json({ message: 'Chia sẻ công việc thành công', shares: results });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/tasks/:id/shares/:shareId
const updateShare = async (req, res, next) => {
  try {
    const { permission } = req.body;
    const share = await TaskShare.findByIdAndUpdate(req.params.shareId, { permission }, { new: true });
    if (!share) {
      return res.status(404).json({ message: 'Không tìm thấy bản ghi chia sẻ' });
    }
    res.json({ message: 'Cập nhật quyền thành công', share });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/tasks/:id/shares/:shareId
const removeShare = async (req, res, next) => {
  try {
    await TaskShare.findByIdAndDelete(req.params.shareId);

    await TaskActivity.create({
      taskId: req.params.id,
      userId: req.user._id,
      action: 'unshared',
      details: { shareId: req.params.shareId },
    });

    res.json({ message: 'Thu hồi quyền chia sẻ thành công' });
  } catch (error) {
    next(error);
  }
};

module.exports = { getShares, addShares, updateShare, removeShare };

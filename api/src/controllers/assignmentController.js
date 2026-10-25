const Task = require('../models/Task');
const TaskActivity = require('../models/TaskActivity');
const notificationService = require('../services/notificationService');
const emailService = require('../services/emailService');
const User = require('../models/User');

// GET /api/tasks/:id/assignees
const getAssignees = async (req, res, next) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');
    res.json({ assignees: task.assigneeIds, primaryAssignee: task.primaryAssigneeId });
  } catch (error) {
    next(error);
  }
};

// POST /api/tasks/:id/assignees
const addAssignees = async (req, res, next) => {
  try {
    const { userIds, primaryAssigneeId } = req.body;
    const task = req.task;

    // Kiểm tra user tồn tại
    const users = await User.find({ _id: { $in: userIds } });
    if (users.length !== userIds.length) {
      return res.status(400).json({ message: 'Một hoặc nhiều người dùng không tồn tại' });
    }

    // Thêm assignees (tránh trùng)
    const newIds = userIds.filter((id) => !task.assigneeIds.map((a) => a.toString()).includes(id));
    task.assigneeIds.push(...newIds);
    if (primaryAssigneeId) task.primaryAssigneeId = primaryAssigneeId;
    await task.save();

    // Gửi thông báo và email
    for (const user of users) {
      await notificationService.create({
        userId: user._id,
        taskId: task._id,
        type: 'task_assigned',
        title: 'Bạn được giao công việc mới',
        message: `Bạn đã được giao công việc: ${task.title}`,
      });
      await emailService.sendTaskAssignedEmail(user.email, task, req.user);
    }

    await TaskActivity.create({
      taskId: task._id,
      userId: req.user._id,
      action: 'assigned',
      details: { userIds },
    });

    res.json({ message: 'Giao việc thành công', task });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/tasks/:id/assignees/:userId
const updateAssignee = async (req, res, next) => {
  try {
    const { isPrimaryAssignee } = req.body;
    const task = req.task;

    if (isPrimaryAssignee) {
      task.primaryAssigneeId = req.params.userId;
      await task.save();
    }

    res.json({ message: 'Cập nhật người phụ trách thành công', task });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/tasks/:id/assignees/:userId
const removeAssignee = async (req, res, next) => {
  try {
    const task = req.task;
    task.assigneeIds = task.assigneeIds.filter((id) => id.toString() !== req.params.userId);
    if (task.primaryAssigneeId && task.primaryAssigneeId.toString() === req.params.userId) {
      task.primaryAssigneeId = null;
    }
    await task.save();

    await TaskActivity.create({
      taskId: task._id,
      userId: req.user._id,
      action: 'unassigned',
      details: { userId: req.params.userId },
    });

    res.json({ message: 'Hủy giao việc thành công' });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAssignees, addAssignees, updateAssignee, removeAssignee };

const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

// Kiểm tra quyền truy cập công việc (owner, assignee, hoặc được share)
const checkTaskAccess = async (req, res, next) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc' });
    }

    const userId = req.user._id.toString();
    const isOwner = task.createdBy.toString() === userId;
    const isAssignee = task.assigneeIds.some((id) => id.toString() === userId);
    const shareRecord = await TaskShare.findOne({ taskId: task._id, userId: req.user._id });

    if (!isOwner && !isAssignee && !shareRecord) {
      return res.status(403).json({ message: 'Không có quyền truy cập công việc này' });
    }

    req.task = task;
    req.taskShare = shareRecord;
    req.isOwner = isOwner;
    req.isAssignee = isAssignee;
    next();
  } catch (error) {
    next(error);
  }
};

// Chỉ owner mới có quyền xóa hoặc quản lý chia sẻ
const requireOwner = (req, res, next) => {
  if (!req.isOwner) {
    return res.status(403).json({ message: 'Chỉ người tạo công việc mới có quyền thực hiện thao tác này' });
  }
  next();
};

// Owner hoặc editor mới có quyền chỉnh sửa
const requireEditor = (req, res, next) => {
  if (!req.isOwner && (!req.taskShare || req.taskShare.permission !== 'editor') && !req.isAssignee) {
    return res.status(403).json({ message: 'Không có quyền chỉnh sửa công việc này' });
  }
  next();
};

module.exports = { checkTaskAccess, requireOwner, requireEditor };

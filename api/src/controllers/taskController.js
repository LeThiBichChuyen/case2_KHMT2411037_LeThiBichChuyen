const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const TaskActivity = require('../models/TaskActivity');

// GET /api/tasks
const getTasks = async (req, res, next) => {
  try {
    const { scope, status, priority, q, sortBy = 'createdAt', order = 'desc' } = req.query;
    const userId = req.user._id;

    // Lấy danh sách taskId được share
    const sharedTaskIds = await TaskShare.find({ userId }).distinct('taskId');

    let filter = {};
    if (scope === 'created') {
      filter = { createdBy: userId };
    } else if (scope === 'assigned') {
      filter = { assigneeIds: userId };
    } else if (scope === 'shared') {
      filter = { _id: { $in: sharedTaskIds } };
    } else {
      // Tất cả công việc có quyền truy cập
      filter = {
        $or: [{ createdBy: userId }, { assigneeIds: userId }, { _id: { $in: sharedTaskIds } }],
      };
    }

    if (status) filter.status = status;
    if (priority) filter.priority = priority;
    if (q) filter.title = { $regex: q, $options: 'i' };

    const sortOrder = order === 'asc' ? 1 : -1;
    const tasks = await Task.find(filter)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email')
      .sort({ [sortBy]: sortOrder });

    res.json({ tasks });
  } catch (error) {
    next(error);
  }
};

// POST /api/tasks
const createTask = async (req, res, next) => {
  try {
    const { title, description, startDate, dueDate, priority, status } = req.body;
    const task = await Task.create({
      title,
      description,
      startDate,
      dueDate,
      priority,
      status,
      createdBy: req.user._id,
    });

    await TaskActivity.create({ taskId: task._id, userId: req.user._id, action: 'created' });

    res.status(201).json({ message: 'Tạo công việc thành công', task });
  } catch (error) {
    next(error);
  }
};

// GET /api/tasks/:id
const getTaskById = async (req, res) => {
  const task = await req.task
    .populate('createdBy', 'fullName email')
    .populate('assigneeIds', 'fullName email')
    .populate('primaryAssigneeId', 'fullName email');
  res.json({ task });
};

// PUT /api/tasks/:id
const updateTask = async (req, res, next) => {
  try {
    const { title, description, startDate, dueDate, priority } = req.body;
    const task = await Task.findByIdAndUpdate(
      req.params.id,
      { title, description, startDate, dueDate, priority },
      { new: true, runValidators: true }
    );

    await TaskActivity.create({
      taskId: task._id,
      userId: req.user._id,
      action: 'updated',
      details: req.body,
    });

    res.json({ message: 'Cập nhật công việc thành công', task });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/tasks/:id
const deleteTask = async (req, res, next) => {
  try {
    await Task.findByIdAndDelete(req.params.id);
    await TaskShare.deleteMany({ taskId: req.params.id });
    res.json({ message: 'Xóa công việc thành công' });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/tasks/:id/status
const updateStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const validStatuses = ['todo', 'in_progress', 'completed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ message: 'Trạng thái không hợp lệ' });
    }

    const task = await Task.findByIdAndUpdate(req.params.id, { status }, { new: true });

    await TaskActivity.create({
      taskId: task._id,
      userId: req.user._id,
      action: 'status_changed',
      details: { status },
    });

    res.json({ message: 'Cập nhật trạng thái thành công', task });
  } catch (error) {
    next(error);
  }
};

// GET /api/tasks/:id/activities
const getTaskActivities = async (req, res, next) => {
  try {
    const activities = await TaskActivity.find({ taskId: req.params.id })
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 });
    res.json({ activities });
  } catch (error) {
    next(error);
  }
};

module.exports = { getTasks, createTask, getTaskById, updateTask, deleteTask, updateStatus, getTaskActivities };

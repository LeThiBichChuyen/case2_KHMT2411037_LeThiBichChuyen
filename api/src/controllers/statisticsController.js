const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

// GET /api/statistics/tasks
const getTaskStats = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const sharedTaskIds = await TaskShare.find({ userId }).distinct('taskId');

    const filter = {
      $or: [{ createdBy: userId }, { assigneeIds: userId }, { _id: { $in: sharedTaskIds } }],
    };

    const [todo, in_progress, completed] = await Promise.all([
      Task.countDocuments({ ...filter, status: 'todo' }),
      Task.countDocuments({ ...filter, status: 'in_progress' }),
      Task.countDocuments({ ...filter, status: 'completed' }),
    ]);

    res.json({ stats: { todo, in_progress, completed, total: todo + in_progress + completed } });
  } catch (error) {
    next(error);
  }
};

// GET /api/statistics/assignments
const getAssignmentStats = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const [assigned, managing] = await Promise.all([
      Task.countDocuments({ assigneeIds: userId }),
      Task.countDocuments({ primaryAssigneeId: userId }),
    ]);
    res.json({ stats: { assigned, managing } });
  } catch (error) {
    next(error);
  }
};

// GET /api/statistics/deadlines
const getDeadlineStats = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const now = new Date();
    const in24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const baseFilter = {
      $or: [{ createdBy: userId }, { assigneeIds: userId }],
      status: { $ne: 'completed' },
    };

    const [overdue, dueSoon] = await Promise.all([
      Task.countDocuments({ ...baseFilter, dueDate: { $lt: now } }),
      Task.countDocuments({ ...baseFilter, dueDate: { $gte: now, $lte: in24h } }),
    ]);

    res.json({ stats: { overdue, dueSoon } });
  } catch (error) {
    next(error);
  }
};

module.exports = { getTaskStats, getAssignmentStats, getDeadlineStats };

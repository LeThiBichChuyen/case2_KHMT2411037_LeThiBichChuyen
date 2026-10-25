const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { checkTaskAccess, requireOwner, requireEditor } = require('../middleware/permissionMiddleware');
const {
  getTasks, createTask, getTaskById, updateTask, deleteTask, updateStatus, getTaskActivities,
} = require('../controllers/taskController');
const {
  getAssignees, addAssignees, updateAssignee, removeAssignee,
} = require('../controllers/assignmentController');
const {
  getShares, addShares, updateShare, removeShare,
} = require('../controllers/taskShareController');

router.use(protect);

// Task CRUD
router.get('/', getTasks);
router.post('/', createTask);
router.get('/:id', checkTaskAccess, getTaskById);
router.put('/:id', checkTaskAccess, requireEditor, updateTask);
router.delete('/:id', checkTaskAccess, requireOwner, deleteTask);
router.patch('/:id/status', checkTaskAccess, requireEditor, updateStatus);
router.get('/:id/activities', checkTaskAccess, getTaskActivities);

// Assignees
router.get('/:id/assignees', checkTaskAccess, getAssignees);
router.post('/:id/assignees', checkTaskAccess, requireOwner, addAssignees);
router.patch('/:id/assignees/:userId', checkTaskAccess, requireOwner, updateAssignee);
router.delete('/:id/assignees/:userId', checkTaskAccess, requireOwner, removeAssignee);

// Shares
router.get('/:id/shares', checkTaskAccess, getShares);
router.post('/:id/shares', checkTaskAccess, requireOwner, addShares);
router.patch('/:id/shares/:shareId', checkTaskAccess, requireOwner, updateShare);
router.delete('/:id/shares/:shareId', checkTaskAccess, requireOwner, removeShare);

module.exports = router;

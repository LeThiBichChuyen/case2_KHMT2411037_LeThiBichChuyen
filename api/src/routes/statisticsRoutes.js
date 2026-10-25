const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { getTaskStats, getAssignmentStats, getDeadlineStats } = require('../controllers/statisticsController');

router.use(protect);

router.get('/tasks', getTaskStats);
router.get('/assignments', getAssignmentStats);
router.get('/deadlines', getDeadlineStats);

module.exports = router;

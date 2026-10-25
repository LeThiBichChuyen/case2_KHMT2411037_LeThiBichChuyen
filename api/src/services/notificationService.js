const Notification = require('../models/Notification');

const create = async ({ userId, taskId, type, title, message }) => {
  return Notification.create({ userId, taskId, type, title, message });
};

module.exports = { create };

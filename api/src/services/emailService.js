const transporter = require('../config/email');
const EmailLog = require('../models/EmailLog');

const sendEmail = async ({ to, subject, html, taskId, eventType }) => {
  const log = await EmailLog.create({
    taskId: taskId || null,
    recipientEmail: to,
    eventType,
    subject,
    status: 'pending',
  });

  try {
    log.attempts += 1;
    await transporter.sendMail({
      from: process.env.EMAIL_FROM,
      to,
      subject,
      html,
    });
    log.status = 'sent';
    log.sentAt = new Date();
  } catch (error) {
    log.status = 'failed';
    log.errorMessage = error.message;
  } finally {
    await log.save();
  }

  return log;
};

const sendTaskAssignedEmail = async (recipientEmail, task, assignedBy) => {
  return sendEmail({
    to: recipientEmail,
    subject: `[Task Manager] Bạn được giao công việc: ${task.title}`,
    html: `
      <h2>Bạn được giao công việc mới</h2>
      <p><strong>Công việc:</strong> ${task.title}</p>
      <p><strong>Mô tả:</strong> ${task.description || 'Không có mô tả'}</p>
      <p><strong>Người giao:</strong> ${assignedBy.fullName}</p>
      <p><strong>Hạn hoàn thành:</strong> ${task.dueDate ? new Date(task.dueDate).toLocaleDateString('vi-VN') : 'Chưa đặt'}</p>
    `,
    taskId: task._id,
    eventType: 'task_assigned',
  });
};

const sendTaskSharedEmail = async (recipientEmail, task, sharedBy, permission) => {
  const permissionText = permission === 'editor' ? 'chỉnh sửa' : 'xem';
  return sendEmail({
    to: recipientEmail,
    subject: `[Task Manager] Công việc được chia sẻ với bạn: ${task.title}`,
    html: `
      <h2>Công việc được chia sẻ với bạn</h2>
      <p><strong>Công việc:</strong> ${task.title}</p>
      <p><strong>Người chia sẻ:</strong> ${sharedBy.fullName}</p>
      <p><strong>Quyền của bạn:</strong> ${permissionText}</p>
    `,
    taskId: task._id,
    eventType: 'task_shared',
  });
};

const retryEmail = async (log) => {
  // Thử gửi lại dựa trên log
  try {
    log.attempts += 1;
    await transporter.sendMail({
      from: process.env.EMAIL_FROM,
      to: log.recipientEmail,
      subject: log.subject,
      html: '<p>Xin lỗi vì sự chậm trễ. Email này được gửi lại.</p>',
    });
    log.status = 'sent';
    log.sentAt = new Date();
    log.errorMessage = null;
  } catch (error) {
    log.status = 'failed';
    log.errorMessage = error.message;
  } finally {
    await log.save();
  }
};

module.exports = { sendEmail, sendTaskAssignedEmail, sendTaskSharedEmail, retryEmail };

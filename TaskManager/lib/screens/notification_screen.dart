import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final Task relatedTask;
  final String emailStatus; // 'Success' hoặc 'Failed'

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.relatedTask,
    this.emailStatus = 'Success',
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Dữ liệu mẫu thông báo & lịch sử gửi Email
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      title: 'Giao việc mới',
      body: 'Bạn được giao công việc: Hoàn thiện Giao diện A',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      emailStatus: 'Success',
      relatedTask: Task(
        id: '1',
        title: 'Hoàn thiện Giao diện A',
        description: 'Thiết kế màn hình Đăng nhập và Đăng ký',
        isCompleted: true,
        creatorEmail: 'admin@gmail.com',
      ),
    ),
    AppNotification(
      id: 'n2',
      title: 'Lời mời hợp tác',
      body: 'Bạn được mời xem công việc: Xây dựng Giao diện C',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      emailStatus: 'Success',
      relatedTask: Task(
        id: '3',
        title: 'Xây dựng Giao diện C',
        description: 'Giao việc, chia sẻ và phân quyền truy cập',
        isCompleted: false,
        creatorEmail: 'admin@gmail.com',
      ),
    ),
    AppNotification(
      id: 'n3',
      title: 'Nhắc việc sắp tới hạn (24h)',
      body: 'Công việc Xây dựng Giao diện D sắp hết hạn',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      emailStatus: 'Failed',
      relatedTask: Task(
        id: '4',
        title: 'Xây dựng Giao diện D',
        description: 'Thông báo qua Email và Trong ứng dụng',
        isCompleted: false,
        creatorEmail: 'admin@gmail.com',
      ),
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo & Email'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return Card(
            color: item.isRead ? Colors.white : Colors.deepPurple.shade50,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                item.isRead ? Icons.notifications_none : Icons.notifications_active,
                color: item.isRead ? Colors.grey : Colors.deepPurple,
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item.body),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        item.emailStatus == 'Success' ? Icons.mark_email_read : Icons.mark_email_unread,
                        size: 14,
                        color: item.emailStatus == 'Success' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Email: ${item.emailStatus == 'Success' ? 'Đã gửi' : 'Thất bại'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.emailStatus == 'Success' ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                setState(() {
                  item.isRead = true;
                });
                // Mở trực tiếp công việc liên quan
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(task: item.relatedTask),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
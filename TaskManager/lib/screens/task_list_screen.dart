import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';
import 'notification_screen.dart';
import 'dashboard_screen.dart';
import 'task_create_screen.dart';
import 'profile/profile_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Hoàn thiện Giao diện A',
      description: 'Thiết kế màn hình Đăng nhập và Đăng ký',
      isCompleted: true,
      creatorEmail: 'admin@gmail.com',
    ),
    Task(
      id: '2',
      title: 'Tích hợp Giao diện B',
      description: 'Xây dựng danh sách công việc và lọc trạng thái',
      isCompleted: true,
      creatorEmail: 'lchzuyen@gmail.com',
    ),
    Task(
      id: '3',
      title: 'Xây dựng Giao diện C',
      description: 'Giao việc, chia sẻ và phân quyền truy cập',
      isCompleted: false,
      creatorEmail: 'admin@gmail.com',
    ),
    Task(
      id: '4',
      title: 'Xây dựng Giao diện D',
      description: 'Thông báo qua email và trong ứng dụng',
      isCompleted: false,
      creatorEmail: 'admin@gmail.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Cá nhân',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const DashboardScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const NotificationScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task.isCompleted ? Colors.green : Colors.grey,
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(task.description),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
                );
              },
            ),
          );
        },
      ),
      // Nút FloatingActionButton hứng kết quả trả về từ màn hình Tạo công việc
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push<Task>(
            context,
            MaterialPageRoute(builder: (context) => const TaskCreateScreen()),
          );

          if (newTask != null) {
            setState(() {
              _tasks.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
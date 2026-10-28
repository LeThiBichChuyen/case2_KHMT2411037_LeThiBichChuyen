import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';
import 'notification_screen.dart'; // Import Giao diện D
import 'dashboard_screen.dart';    // Import Giao diện E

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
      assigneeEmail: 'lchzuyen@gmail.com',
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
      assigneeEmail: 'lchzuyen@gmail.com',
    ),
  ];

  String _filter = 'All';

  List<Task> get _filteredTasks {
    if (_filter == 'Completed') {
      return _tasks.where((t) => t.isCompleted).toList();
    } else if (_filter == 'Pending') {
      return _tasks.where((t) => !t.isCompleted).toList();
    }
    return _tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        centerTitle: true,
        actions: [
          // NÚT MỞ GIAO DIỆN E (THỐNG KÊ & TIỆN ÍCH)
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Thống kê & Tiện ích',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
          // NÚT MỞ GIAO DIỆN D (THÔNG BÁO & EMAIL)
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Thông báo & Email',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filter = value);
            },
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('Tất cả')),
              const PopupMenuItem(value: 'Pending', child: Text('Chưa xong')),
              const PopupMenuItem(value: 'Completed', child: Text('Đã xong')),
            ],
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredTasks.length,
        itemBuilder: (context, index) {
          final task = _filteredTasks[index];
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
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(task: task),
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
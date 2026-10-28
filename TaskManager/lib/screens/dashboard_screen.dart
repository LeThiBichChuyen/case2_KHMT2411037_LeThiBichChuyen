import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // Dữ liệu mẫu giả lập cho Thống kê
  final List<Task> _allTasks = [
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

  // Lịch sử hoạt động giả lập
  final List<Map<String, String>> _activityLogs = [
    {'time': '10:30 AM', 'action': 'Admin đã tạo công việc Giao diện D'},
    {'time': '09:15 AM', 'action': 'Bạn đã hoàn thành công việc Giao diện B'},
    {'time': 'Hôm qua', 'action': 'Admin đã chia sẻ quyền Editor cho bạn'},
  ];

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1)); // Giả lập tải dữ liệu

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Làm mới dữ liệu thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = 'lchzuyen@gmail.com';

    final completedCount = _allTasks.where((t) => t.isCompleted).length;
    final pendingCount = _allTasks.where((t) => !t.isCompleted).length;
    final assignedToMeCount = _allTasks.where((t) => t.assigneeEmail == currentUserEmail).length;
    final createdByMeCount = _allTasks.where((t) => t.creatorEmail == currentUserEmail).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê & Tiện ích'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),

              // 1. Thống kê tổng quan trạng thái
              const Text('Trạng thái công việc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatCard('Tổng số', '${_allTasks.length}', Colors.blue),
                  _buildStatCard('Đã xong', '$completedCount', Colors.green),
                  _buildStatCard('Chưa xong', '$pendingCount', Colors.orange),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Thống kê theo vai trò
              const Text('Phân loại vai trò', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatCard('Được giao', '$assignedToMeCount', Colors.purple),
                  _buildStatCard('Tôi tạo', '$createdByMeCount', Colors.teal),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Công việc sắp / quá hạn
              const Text('Cảnh báo tiến độ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: const Text('Công việc quá hạn: 1', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Xây dựng Giao diện D (Quá hạn 2 giờ)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(task: _allTasks[3]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 4. Lịch sử hoạt động
              const Text('Lịch sử hoạt động', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activityLogs.length,
                itemBuilder: (context, index) {
                  final log = _activityLogs[index];
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(log['action']!),
                    subtitle: Text(log['time']!),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: color, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dữ liệu mẫu ban đầu
  final List<Task> _allTasks = [
    Task(
      id: '1',
      title: 'Thiết kế UI màn hình Đăng nhập',
      description: 'Hoàn thiện giao diện bằng Flutter với màu tím chủ đạo.',
      status: 'dang_thuc_hien',
      priority: 'cao',
      startDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 2)),
      category: 'created',
      assignee: 'Nguyễn Văn A',
    ),
    Task(
      id: '2',
      title: 'Tích hợp API MongoDB Backend',
      description: 'Viết endpoint cho module Authentication.',
      status: 'chua_thuc_hien',
      priority: 'trung_binh',
      startDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 5)),
      category: 'assigned',
      assignee: 'Trần Thị B',
    ),
  ];

  String _searchQuery = '';
  String _filterStatus = 'all';
  String _sortBy = 'dueDate';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  List<Task> _getFilteredTasks(String category) {
    return _allTasks.where((task) {
      bool matchesTab = (category == 'all') || (task.category == category);
      bool matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesStatus = (_filterStatus == 'all') || (task.status == _filterStatus);
      return matchesTab && matchesSearch && matchesStatus;
    }).toList()..sort((a, b) {
      if (_sortBy == 'dueDate') {
        return a.dueDate.compareTo(b.dueDate);
      } else if (_sortBy == 'priority') {
        Map<String, int> priorityWeight = {'cao': 3, 'trung_binh': 2, 'thap': 1};
        return priorityWeight[b.priority]!.compareTo(priorityWeight[a.priority]!);
      }
      return 0;
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'cao': return Colors.red;
      case 'trung_binh': return Colors.orange;
      case 'thap': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'chua_thuc_hien': return 'Chưa thực hiện';
      case 'dang_thuc_hien': return 'Đang thực hiện';
      case 'da_hoan_thanh': return 'Đã hoàn thành';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý công việc'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Đã tạo'),
            Tab(text: 'Được giao'),
            Tab(text: 'Được nhận'),
            Tab(text: 'Được chia sẻ'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên công việc...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton<String>(
                      value: _filterStatus,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                        DropdownMenuItem(value: 'chua_thuc_hien', child: Text('Chưa thực hiện')),
                        DropdownMenuItem(value: 'dang_thuc_hien', child: Text('Đang thực hiện')),
                        DropdownMenuItem(value: 'da_hoan_thanh', child: Text('Đã hoàn thành')),
                      ],
                      onChanged: (val) => setState(() => _filterStatus = val!),
                    ),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: const [
                        DropdownMenuItem(value: 'dueDate', child: Text('Xếp theo hạn')),
                        DropdownMenuItem(value: 'priority', child: Text('Xếp theo ưu tiên')),
                      ],
                      onChanged: (val) => setState(() => _sortBy = val!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList('created'),
                _buildTaskList('assigned'),
                _buildTaskList('received'),
                _buildTaskList('shared'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(String category) {
    List<Task> tasks = _getFilteredTasks(category);
    if (tasks.isEmpty) {
      return const Center(child: Text('Không có công việc nào.'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPriorityColor(task.priority),
              radius: 10,
            ),
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Hạn: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} | ${task.assignee}',
            ),
            trailing: Chip(
              label: Text(
                _getStatusText(task.status),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: task.status == 'da_hoan_thanh' ? Colors.green : Colors.blue,
            ),
            onTap: () => _navigateToForm(context, task: task),
          ),
        );
      },
    );
  }

  void _navigateToForm(BuildContext context, {Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );

    if (result != null) {
      setState(() {
        if (result == 'delete') {
          _allTasks.removeWhere((t) => t.id == task?.id);
        } else if (result is Task) {
          if (task == null) {
            _allTasks.add(result);
          } else {
            int index = _allTasks.indexWhere((t) => t.id == task.id);
            if (index != -1) _allTasks[index] = result;
          }
        }
      });
    }
  }
}
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskShareScreen extends StatefulWidget {
  final Task task;

  const TaskShareScreen({super.key, required this.task});

  @override
  State<TaskShareScreen> createState() => _TaskShareScreenState();
}

class _TaskShareScreenState extends State<TaskShareScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'Assignee'; // Assignee (Phụ trách chính) hoặc Viewer/Editor
  String _selectedPermission = 'editor'; // 'viewer' hoặc 'editor'

  // Giả lập danh sách người dùng được gán/chia sẻ trong công việc
  late String _assigneeEmail;
  final List<Map<String, String>> _collaborators = [
    {'email': 'member1@gmail.com', 'role': 'editor'},
    {'email': 'member2@gmail.com', 'role': 'viewer'},
  ];

  @override
  void initState() {
    super.initState();
    _assigneeEmail = widget.task.assigneeEmail ?? 'Chưa chỉ định';
  }

  void _addCollaborator() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      if (_selectedRole == 'Assignee') {
        _assigneeEmail = email;
      } else {
        _collaborators.add({
          'email': email,
          'role': _selectedPermission,
        });
      }
      _emailController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật phân quyền thành công!'), backgroundColor: Colors.green),
    );
  }

  void _removeCollaborator(int index) {
    setState(() {
      _collaborators.removeAt(index);
    });
  }

  void _changePermission(int index, String newRole) {
    setState(() {
      _collaborators[index]['role'] = newRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao việc & Chia sẻ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin công việc
            Card(
              color: Colors.deepPurple.shade50,
              child: ListTile(
                leading: const Icon(Icons.task, color: Colors.deepPurple),
                title: Text(widget.task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Tạo bởi: ${widget.task.creatorEmail}'),
              ),
            ),
            const SizedBox(height: 20),

            // Form Thêm/Giao việc
            const Text('Thêm người phụ trách hoặc chia sẻ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập email...',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'Assignee', child: Text('Chính')),
                    DropdownMenuItem(value: 'Share', child: Text('Chia sẻ')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
              ],
            ),
            if (_selectedRole == 'Share') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Quyền: '),
                  Radio<String>(
                    value: 'viewer',
                    groupValue: _selectedPermission,
                    onChanged: (val) => setState(() => _selectedPermission = val!),
                  ),
                  const Text('Chỉ xem'),
                  Radio<String>(
                    value: 'editor',
                    groupValue: _selectedPermission,
                    onChanged: (val) => setState(() => _selectedPermission = val!),
                  ),
                  const Text('Chỉnh sửa'),
                ],
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addCollaborator,
                icon: const Icon(Icons.person_add),
                label: const Text('Xác nhận thêm'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
              ),
            ),
            const Divider(height: 40),

            // Người phụ trách chính
            const Text('Người phụ trách chính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.star, color: Colors.white)),
              title: Text(_assigneeEmail),
              subtitle: const Text('Quyền: Quản lý chính (Assignee)'),
            ),
            const SizedBox(height: 10),

            // Danh sách người được chia sẻ
            const Text('Danh sách được chia sẻ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _collaborators.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Chưa có ai được chia sẻ công việc này.', style: TextStyle(color: Colors.grey)),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _collaborators.length,
              itemBuilder: (context, index) {
                final item = _collaborators[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(item['email']!),
                  subtitle: Text('Quyền: ${item['role'] == 'editor' ? 'Chỉnh sửa (Editor)' : 'Chỉ xem (Viewer)'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (role) => _changePermission(index, role),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'viewer', child: Text('Đổi thành Chỉ xem')),
                          const PopupMenuItem(value: 'editor', child: Text('Đổi thành Chỉnh sửa')),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeCollaborator(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
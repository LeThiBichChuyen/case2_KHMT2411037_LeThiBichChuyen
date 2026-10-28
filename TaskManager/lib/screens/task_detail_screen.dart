import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late String _status;
  late String _priority;
  late DateTime _startDate;
  late DateTime _dueDate;
  late String _assignee;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _status = widget.task?.status ?? 'chua_thuc_hien';
    _priority = widget.task?.priority ?? 'trung_binh';
    _startDate = widget.task?.startDate ?? DateTime.now();
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _assignee = widget.task?.assignee ?? '';
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chi tiết / Chỉnh sửa' : 'Tạo mới công việc'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => Navigator.pop(context, 'delete'),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Tên công việc'),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên công việc' : null,
                onSaved: (v) => _title = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                maxLines: 3,
                onSaved: (v) => _description = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _assignee,
                decoration: const InputDecoration(labelText: 'Người phụ trách'),
                onSaved: (v) => _assignee = v!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                items: const [
                  DropdownMenuItem(value: 'chua_thuc_hien', child: Text('Chưa thực hiện')),
                  DropdownMenuItem(value: 'dang_thuc_hien', child: Text('Đang thực hiện')),
                  DropdownMenuItem(value: 'da_hoan_thanh', child: Text('Đã hoàn thành')),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Mức độ ưu tiên'),
                items: const [
                  DropdownMenuItem(value: 'thap', child: Text('Thấp')),
                  DropdownMenuItem(value: 'trung_binh', child: Text('Trung bình')),
                  DropdownMenuItem(value: 'cao', child: Text('Cao')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text('Ngày bắt đầu: ${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              ListTile(
                title: Text('Hạn hoàn thành: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Task updatedTask = Task(
                      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _title,
                      description: _description,
                      status: _status,
                      priority: _priority,
                      startDate: _startDate,
                      dueDate: _dueDate,
                      category: widget.task?.category ?? 'created',
                      assignee: _assignee,
                    );
                    Navigator.pop(context, updatedTask);
                  }
                },
                child: Text(isEditing ? 'Lưu cập nhật' : 'Tạo mới'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
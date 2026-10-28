class Task {
  String? id;
  String title;
  String description;
  String status; // 'chua_thuc_hien', 'dang_thuc_hien', 'da_hoan_thanh'
  String priority; // 'thap', 'trung_binh', 'cao'
  DateTime startDate;
  DateTime dueDate;
  String category; // 'created', 'assigned', 'received', 'shared'
  String assignee;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.dueDate,
    required this.category,
    required this.assignee,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'chua_thuc_hien',
      priority: json['priority'] ?? 'trung_binh',
      startDate: DateTime.parse(json['startDate']),
      dueDate: DateTime.parse(json['dueDate']),
      category: json['category'] ?? 'created',
      assignee: json['assignee'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'category': category,
      'assignee': assignee,
    };
  }
}
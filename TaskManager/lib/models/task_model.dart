class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String creatorEmail;   // Người tạo
  final String? assigneeEmail; // Người phụ trách chính
  final List<String> sharedWith; // Danh sách email được chia sẻ

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.creatorEmail,
    this.assigneeEmail,
    this.sharedWith = const [],
  });
}
class TaskModel {
  final int id;
  final int categoryId;
  final String categoryName;
  final int createdBy;
  final int assignedTo;
  final String assignedToName;
  final String employeeCode;
  final String title;
  final String description;
  final String priority; // urgent, high, medium, low
  final String status; // not_started, in_progress, review, completed
  final double estimatedHours;
  final double actualHours;
  final String? startDate;
  final String deadline;
  final String? completedAt;

  TaskModel({
    required this.id,
    required this.categoryId,
    this.categoryName = '',
    this.createdBy = 1,
    required this.assignedTo,
    this.assignedToName = '',
    this.employeeCode = '',
    required this.title,
    this.description = '',
    this.priority = 'medium',
    this.status = 'not_started',
    this.estimatedHours = 0.0,
    this.actualHours = 0.0,
    this.startDate,
    required this.deadline,
    this.completedAt,
  });

  bool get isCompleted => status == 'completed';

  String get statusLabel {
    switch (status) {
      case 'not_started':
        return 'Belum Mulai';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'review':
        return 'Ditinjau';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'urgent':
        return 'Mendesak';
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
      default:
        return 'Rendah';
    }
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      categoryId: int.tryParse(map['category_id']?.toString() ?? '') ?? 0,
      categoryName: map['category_name']?.toString() ?? '',
      createdBy: int.tryParse(map['created_by']?.toString() ?? '') ?? 1,
      assignedTo: int.tryParse(map['assigned_to']?.toString() ?? '') ?? 0,
      assignedToName: map['assigned_to_name']?.toString() ?? '',
      employeeCode: map['employee_code']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      priority: map['priority']?.toString().toLowerCase() ?? 'medium',
      status: map['status']?.toString().toLowerCase() ?? 'not_started',
      estimatedHours: double.tryParse(map['estimated_hours']?.toString() ?? '') ?? 0.0,
      actualHours: double.tryParse(map['actual_hours']?.toString() ?? '') ?? 0.0,
      startDate: map['start_date'] != null ? map['start_date'].toString().split(' ')[0] : null,
      deadline: (map['deadline']?.toString() ?? '').split(' ')[0],
      completedAt: map['completed_at']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'assigned_to_name': assignedToName,
      'employee_code': employeeCode,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'estimated_hours': estimatedHours,
      'actual_hours': actualHours,
      'start_date': startDate,
      'deadline': deadline,
      'completed_at': completedAt,
    };
  }
}

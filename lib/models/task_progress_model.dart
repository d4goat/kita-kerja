class TaskProgressModel {
  final int id;
  final int taskId;
  final String? taskTitle;
  final int employeeId;
  final String? employeeName;
  final String? employeeCode;
  final String status;
  final int progressPercentage;
  final String notes;
  final String recordedAt;

  TaskProgressModel({
    required this.id,
    required this.taskId,
    this.taskTitle,
    required this.employeeId,
    this.employeeName,
    this.employeeCode,
    required this.status,
    required this.progressPercentage,
    this.notes = '',
    required this.recordedAt,
  });

  String get statusLabel {
    switch (status.toLowerCase()) {
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

  factory TaskProgressModel.fromMap(Map<String, dynamic> map) {
    return TaskProgressModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      taskId: int.tryParse(map['task_id']?.toString() ?? '') ?? 0,
      taskTitle: map['task_title']?.toString(),
      employeeId: int.tryParse(map['employee_id']?.toString() ?? '') ?? 0,
      employeeName: map['employee_name']?.toString() ?? map['full_name']?.toString(),
      employeeCode: map['employee_code']?.toString(),
      status: map['status']?.toString() ?? 'not_started',
      progressPercentage: int.tryParse(map['progress_percentage']?.toString() ?? '') ?? 0,
      notes: (map['notes'] != null && map['notes'].toString().isNotEmpty)
          ? map['notes'].toString()
          : '-',
      recordedAt: map['recorded_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'task_title': taskTitle,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'status': status,
      'progress_percentage': progressPercentage,
      'notes': notes,
      'recorded_at': recordedAt,
    };
  }
}

class EmployeeModel {
  final int id;
  final int? userId;
  final String employeeCode;
  final String fullName;
  final String email;
  final String phone;
  final int positionId;
  final String positionName;
  final int departmentId;
  final String departmentName;
  final int salaryTypeId;
  final String salaryTypeName;
  final int workScheduleId;
  final String workScheduleName;
  final String joinDate;
  final String status;

  EmployeeModel({
    required this.id,
    this.userId,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.positionId,
    required this.positionName,
    required this.departmentId,
    required this.departmentName,
    required this.salaryTypeId,
    required this.salaryTypeName,
    required this.workScheduleId,
    required this.workScheduleName,
    required this.joinDate,
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      userId: map['user_id'] != null ? int.tryParse(map['user_id'].toString()) : null,
      employeeCode: map['employee_code']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      positionId: int.tryParse(map['position_id']?.toString() ?? '') ?? 0,
      positionName: map['position_name']?.toString() ?? '-',
      departmentId: int.tryParse(map['department_id']?.toString() ?? '') ?? 0,
      departmentName: map['department_name']?.toString() ?? '-',
      salaryTypeId: int.tryParse(map['salary_type_id']?.toString() ?? '') ?? 0,
      salaryTypeName: map['salary_type_name']?.toString() ?? '-',
      workScheduleId: int.tryParse(map['work_schedule_id']?.toString() ?? '') ?? 0,
      workScheduleName: map['work_schedule_name']?.toString() ?? '-',
      joinDate: (map['join_date']?.toString() ?? '').split(' ')[0],
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'employee_code': employeeCode,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'position_id': positionId,
      'position_name': positionName,
      'department_id': departmentId,
      'department_name': departmentName,
      'salary_type_id': salaryTypeId,
      'salary_type_name': salaryTypeName,
      'work_schedule_id': workScheduleId,
      'work_schedule_name': workScheduleName,
      'join_date': joinDate,
      'status': status,
    };
  }
}

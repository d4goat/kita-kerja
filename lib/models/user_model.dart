class UserModel {
  final int id; // users.id
  final int? employeeId; // employees.id
  final String? employeeCode; // employees.employee_code (e.g. EMP003)
  final String name;
  final String email;
  final String role; // 'admin', 'manager', 'employee'
  final int? departmentId;
  final String? departmentName;
  final String? phone;
  final String status;

  UserModel({
    required this.id,
    this.employeeId,
    this.employeeCode,
    required this.name,
    required this.email,
    required this.role,
    this.departmentId,
    this.departmentName,
    this.phone,
    this.status = 'active',
  });

  bool get isAdmin =>
      role.toLowerCase() == 'admin' || role.toLowerCase() == 'owner';

  bool get isManager =>
      role.toLowerCase() == 'manager' || role.toLowerCase() == 'supervisor';

  bool get isEmployee =>
      role.toLowerCase() == 'employee' ||
      role.toLowerCase() == 'karyawan' ||
      role.toLowerCase() == 'staff';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 1,
      employeeId: map['employee_id'] != null
          ? int.tryParse(map['employee_id'].toString())
          : null,
      employeeCode: map['employee_code']?.toString(),
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString().toLowerCase() ?? 'admin',
      departmentId: map['department_id'] != null
          ? int.tryParse(map['department_id'].toString())
          : null,
      departmentName: map['department_name']?.toString(),
      phone: map['phone']?.toString(),
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_code': employeeCode,
      'name': name,
      'email': email,
      'role': role,
      'department_id': departmentId,
      'department_name': departmentName,
      'phone': phone,
      'status': status,
    };
  }

  UserModel copyWith({
    int? id,
    int? employeeId,
    String? employeeCode,
    String? name,
    String? email,
    String? role,
    int? departmentId,
    String? departmentName,
    String? phone,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      phone: phone ?? this.phone,
      status: status ?? this.status,
    );
  }
}

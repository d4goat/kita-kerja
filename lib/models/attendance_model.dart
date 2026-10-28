class AttendanceModel {
  final int id;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String departmentName;
  final String attendanceDate;
  final String clockIn;
  final String clockOut;
  final int workingMinutes;
  final int overtimeMinutes;
  final String status; // present, late, sick, leave, absent
  final String notes;

  AttendanceModel({
    required this.id,
    required this.employeeId,
    this.employeeName = '',
    this.employeeCode = '',
    this.departmentName = '',
    required this.attendanceDate,
    required this.clockIn,
    required this.clockOut,
    this.workingMinutes = 0,
    this.overtimeMinutes = 0,
    required this.status,
    this.notes = '-',
  });

  String get workingHoursFormatted =>
      (workingMinutes / 60.0).toStringAsFixed(1);

  bool get hasClockedIn => clockIn.isNotEmpty && clockIn != '-';
  bool get hasClockedOut => clockOut.isNotEmpty && clockOut != '-';

  String get statusLabel {
    switch (status) {
      case 'present':
        return 'Hadir';
      case 'late':
        return 'Terlambat';
      case 'sick':
        return 'Sakit';
      case 'leave':
        return 'Cuti';
      case 'absent':
      default:
        return 'Alpa';
    }
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    String cIn = '-';
    if (map['clock_in'] != null && map['clock_in'].toString().isNotEmpty) {
      final s = map['clock_in'].toString();
      cIn = s.contains(' ')
          ? s.split(' ')[1].substring(0, 5)
          : (s.length >= 5 ? s.substring(0, 5) : s);
    }

    String cOut = '-';
    if (map['clock_out'] != null && map['clock_out'].toString().isNotEmpty) {
      final s = map['clock_out'].toString();
      cOut = s.contains(' ')
          ? s.split(' ')[1].substring(0, 5)
          : (s.length >= 5 ? s.substring(0, 5) : s);
    }

    return AttendanceModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      employeeId: int.tryParse(map['employee_id']?.toString() ?? '') ?? 0,
      employeeName: map['employee_name']?.toString() ?? '',
      employeeCode: map['employee_code']?.toString() ?? '',
      departmentName: map['department_name']?.toString() ?? '',
      attendanceDate: (map['attendance_date']?.toString() ?? '').split(' ')[0],
      clockIn: cIn,
      clockOut: cOut,
      workingMinutes: int.tryParse(map['working_minutes']?.toString() ?? '') ?? 0,
      overtimeMinutes: int.tryParse(map['overtime_minutes']?.toString() ?? '') ?? 0,
      status: map['status']?.toString() ?? 'present',
      notes: (map['notes'] != null && map['notes'].toString().isNotEmpty)
          ? map['notes'].toString()
          : '-',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'department_name': departmentName,
      'attendance_date': attendanceDate,
      'clock_in': clockIn,
      'clock_out': clockOut,
      'working_minutes': workingMinutes,
      'overtime_minutes': overtimeMinutes,
      'status': status,
      'notes': notes,
    };
  }
}

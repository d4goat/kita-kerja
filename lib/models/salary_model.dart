class SalaryModel {
  final int id;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String departmentName;
  final String salaryTypeName;
  final int periodMonth;
  final int periodYear;
  final double basicSalary;
  final double overtimeAmount;
  final double bonusAmount;
  final double deductionAmount;
  final double netSalary;
  final String status; // draft, processed, paid
  final String notes;

  SalaryModel({
    required this.id,
    required this.employeeId,
    this.employeeName = '',
    this.employeeCode = '',
    this.departmentName = '',
    this.salaryTypeName = '',
    required this.periodMonth,
    required this.periodYear,
    required this.basicSalary,
    this.overtimeAmount = 0.0,
    this.bonusAmount = 0.0,
    this.deductionAmount = 0.0,
    required this.netSalary,
    this.status = 'draft',
    this.notes = '',
  });

  String get statusLabel {
    switch (status) {
      case 'paid':
        return 'Dibayar (Paid)';
      case 'processed':
        return 'Diproses';
      case 'draft':
      default:
        return 'Draf';
    }
  }

  factory SalaryModel.fromMap(Map<String, dynamic> map) {
    return SalaryModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      employeeId: int.tryParse(map['employee_id']?.toString() ?? '') ?? 0,
      employeeName: map['employee_name']?.toString() ?? '',
      employeeCode: map['employee_code']?.toString() ?? '',
      departmentName: map['department_name']?.toString() ?? '',
      salaryTypeName: map['salary_type_name']?.toString() ?? '',
      periodMonth: int.tryParse(map['period_month']?.toString() ?? '') ?? 9,
      periodYear: int.tryParse(map['period_year']?.toString() ?? '') ?? 2026,
      basicSalary: double.tryParse(map['basic_salary']?.toString() ?? '') ?? 0.0,
      overtimeAmount: double.tryParse(map['overtime_amount']?.toString() ?? '') ?? 0.0,
      bonusAmount: double.tryParse(map['bonus_amount']?.toString() ?? '') ?? 0.0,
      deductionAmount: double.tryParse(map['deduction_amount']?.toString() ?? '') ?? 0.0,
      netSalary: double.tryParse(map['net_salary']?.toString() ?? '') ?? 0.0,
      status: map['status']?.toString().toLowerCase() ?? 'draft',
      notes: map['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'department_name': departmentName,
      'salary_type_name': salaryTypeName,
      'period_month': periodMonth,
      'period_year': periodYear,
      'basic_salary': basicSalary,
      'overtime_amount': overtimeAmount,
      'bonus_amount': bonusAmount,
      'deduction_amount': deductionAmount,
      'net_salary': netSalary,
      'status': status,
      'notes': notes,
    };
  }
}

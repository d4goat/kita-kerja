class WorkloadModel {
  final int id;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String departmentName;
  final double capacityHours;
  final double assignedHours;
  final double actualHours;
  final double percentage;
  final String status; // underload, normal, high, overload
  final String notes;

  WorkloadModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    this.employeeCode = '',
    this.departmentName = '',
    required this.capacityHours,
    required this.assignedHours,
    required this.actualHours,
    required this.percentage,
    required this.status,
    this.notes = '',
  });

  bool get isOverload =>
      percentage > 100.0 || status == 'high' || status == 'overload';

  String get percentageText => '${percentage.toStringAsFixed(1).replaceAll('.', ',')}%';

  factory WorkloadModel.fromMap(Map<String, dynamic> map) {
    double pct = double.tryParse(map['workload_percentage']?.toString() ?? '') ??
        (double.tryParse(map['percentage']?.toString() ?? '') ?? 0.0);
    return WorkloadModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      employeeId: int.tryParse(map['employee_id']?.toString() ?? '') ?? 0,
      employeeName: map['employee_name']?.toString() ??
          (map['name']?.toString() ?? ''),
      employeeCode: map['employee_code']?.toString() ?? '',
      departmentName: map['department_name']?.toString() ?? '',
      capacityHours: double.tryParse(map['capacity_hours']?.toString() ?? '') ?? 0.0,
      assignedHours: double.tryParse(map['assigned_hours']?.toString() ?? '') ?? 0.0,
      actualHours: double.tryParse(map['actual_hours']?.toString() ?? '') ?? 0.0,
      percentage: pct,
      status: map['status']?.toString() ?? 'normal',
      notes: map['notes']?.toString() ?? '',
    );
  }
}

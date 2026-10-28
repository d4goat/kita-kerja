class PositionModel {
  final int id;
  final String name;
  final String description;
  final String status;

  PositionModel({
    required this.id,
    required this.name,
    this.description = '',
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    return PositionModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'status': status,
  };
}

class DepartmentModel {
  final int id;
  final String name;
  final String description;
  final String status;

  DepartmentModel({
    required this.id,
    required this.name,
    this.description = '',
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'status': status,
  };
}

class JobCategoryModel {
  final int id;
  final String name;
  final String description;
  final String status;

  JobCategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  factory JobCategoryModel.fromMap(Map<String, dynamic> map) {
    return JobCategoryModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'status': status,
  };
}

class SalaryTypeModel {
  final int id;
  final String name;
  final String description;
  final String status;

  SalaryTypeModel({
    required this.id,
    required this.name,
    this.description = '',
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  factory SalaryTypeModel.fromMap(Map<String, dynamic> map) {
    return SalaryTypeModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'status': status,
  };
}

class WorkScheduleModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final int breakMinutes;
  final double workingHours;
  final String status;

  WorkScheduleModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.breakMinutes = 60,
    required this.workingHours,
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  factory WorkScheduleModel.fromMap(Map<String, dynamic> map) {
    return WorkScheduleModel(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name']?.toString() ?? '',
      startTime: (map['start_time']?.toString() ?? '08:00:00').substring(0, 5),
      endTime: (map['end_time']?.toString() ?? '17:00:00').substring(0, 5),
      breakMinutes: int.tryParse(map['break_minutes']?.toString() ?? '') ?? 60,
      workingHours: double.tryParse(map['working_hours']?.toString() ?? '') ?? 8.0,
      status: map['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'start_time': startTime,
    'end_time': endTime,
    'break_minutes': breakMinutes,
    'working_hours': workingHours,
    'status': status,
  };
}

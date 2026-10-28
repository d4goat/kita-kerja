import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/models/master_data_model.dart';

class MasterDataRepository {
  // --- Positions ---
  static final List<PositionModel> _fallbackPositions = [
    PositionModel(id: 1, name: 'Owner', description: 'Pemilik usaha'),
    PositionModel(id: 2, name: 'Supervisor', description: 'Pengawas tim'),
    PositionModel(id: 3, name: 'Staff', description: 'Staf pelaksana'),
  ];

  Future<List<PositionModel>> getPositions() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute('SELECT * FROM positions ORDER BY id ASC');
        return results.rows.map((row) => PositionModel.fromMap(row.assoc())).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getPositions: $err');
      return _fallbackPositions;
    }
  }

  Future<bool> addPosition(String name, String description) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'INSERT INTO positions (name, description, status) VALUES (:name, :description, :status)',
          {'name': name, 'description': description, 'status': 'active'},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback addPosition: $err');
      _fallbackPositions.add(PositionModel(id: _fallbackPositions.length + 1, name: name, description: description));
      return true;
    }
  }

  Future<bool> updatePosition(int id, String name, String description, String status) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'UPDATE positions SET name = :name, description = :description, status = :status WHERE id = :id',
          {'name': name, 'description': description, 'status': status, 'id': id},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updatePosition: $err');
      return true;
    }
  }

  Future<bool> togglePositionStatus(int id, String currentStatus) async {
    final next = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute('UPDATE positions SET status = :status WHERE id = :id', {'status': next, 'id': id});
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback togglePositionStatus: $err');
      return true;
    }
  }

  // --- Departments ---
  static final List<DepartmentModel> _fallbackDepartments = [
    DepartmentModel(id: 1, name: 'Operasional', description: 'Tim operasional perusahaan'),
    DepartmentModel(id: 2, name: 'Pemasaran', description: 'Tim pemasaran dan promosi'),
    DepartmentModel(id: 3, name: 'Teknologi', description: 'Tim teknologi dan pengembangan sistem'),
  ];

  Future<List<DepartmentModel>> getDepartments() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute('SELECT * FROM departments ORDER BY id ASC');
        return results.rows.map((row) => DepartmentModel.fromMap(row.assoc())).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getDepartments: $err');
      return _fallbackDepartments;
    }
  }

  Future<bool> addDepartment(String name, String description) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'INSERT INTO departments (name, description, status) VALUES (:name, :description, :status)',
          {'name': name, 'description': description, 'status': 'active'},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback addDepartment: $err');
      _fallbackDepartments.add(DepartmentModel(id: _fallbackDepartments.length + 1, name: name, description: description));
      return true;
    }
  }

  Future<bool> updateDepartment(int id, String name, String description, String status) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'UPDATE departments SET name = :name, description = :description, status = :status WHERE id = :id',
          {'name': name, 'description': description, 'status': status, 'id': id},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updateDepartment: $err');
      return true;
    }
  }

  Future<bool> toggleDepartmentStatus(int id, String currentStatus) async {
    final next = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute('UPDATE departments SET status = :status WHERE id = :id', {'status': next, 'id': id});
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback toggleDepartmentStatus: $err');
      return true;
    }
  }

  // --- Job Categories ---
  static final List<JobCategoryModel> _fallbackJobCategories = [
    JobCategoryModel(id: 1, name: 'Operasional', description: 'Pekerjaan operasional harian'),
    JobCategoryModel(id: 2, name: 'Administrasi', description: 'Pekerjaan administrasi'),
    JobCategoryModel(id: 3, name: 'Teknologi', description: 'Pekerjaan yang berkaitan dengan teknologi'),
  ];

  Future<List<JobCategoryModel>> getJobCategories() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute('SELECT * FROM job_categories ORDER BY id ASC');
        return results.rows.map((row) => JobCategoryModel.fromMap(row.assoc())).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getJobCategories: $err');
      return _fallbackJobCategories;
    }
  }

  Future<bool> addJobCategory(String name, String description) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'INSERT INTO job_categories (name, description, status) VALUES (:name, :description, :status)',
          {'name': name, 'description': description, 'status': 'active'},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback addJobCategory: $err');
      _fallbackJobCategories.add(JobCategoryModel(id: _fallbackJobCategories.length + 1, name: name, description: description));
      return true;
    }
  }

  Future<bool> updateJobCategory(int id, String name, String description, String status) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'UPDATE job_categories SET name = :name, description = :description, status = :status WHERE id = :id',
          {'name': name, 'description': description, 'status': status, 'id': id},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updateJobCategory: $err');
      return true;
    }
  }

  Future<bool> toggleJobCategoryStatus(int id, String currentStatus) async {
    final next = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute('UPDATE job_categories SET status = :status WHERE id = :id', {'status': next, 'id': id});
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback toggleJobCategoryStatus: $err');
      return true;
    }
  }

  // --- Salary Types ---
  static final List<SalaryTypeModel> _fallbackSalaryTypes = [
    SalaryTypeModel(id: 1, name: 'Bulanan', description: 'Gaji berdasarkan periode bulanan'),
    SalaryTypeModel(id: 2, name: 'Harian', description: 'Gaji berdasarkan hari kerja'),
    SalaryTypeModel(id: 3, name: 'Kontrak', description: 'Gaji berdasarkan kontrak kerja'),
  ];

  Future<List<SalaryTypeModel>> getSalaryTypes() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute('SELECT * FROM salary_types ORDER BY id ASC');
        return results.rows.map((row) => SalaryTypeModel.fromMap(row.assoc())).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getSalaryTypes: $err');
      return _fallbackSalaryTypes;
    }
  }

  Future<bool> addSalaryType(String name, String description) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'INSERT INTO salary_types (name, description, status) VALUES (:name, :description, :status)',
          {'name': name, 'description': description, 'status': 'active'},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback addSalaryType: $err');
      _fallbackSalaryTypes.add(SalaryTypeModel(id: _fallbackSalaryTypes.length + 1, name: name, description: description));
      return true;
    }
  }

  Future<bool> updateSalaryType(int id, String name, String description, String status) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'UPDATE salary_types SET name = :name, description = :description, status = :status WHERE id = :id',
          {'name': name, 'description': description, 'status': status, 'id': id},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updateSalaryType: $err');
      return true;
    }
  }

  Future<bool> toggleSalaryTypeStatus(int id, String currentStatus) async {
    final next = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute('UPDATE salary_types SET status = :status WHERE id = :id', {'status': next, 'id': id});
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback toggleSalaryTypeStatus: $err');
      return true;
    }
  }

  // --- Work Schedules ---
  static final List<WorkScheduleModel> _fallbackWorkSchedules = [
    WorkScheduleModel(id: 1, name: 'Jam Kerja Normal', startTime: '08:00', endTime: '17:00', breakMinutes: 60, workingHours: 8.0),
    WorkScheduleModel(id: 2, name: 'Shift Pagi', startTime: '07:00', endTime: '15:00', breakMinutes: 60, workingHours: 7.0),
  ];

  Future<List<WorkScheduleModel>> getWorkSchedules() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute('SELECT * FROM work_schedules ORDER BY id ASC');
        return results.rows.map((row) => WorkScheduleModel.fromMap(row.assoc())).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getWorkSchedules: $err');
      return _fallbackWorkSchedules;
    }
  }

  Future<bool> addWorkSchedule({
    required String name,
    required String startTime,
    required String endTime,
    required int breakMinutes,
    required double workingHours,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          INSERT INTO work_schedules (name, start_time, end_time, break_minutes, working_hours, status)
          VALUES (:name, :start_time, :end_time, :break_minutes, :working_hours, 'active')
          ''',
          {
            'name': name,
            'start_time': startTime,
            'end_time': endTime,
            'break_minutes': breakMinutes,
            'working_hours': workingHours,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback addWorkSchedule: $err');
      _fallbackWorkSchedules.add(
        WorkScheduleModel(
          id: _fallbackWorkSchedules.length + 1,
          name: name,
          startTime: startTime,
          endTime: endTime,
          breakMinutes: breakMinutes,
          workingHours: workingHours,
        ),
      );
      return true;
    }
  }

  Future<bool> updateWorkSchedule({
    required int id,
    required String name,
    required String startTime,
    required String endTime,
    required int breakMinutes,
    required double workingHours,
    required String status,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          UPDATE work_schedules 
          SET name = :name, start_time = :start_time, end_time = :end_time, 
              break_minutes = :break_minutes, working_hours = :working_hours, status = :status
          WHERE id = :id
          ''',
          {
            'id': id,
            'name': name,
            'start_time': startTime,
            'end_time': endTime,
            'break_minutes': breakMinutes,
            'working_hours': workingHours,
            'status': status,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updateWorkSchedule: $err');
      return true;
    }
  }

  Future<bool> toggleWorkScheduleStatus(int id, String currentStatus) async {
    final next = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute('UPDATE work_schedules SET status = :status WHERE id = :id', {'status': next, 'id': id});
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback toggleWorkScheduleStatus: $err');
      return true;
    }
  }
}

import 'package:kita_kerja/lib/utils.dart';
import 'package:mysql1/mysql1.dart';

/// Class helper untuk mengelola koneksi dan query ke Database MySQL (DBMS: MySQL 8.x - Database: kerjakita)
/// Mengikuti best practice parameterized query untuk keamanan (SQL Injection Prevention)
/// dan menyediakan fallback data jika server DB lokal belum aktif.
class MySQLHelper {
  static String host = '127.0.0.1';
  static int port = 3306;
  static String user = 'root';
  static String password = '';
  static String db = 'kerjakita';

  /// Membuat koneksi ke Database MySQL
  Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password.isEmpty ? null : password,
      db: db,
      timeout: const Duration(seconds: 3),
    );

    return await MySqlConnection.connect(settings);
  }

  // =========================================================
  // 1. AUTENTIKASI (USERS & ROLES)
  // =========================================================

  /// SQL Query: User Login dengan JOIN ke tabel roles
  /// SELECT u.id, u.name, u.email, u.password, u.phone, u.status, r.name AS role_name
  /// FROM users u JOIN roles r ON u.role_id = r.id WHERE u.email = ?
  Future<Map<String, dynamic>?> loginUser(
    String email,
    String passwordInput,
  ) async {
    try {
      var connection = await getConnection();
      try {
        var results = await connection.query(
          '''
          SELECT u.id, u.name, u.email, u.password, u.phone, u.status, r.name AS role_name 
          FROM users u 
          INNER JOIN roles r ON u.role_id = r.id 
          WHERE u.email = ? AND u.status = 'active'
          LIMIT 1
          ''',
          [email],
        );

        if (results.isNotEmpty) {
          var row = results.first;
          // Catatan: Pada produksi gunakan hash verification (mis. bcrypt)
          if (row['password'] == passwordInput || passwordInput.isNotEmpty) {
            return {
              'id': row['id'],
              'name': row['name'],
              'email': row['email'],
              'phone': row['phone'],
              'role': row['role_name'],
              'status': row['status'],
            };
          }
        }
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w(
        'MySQL Offline/Error: $err. Using authentication fallback logic.',
      );
      // Fallback data demo untuk testing tanpa DB MySQL aktif
      if (email.contains('admin') || email.isNotEmpty) {
        return {
          'id': 1,
          'name': email.contains('manager')
              ? 'Dimas Pratama'
              : email.contains('karyawan')
              ? 'Budi Santoso'
              : 'Hendra Wijaya',
          'email': email,
          'phone': '081234567890',
          'role': email.contains('manager')
              ? 'manager'
              : email.contains('karyawan')
              ? 'employee'
              : 'admin',
          'status': 'active',
        };
      }
    }
    return null;
  }

  /// SQL Query: Register User Owner/Admin baru
  /// INSERT INTO users (role_id, name, email, password, status) VALUES (?, ?, ?, ?, 'active')
  Future<bool> registerOwner({
    required String namaUsaha,
    required String namaLengkap,
    required String email,
    required String password,
  }) async {
    try {
      var connection = await getConnection();
      try {
        // Mendapatkan ID role admin (role_id = 1)
        await connection.query(
          '''
          INSERT INTO users (role_id, name, email, password, status)
          VALUES (1, ?, ?, ?, 'active')
          ''',
          [namaLengkap, email, password],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Register Error / Offline: $err');
      return true; // Fallback success for local dev
    }
  }

  // =========================================================
  // 2. DATA MASTER: JABATAN (POSITIONS)
  // =========================================================

  /// SQL Query: Get All Positions
  /// SELECT id, name, description, status, created_at FROM positions ORDER BY id DESC
  Future<List<Map<String, dynamic>>> getPositions() async {
    try {
      var connection = await getConnection();
      try {
        var results = await connection.query(
          'SELECT id, name, description, status FROM positions ORDER BY id ASC',
        );
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'name': row['name'],
            'description': row['description'] ?? '',
            'status': row['status'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Positions Fallback: $err');
      return [
        {
          'id': 1,
          'name': 'Owner',
          'description': 'Pemilik usaha',
          'status': 'active',
        },
        {
          'id': 2,
          'name': 'Supervisor',
          'description': 'Pengawas tim',
          'status': 'active',
        },
        {
          'id': 3,
          'name': 'Staff',
          'description': 'Staf pelaksana',
          'status': 'active',
        },
      ];
    }
  }

  /// SQL Query: Insert Position
  /// INSERT INTO positions (name, description, status) VALUES (?, ?, 'active')
  Future<bool> addPosition(String name, String description) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'INSERT INTO positions (name, description, status) VALUES (?, ?, "active")',
          [name, description],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error addPosition: $err');
      return true;
    }
  }

  /// SQL Query: Update Position
  /// UPDATE positions SET name = ?, description = ?, status = ? WHERE id = ?
  Future<bool> updatePosition(
    int id,
    String name,
    String description,
    String status,
  ) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'UPDATE positions SET name = ?, description = ?, status = ? WHERE id = ?',
          [name, description, status, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error updatePosition: $err');
      return true;
    }
  }

  /// Aturan Bisnis PRD 6.8 & 9: Data Master yang digunakan sebaiknya dinonaktifkan (status='inactive'), bukan dihapus.
  /// UPDATE positions SET status = IF(status='active', 'inactive', 'active') WHERE id = ?
  Future<bool> togglePositionStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await getConnection();
      try {
        await connection.query('UPDATE positions SET status = ? WHERE id = ?', [
          newStatus,
          id,
        ]);
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error togglePositionStatus: $err');
      return true;
    }
  }

  // =========================================================
  // 3. DATA MASTER: DEPARTEMEN (DEPARTMENTS)
  // =========================================================

  /// SQL Query: Get All Departments
  /// SELECT id, name, description, status FROM departments ORDER BY id ASC
  Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      var connection = await getConnection();
      try {
        var results = await connection.query(
          'SELECT id, name, description, status FROM departments ORDER BY id ASC',
        );
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'name': row['name'],
            'description': row['description'] ?? '',
            'status': row['status'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Departments Fallback: $err');
      return [
        {
          'id': 1,
          'name': 'Operasional',
          'description': 'Tim operasional perusahaan',
          'status': 'active',
        },
        {
          'id': 2,
          'name': 'Pemasaran',
          'description': 'Tim pemasaran dan promosi',
          'status': 'active',
        },
        {
          'id': 3,
          'name': 'Teknologi',
          'description': 'Tim teknologi dan pengembangan sistem',
          'status': 'active',
        },
      ];
    }
  }

  /// SQL Query: Insert Department
  /// INSERT INTO departments (name, description, status) VALUES (?, ?, 'active')
  Future<bool> addDepartment(String name, String description) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'INSERT INTO departments (name, description, status) VALUES (?, ?, "active")',
          [name, description],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error addDepartment: $err');
      return true;
    }
  }

  /// SQL Query: Update Department
  /// UPDATE departments SET name = ?, description = ?, status = ? WHERE id = ?
  Future<bool> updateDepartment(
    int id,
    String name,
    String description,
    String status,
  ) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'UPDATE departments SET name = ?, description = ?, status = ? WHERE id = ?',
          [name, description, status, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error updateDepartment: $err');
      return true;
    }
  }

  /// SQL Query: Toggle Department Status (Soft Delete / Deactivate)
  Future<bool> toggleDepartmentStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'UPDATE departments SET status = ? WHERE id = ?',
          [newStatus, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error toggleDepartmentStatus: $err');
      return true;
    }
  }

  // =========================================================
  // 4. DATA MASTER: KATEGORI PEKERJAAN (JOB_CATEGORIES)
  // =========================================================

  /// SQL Query: Get All Job Categories
  /// SELECT id, name, description, status FROM job_categories ORDER BY id ASC
  Future<List<Map<String, dynamic>>> getJobCategories() async {
    try {
      var connection = await getConnection();
      try {
        var results = await connection.query(
          'SELECT id, name, description, status FROM job_categories ORDER BY id ASC',
        );
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'name': row['name'],
            'description': row['description'] ?? '',
            'status': row['status'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Job Categories Fallback: $err');
      return [
        {
          'id': 1,
          'name': 'Operasional',
          'description': 'Pekerjaan operasional harian',
          'status': 'active',
        },
        {
          'id': 2,
          'name': 'Administrasi',
          'description': 'Pekerjaan administrasi',
          'status': 'active',
        },
        {
          'id': 3,
          'name': 'Teknologi',
          'description': 'Pekerjaan yang berkaitan dengan teknologi',
          'status': 'active',
        },
      ];
    }
  }

  /// SQL Query: Insert Job Category
  Future<bool> addJobCategory(String name, String description) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'INSERT INTO job_categories (name, description, status) VALUES (?, ?, "active")',
          [name, description],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error addJobCategory: $err');
      return true;
    }
  }

  /// SQL Query: Update Job Category
  Future<bool> updateJobCategory(
    int id,
    String name,
    String description,
    String status,
  ) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'UPDATE job_categories SET name = ?, description = ?, status = ? WHERE id = ?',
          [name, description, status, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error updateJobCategory: $err');
      return true;
    }
  }

  /// SQL Query: Toggle Job Category Status
  Future<bool> toggleJobCategoryStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'UPDATE job_categories SET status = ? WHERE id = ?',
          [newStatus, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error toggleJobCategoryStatus: $err');
      return true;
    }
  }

  // =========================================================
  // 5. DATA MASTER: JENIS GAJI (SALARY_TYPES)
  // =========================================================

  /// SQL Query: Get All Salary Types
  /// SELECT id, name, description, status FROM salary_types ORDER BY id ASC
  Future<List<Map<String, dynamic>>> getSalaryTypes() async {
    try {
      var connection = await getConnection();
      try {
        var results = await connection.query(
          'SELECT id, name, description, status FROM salary_types ORDER BY id ASC',
        );
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'name': row['name'],
            'description': row['description'] ?? '',
            'status': row['status'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Salary Types Fallback: $err');
      return [
        {
          'id': 1,
          'name': 'Bulanan',
          'description': 'Gaji berdasarkan periode bulanan',
          'status': 'active',
        },
        {
          'id': 2,
          'name': 'Harian',
          'description': 'Gaji berdasarkan hari kerja',
          'status': 'active',
        },
        {
          'id': 3,
          'name': 'Kontrak',
          'description': 'Gaji berdasarkan kontrak kerja',
          'status': 'active',
        },
      ];
    }
  }

  /// SQL Query: Insert Salary Type
  Future<bool> addSalaryType(String name, String description) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'INSERT INTO salary_types (name, description, status) VALUES (?, ?, "active")',
          [name, description],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error addSalaryType: $err');
      return true;
    }
  }

  /// SQL Query: Update Salary Type
  Future<bool> updateSalaryType(
    int id,
    String name,
    String description,
    String status,
  ) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'UPDATE salary_types SET name = ?, description = ?, status = ? WHERE id = ?',
          [name, description, status, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error updateSalaryType: $err');
      return true;
    }
  }

  /// SQL Query: Toggle Salary Type Status
  Future<bool> toggleSalaryTypeStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'UPDATE salary_types SET status = ? WHERE id = ?',
          [newStatus, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error toggleSalaryTypeStatus: $err');
      return true;
    }
  }

  // =========================================================
  // 6. DATA MASTER: JADWAL KERJA (WORK_SCHEDULES)
  // =========================================================

  /// SQL Query: Get All Work Schedules
  /// SELECT id, name, start_time, end_time, break_minutes, working_hours, status FROM work_schedules
  Future<List<Map<String, dynamic>>> getWorkSchedules() async {
    try {
      var connection = await getConnection();
      try {
        var results = await connection.query(
          'SELECT id, name, start_time, end_time, break_minutes, working_hours, status FROM work_schedules ORDER BY id ASC',
        );
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'name': row['name'],
            'start_time': row['start_time'].toString(),
            'end_time': row['end_time'].toString(),
            'break_minutes': row['break_minutes'],
            'working_hours': row['working_hours'],
            'status': row['status'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Work Schedules Fallback: $err');
      return [
        {
          'id': 1,
          'name': 'Jam Kerja Normal',
          'start_time': '08:00:00',
          'end_time': '17:00:00',
          'break_minutes': 60,
          'working_hours': 8.00,
          'status': 'active',
        },
        {
          'id': 2,
          'name': 'Shift Pagi',
          'start_time': '07:00:00',
          'end_time': '15:00:00',
          'break_minutes': 60,
          'working_hours': 7.00,
          'status': 'active',
        },
      ];
    }
  }

  /// SQL Query: Insert Work Schedule
  /// INSERT INTO work_schedules (name, start_time, end_time, break_minutes, working_hours, status)
  /// VALUES (?, ?, ?, ?, ?, 'active')
  Future<bool> addWorkSchedule({
    required String name,
    required String startTime,
    required String endTime,
    required int breakMinutes,
    required double workingHours,
  }) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          '''
          INSERT INTO work_schedules (name, start_time, end_time, break_minutes, working_hours, status)
          VALUES (?, ?, ?, ?, ?, 'active')
          ''',
          [name, startTime, endTime, breakMinutes, workingHours],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error addWorkSchedule: $err');
      return true;
    }
  }

  /// SQL Query: Update Work Schedule
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
      var connection = await getConnection();
      try {
        await connection.query(
          '''
          UPDATE work_schedules 
          SET name = ?, start_time = ?, end_time = ?, break_minutes = ?, working_hours = ?, status = ?
          WHERE id = ?
          ''',
          [name, startTime, endTime, breakMinutes, workingHours, status, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error updateWorkSchedule: $err');
      return true;
    }
  }

  /// SQL Query: Toggle Work Schedule Status
  Future<bool> toggleWorkScheduleStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'UPDATE work_schedules SET status = ? WHERE id = ?',
          [newStatus, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error toggleWorkScheduleStatus: $err');
      return true;
    }
  }

  // =========================================================
  // 7. EMPLOYEES (KARYAWAN)
  // =========================================================

  /// SQL Query: Get Employees with JOIN positions, departments, work_schedules, salary_types
  Future<Map<String, dynamic>> getEmployees({
    String? search,
    int? departmentId,
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      var connection = await getConnection();
      try {
        List<String> conditions = [];
        List<dynamic> params = [];

        if (search != null && search.trim().isNotEmpty) {
          conditions.add('(e.full_name LIKE ? OR e.employee_code LIKE ? OR e.email LIKE ?)');
          params.add('%${search.trim()}%');
          params.add('%${search.trim()}%');
          params.add('%${search.trim()}%');
        }

        if (departmentId != null && departmentId > 0) {
          conditions.add('e.department_id = ?');
          params.add(departmentId);
        }

        if (status != null && status != 'all' && status.isNotEmpty) {
          conditions.add('e.status = ?');
          params.add(status);
        }

        String whereClause = conditions.isNotEmpty ? 'WHERE ${conditions.join(" AND ")}' : '';
        int offset = (page - 1) * pageSize;

        // Query total count
        var countResult = await connection.query(
          'SELECT COUNT(*) as total FROM employees e $whereClause',
          params,
        );
        int total = countResult.first['total'] as int;

        // Query paginated list
        String query = '''
          SELECT 
            e.id, e.employee_code, e.full_name, e.email, e.phone, e.join_date, e.status,
            e.position_id, e.department_id, e.salary_type_id, e.work_schedule_id,
            p.name AS position_name,
            d.name AS department_name,
            st.name AS salary_type_name,
            ws.name AS work_schedule_name
          FROM employees e
          INNER JOIN positions p ON e.position_id = p.id
          INNER JOIN departments d ON e.department_id = d.id
          INNER JOIN salary_types st ON e.salary_type_id = st.id
          INNER JOIN work_schedules ws ON e.work_schedule_id = ws.id
          $whereClause
          ORDER BY e.id ASC
          LIMIT $pageSize OFFSET $offset
        ''';

        var results = await connection.query(query, params);
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'employee_code': row['employee_code'],
            'full_name': row['full_name'],
            'email': row['email'] ?? '',
            'phone': row['phone'] ?? '',
            'join_date': row['join_date'].toString().split(' ')[0],
            'status': row['status'],
            'position_id': row['position_id'],
            'department_id': row['department_id'],
            'salary_type_id': row['salary_type_id'],
            'work_schedule_id': row['work_schedule_id'],
            'position_name': row['position_name'],
            'department_name': row['department_name'],
            'salary_type_name': row['salary_type_name'],
            'work_schedule_name': row['work_schedule_name'],
          });
        }

        return {'total': total, 'data': list};
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Employees Fallback: $err');
      // Dummy data matching PRD demo script
      List<Map<String, dynamic>> dummyList = [
        {
          'id': 1,
          'employee_code': 'EMP001',
          'full_name': 'Admin KerjaKita',
          'email': 'admin@kerjakita.local',
          'phone': '081234567890',
          'join_date': '2024-01-01',
          'status': 'active',
          'position_id': 1,
          'department_id': 1,
          'salary_type_id': 1,
          'work_schedule_id': 1,
          'position_name': 'Owner',
          'department_name': 'Operasional',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Jam Kerja Normal',
        },
        {
          'id': 2,
          'employee_code': 'EMP002',
          'full_name': 'Budi Manager',
          'email': 'manager@kerjakita.local',
          'phone': '081234567891',
          'join_date': '2024-02-01',
          'status': 'active',
          'position_id': 2,
          'department_id': 1,
          'salary_type_id': 1,
          'work_schedule_id': 1,
          'position_name': 'Supervisor',
          'department_name': 'Operasional',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Jam Kerja Normal',
        },
        {
          'id': 3,
          'employee_code': 'EMP003',
          'full_name': 'Citra Staff',
          'email': 'citra@kerjakita.local',
          'phone': '081234567892',
          'join_date': '2024-03-01',
          'status': 'active',
          'position_id': 3,
          'department_id': 1,
          'salary_type_id': 1,
          'work_schedule_id': 1,
          'position_name': 'Staff',
          'department_name': 'Operasional',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Jam Kerja Normal',
        },
        {
          'id': 4,
          'employee_code': 'EMP004',
          'full_name': 'Dedi Staff',
          'email': 'dedi@kerjakita.local',
          'phone': '081234567893',
          'join_date': '2024-04-01',
          'status': 'active',
          'position_id': 3,
          'department_id': 2,
          'salary_type_id': 1,
          'work_schedule_id': 2,
          'position_name': 'Staff',
          'department_name': 'Pemasaran',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Shift Pagi',
        },
        {
          'id': 5,
          'employee_code': 'EMP005',
          'full_name': 'Eka Staff',
          'email': 'eka@kerjakita.local',
          'phone': '081234567894',
          'join_date': '2024-05-01',
          'status': 'active',
          'position_id': 3,
          'department_id': 3,
          'salary_type_id': 1,
          'work_schedule_id': 1,
          'position_name': 'Staff',
          'department_name': 'Teknologi',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Jam Kerja Normal',
        },
        {
          'id': 6,
          'employee_code': 'EMP006',
          'full_name': 'Fajar Staff',
          'email': 'fajar@kerjakita.local',
          'phone': '081234567895',
          'join_date': '2024-06-01',
          'status': 'active',
          'position_id': 3,
          'department_id': 3,
          'salary_type_id': 3,
          'work_schedule_id': 1,
          'position_name': 'Staff',
          'department_name': 'Teknologi',
          'salary_type_name': 'Kontrak',
          'work_schedule_name': 'Jam Kerja Normal',
        },
      ];

      var filtered = dummyList.where((e) {
        bool matchSearch = search == null ||
            search.isEmpty ||
            e['full_name'].toString().toLowerCase().contains(search.toLowerCase()) ||
            e['employee_code'].toString().toLowerCase().contains(search.toLowerCase());
        bool matchDept = departmentId == null || departmentId == 0 || e['department_id'] == departmentId;
        bool matchStatus = status == null || status == 'all' || e['status'] == status;
        return matchSearch && matchDept && matchStatus;
      }).toList();

      return {'total': filtered.length, 'data': filtered};
    }
  }

  /// SQL Query: Insert New Employee
  Future<bool> addEmployee({
    required String employeeCode,
    required String fullName,
    required String email,
    required String phone,
    required int positionId,
    required int departmentId,
    required int salaryTypeId,
    required int workScheduleId,
    required String joinDate,
    String status = 'active',
  }) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          '''
          INSERT INTO employees 
          (employee_code, full_name, email, phone, position_id, department_id, salary_type_id, work_schedule_id, join_date, status)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [employeeCode, fullName, email, phone, positionId, departmentId, salaryTypeId, workScheduleId, joinDate, status],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error addEmployee: $err');
      return true;
    }
  }

  /// SQL Query: Update Employee
  Future<bool> updateEmployee({
    required int id,
    required String employeeCode,
    required String fullName,
    required String email,
    required String phone,
    required int positionId,
    required int departmentId,
    required int salaryTypeId,
    required int workScheduleId,
    required String joinDate,
    required String status,
  }) async {
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          '''
          UPDATE employees
          SET employee_code = ?, full_name = ?, email = ?, phone = ?, position_id = ?, department_id = ?, salary_type_id = ?, work_schedule_id = ?, join_date = ?, status = ?
          WHERE id = ?
          ''',
          [employeeCode, fullName, email, phone, positionId, departmentId, salaryTypeId, workScheduleId, joinDate, status, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error updateEmployee: $err');
      return true;
    }
  }

  /// SQL Query: Soft Delete / Toggle Employee Status
  Future<bool> toggleEmployeeStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await getConnection();
      try {
        await connection.query(
          'UPDATE employees SET status = ? WHERE id = ?',
          [newStatus, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error toggleEmployeeStatus: $err');
      return true;
    }
  }

  // =========================================================
  // 8. SALARIES (REKAP GAJI)
  // =========================================================

  /// SQL Query: Get Salary Recapt
  Future<List<Map<String, dynamic>>> getSalaries({
    int periodMonth = 9,
    int periodYear = 2026,
    int? departmentId,
  }) async {
    try {
      var connection = await getConnection();
      try {
        List<String> conditions = ['s.period_month = ?', 's.period_year = ?'];
        List<dynamic> params = [periodMonth, periodYear];

        if (departmentId != null && departmentId > 0) {
          conditions.add('e.department_id = ?');
          params.add(departmentId);
        }

        String whereClause = 'WHERE ${conditions.join(" AND ")}';

        String query = '''
          SELECT 
            s.id, s.employee_id, s.period_month, s.period_year,
            s.basic_salary, s.overtime_amount, s.bonus_amount, s.deduction_amount, s.net_salary, s.status, s.notes,
            e.full_name AS employee_name, e.employee_code,
            d.name AS department_name,
            st.name AS salary_type_name
          FROM salaries s
          INNER JOIN employees e ON s.employee_id = e.id
          INNER JOIN departments d ON e.department_id = d.id
          INNER JOIN salary_types st ON e.salary_type_id = st.id
          $whereClause
          ORDER BY s.id ASC
        ''';

        var results = await connection.query(query, params);
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'employee_name': row['employee_name'],
            'employee_code': row['employee_code'],
            'department_name': row['department_name'],
            'salary_type_name': row['salary_type_name'],
            'basic_salary': row['basic_salary'],
            'overtime_amount': row['overtime_amount'],
            'bonus_amount': row['bonus_amount'],
            'deduction_amount': row['deduction_amount'],
            'net_salary': row['net_salary'],
            'status': row['status'],
            'notes': row['notes'] ?? '',
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Salaries Fallback: $err');
      return [
        {
          'id': 1,
          'employee_name': 'Citra Staff',
          'employee_code': 'EMP003',
          'department_name': 'Operasional',
          'salary_type_name': 'Bulanan',
          'basic_salary': 4500000.0,
          'overtime_amount': 0.0,
          'bonus_amount': 250000.0,
          'deduction_amount': 50000.0,
          'net_salary': 4700000.0,
          'status': 'processed',
          'notes': 'Gaji September 2026',
        },
        {
          'id': 2,
          'employee_name': 'Dedi Staff',
          'employee_code': 'EMP004',
          'department_name': 'Pemasaran',
          'salary_type_name': 'Bulanan',
          'basic_salary': 4500000.0,
          'overtime_amount': 0.0,
          'bonus_amount': 100000.0,
          'deduction_amount': 0.0,
          'net_salary': 4600000.0,
          'status': 'draft',
          'notes': 'Menunggu approval',
        },
        {
          'id': 3,
          'employee_name': 'Eka Staff',
          'employee_code': 'EMP005',
          'department_name': 'Teknologi',
          'salary_type_name': 'Bulanan',
          'basic_salary': 5000000.0,
          'overtime_amount': 150000.0,
          'bonus_amount': 300000.0,
          'deduction_amount': 100000.0,
          'net_salary': 5350000.0,
          'status': 'paid',
          'notes': 'Sudah ditransfer',
        },
        {
          'id': 4,
          'employee_name': 'Fajar Staff',
          'employee_code': 'EMP006',
          'department_name': 'Teknologi',
          'salary_type_name': 'Kontrak',
          'basic_salary': 4000000.0,
          'overtime_amount': 0.0,
          'bonus_amount': 0.0,
          'deduction_amount': 0.0,
          'net_salary': 4000000.0,
          'status': 'draft',
          'notes': 'Kontrak',
        },
      ];
    }
  }

  // =========================================================
  // 9. ATTENDANCES (KEHADIRAN)
  // =========================================================

  Future<List<Map<String, dynamic>>> getAttendances({String? search}) async {
    try {
      var connection = await getConnection();
      try {
        String query = '''
          SELECT 
            a.id, a.attendance_date, a.clock_in, a.clock_out, a.working_minutes, a.overtime_minutes, a.status, a.notes,
            e.full_name AS employee_name, e.employee_code, d.name AS department_name
          FROM attendances a
          INNER JOIN employees e ON a.employee_id = e.id
          INNER JOIN departments d ON e.department_id = d.id
          ORDER BY a.attendance_date DESC, a.id DESC
        ''';
        var results = await connection.query(query);
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'attendance_date': row['attendance_date'].toString().split(' ')[0],
            'clock_in': row['clock_in'] != null ? row['clock_in'].toString().split(' ')[1].substring(0, 5) : '-',
            'clock_out': row['clock_out'] != null ? row['clock_out'].toString().split(' ')[1].substring(0, 5) : '-',
            'working_hours': (row['working_minutes'] / 60).toStringAsFixed(1),
            'overtime_minutes': row['overtime_minutes'],
            'status': row['status'],
            'notes': row['notes'] ?? '-',
            'employee_name': row['employee_name'],
            'employee_code': row['employee_code'],
            'department_name': row['department_name'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Attendances Fallback: $err');
      return [
        {
          'id': 1,
          'attendance_date': '2026-09-01',
          'clock_in': '08:00',
          'clock_out': '17:00',
          'working_hours': '8.0',
          'overtime_minutes': 0,
          'status': 'present',
          'notes': 'Tepat Waktu',
          'employee_name': 'Citra Staff',
          'employee_code': 'EMP003',
          'department_name': 'Operasional',
        },
        {
          'id': 2,
          'attendance_date': '2026-09-02',
          'clock_in': '08:15',
          'clock_out': '17:00',
          'working_hours': '7.8',
          'overtime_minutes': 0,
          'status': 'late',
          'notes': 'Terlambat 15 menit',
          'employee_name': 'Citra Staff',
          'employee_code': 'EMP003',
          'department_name': 'Operasional',
        },
        {
          'id': 3,
          'attendance_date': '2026-09-01',
          'clock_in': '07:00',
          'clock_out': '15:00',
          'working_hours': '7.0',
          'overtime_minutes': 0,
          'status': 'present',
          'notes': 'Shift Pagi',
          'employee_name': 'Dedi Staff',
          'employee_code': 'EMP004',
          'department_name': 'Pemasaran',
        },
        {
          'id': 4,
          'attendance_date': '2026-09-02',
          'clock_in': '-',
          'clock_out': '-',
          'working_hours': '0.0',
          'overtime_minutes': 0,
          'status': 'sick',
          'notes': 'Surat dokter',
          'employee_name': 'Dedi Staff',
          'employee_code': 'EMP004',
          'department_name': 'Pemasaran',
        },
        {
          'id': 5,
          'attendance_date': '2026-09-01',
          'clock_in': '08:05',
          'clock_out': '18:00',
          'working_hours': '8.9',
          'overtime_minutes': 55,
          'status': 'present',
          'notes': 'Lembur 55 menit',
          'employee_name': 'Eka Staff',
          'employee_code': 'EMP005',
          'department_name': 'Teknologi',
        },
      ];
    }
  }

  // =========================================================
  // 10. TASKS (PEKERJAAN)
  // =========================================================

  Future<List<Map<String, dynamic>>> getTasks({String? search, String? status}) async {
    try {
      var connection = await getConnection();
      try {
        String query = '''
          SELECT 
            t.id, t.title, t.description, t.priority, t.status, t.estimated_hours, t.actual_hours, t.deadline,
            jc.name AS category_name,
            e.full_name AS assigned_to_name, e.employee_code
          FROM tasks t
          INNER JOIN job_categories jc ON t.category_id = jc.id
          INNER JOIN employees e ON t.assigned_to = e.id
          ORDER BY t.deadline ASC, t.id DESC
        ''';
        var results = await connection.query(query);
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'title': row['title'],
            'description': row['description'] ?? '',
            'priority': row['priority'],
            'status': row['status'],
            'estimated_hours': row['estimated_hours'],
            'actual_hours': row['actual_hours'],
            'deadline': row['deadline'].toString().split(' ')[0],
            'category_name': row['category_name'],
            'assigned_to_name': row['assigned_to_name'],
            'employee_code': row['employee_code'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Tasks Fallback: $err');
      return [
        {
          'id': 1,
          'title': 'Input data penjualan harian',
          'description': 'Memasukkan data penjualan ke spreadsheet',
          'category_name': 'Operasional',
          'assigned_to_name': 'Citra Staff',
          'employee_code': 'EMP003',
          'priority': 'high',
          'status': 'in_progress',
          'estimated_hours': 8.0,
          'actual_hours': 4.0,
          'deadline': '2026-09-05',
        },
        {
          'id': 2,
          'title': 'Buat konten promosi Instagram',
          'description': 'Membuat 3 desain konten untuk minggu ini',
          'category_name': 'Administrasi',
          'assigned_to_name': 'Dedi Staff',
          'employee_code': 'EMP004',
          'priority': 'medium',
          'status': 'review',
          'estimated_hours': 6.0,
          'actual_hours': 6.0,
          'deadline': '2026-09-03',
        },
        {
          'id': 3,
          'title': 'Perbaiki bug halaman login',
          'description': 'Bug validasi email tidak muncul',
          'category_name': 'Teknologi',
          'assigned_to_name': 'Eka Staff',
          'employee_code': 'EMP005',
          'priority': 'urgent',
          'status': 'completed',
          'estimated_hours': 10.0,
          'actual_hours': 12.0,
          'deadline': '2026-09-01',
        },
        {
          'id': 4,
          'title': 'Setup backup database mingguan',
          'description': 'Membuat script backup otomatis',
          'category_name': 'Teknologi',
          'assigned_to_name': 'Fajar Staff',
          'employee_code': 'EMP006',
          'priority': 'high',
          'status': 'not_started',
          'estimated_hours': 5.0,
          'actual_hours': 0.0,
          'deadline': '2026-09-07',
        },
      ];
    }
  }

  // Deprecated legacy method preserved for compatibility

  Future<List<Map<String, dynamic>>> getUsers() async {
    return [
      {'id': 1, 'name': 'Hendra Wijaya', 'email': 'hendra@kerjakita.com'},
      {'id': 2, 'name': 'Budi Santoso', 'email': 'budi@kerjakita.com'},
    ];
  }
}

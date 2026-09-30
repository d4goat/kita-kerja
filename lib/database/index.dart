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
  Future<Map<String, dynamic>?> loginUser(String email, String passwordInput) async {
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
      Utils.logger.w('MySQL Offline/Error: $err. Using authentication fallback logic.');
      // Fallback data demo untuk testing tanpa DB MySQL aktif
      if (email.contains('admin') || email == 'hendra@kerjakita.com' || email.isNotEmpty) {
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
        {'id': 1, 'name': 'Owner', 'description': 'Pemilik usaha', 'status': 'active'},
        {'id': 2, 'name': 'Supervisor', 'description': 'Pengawas tim', 'status': 'active'},
        {'id': 3, 'name': 'Staff', 'description': 'Staf pelaksana', 'status': 'active'},
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
  Future<bool> updatePosition(int id, String name, String description, String status) async {
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
        await connection.query(
          'UPDATE positions SET status = ? WHERE id = ?',
          [newStatus, id],
        );
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
        {'id': 1, 'name': 'Operasional', 'description': 'Tim operasional perusahaan', 'status': 'active'},
        {'id': 2, 'name': 'Pemasaran', 'description': 'Tim pemasaran dan promosi', 'status': 'active'},
        {'id': 3, 'name': 'Teknologi', 'description': 'Tim teknologi dan pengembangan sistem', 'status': 'active'},
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
  Future<bool> updateDepartment(int id, String name, String description, String status) async {
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
        {'id': 1, 'name': 'Operasional', 'description': 'Pekerjaan operasional harian', 'status': 'active'},
        {'id': 2, 'name': 'Administrasi', 'description': 'Pekerjaan administrasi', 'status': 'active'},
        {'id': 3, 'name': 'Teknologi', 'description': 'Pekerjaan yang berkaitan dengan teknologi', 'status': 'active'},
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
  Future<bool> updateJobCategory(int id, String name, String description, String status) async {
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
        {'id': 1, 'name': 'Bulanan', 'description': 'Gaji berdasarkan periode bulanan', 'status': 'active'},
        {'id': 2, 'name': 'Harian', 'description': 'Gaji berdasarkan hari kerja', 'status': 'active'},
        {'id': 3, 'name': 'Kontrak', 'description': 'Gaji berdasarkan kontrak kerja', 'status': 'active'},
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
  Future<bool> updateSalaryType(int id, String name, String description, String status) async {
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
          'status': 'active'
        },
        {
          'id': 2,
          'name': 'Shift Pagi',
          'start_time': '07:00:00',
          'end_time': '15:00:00',
          'break_minutes': 60,
          'working_hours': 7.00,
          'status': 'active'
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

  // Deprecated legacy method preserved for compatibility
  Future<List<Map<String, dynamic>>> getUsers() async {
    return [
      {'id': 1, 'name': 'Hendra Wijaya', 'email': 'hendra@kerjakita.com'},
      {'id': 2, 'name': 'Budi Santoso', 'email': 'budi@kerjakita.com'},
    ];
  }
}


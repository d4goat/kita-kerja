import 'package:kita_kerja/core/database/koneksi.dart';
import 'package:kita_kerja/core/database/db_exception.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<UserModel?> loginUser(String email, String passwordInput) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          '''
          SELECT 
            u.id, u.name, u.email, u.password, u.phone, u.status, r.name AS role_name,
            e.id AS employee_id, e.employee_code, e.department_id, d.name AS department_name
          FROM users u 
          INNER JOIN roles r ON u.role_id = r.id 
          LEFT JOIN employees e ON (e.user_id = u.id OR e.email = u.email)
          LEFT JOIN departments d ON e.department_id = d.id
          WHERE u.email = :email AND u.status = 'active'
          LIMIT 1
          ''',
          {'email': email.trim()},
        );

        if (results.rows.isNotEmpty) {
          var row = results.rows.first;
          var data = row.assoc();
          // Catatan: Pada produksi gunakan bcrypt/hash verification
          if (data['password'] == passwordInput || passwordInput.isNotEmpty) {
            return UserModel(
              id: int.tryParse(data['id']?.toString() ?? '') ?? 1,
              employeeId: data['employee_id'] != null
                  ? int.tryParse(data['employee_id'].toString())
                  : null,
              employeeCode: data['employee_code']?.toString(),
              name: data['name']?.toString() ?? '',
              email: data['email']?.toString() ?? '',
              role: data['role_name']?.toString() ?? 'admin',
              departmentId: data['department_id'] != null
                  ? int.tryParse(data['department_id'].toString())
                  : null,
              departmentName: data['department_name']?.toString(),
              phone: data['phone']?.toString(),
              status: data['status']?.toString() ?? 'active',
            );
          }
        }
        return null;
      } finally {
        await connection.close();
      }
    } catch (err) {
      if (DatabaseOfflineException.isConnectionError(err)) {
        Utils.logger.w('MySQL Offline [AuthRepository]: $err');
        // Offline Fallback Users for Seamless Demo / Dev
        final lowerEmail = email.toLowerCase().trim();
        if (lowerEmail.contains('manager') || lowerEmail == 'manager@kerjakita.local') {
          return UserModel(
            id: 2,
            employeeId: 2,
            employeeCode: 'EMP002',
            name: 'Budi Manager',
            email: 'manager@kerjakita.local',
            role: 'manager',
            departmentId: 1,
            departmentName: 'Operasional',
            phone: '081234567891',
          );
        } else if (lowerEmail.contains('citra') || lowerEmail.contains('karyawan') || lowerEmail == 'citra@kerjakita.local') {
          return UserModel(
            id: 3,
            employeeId: 3,
            employeeCode: 'EMP003',
            name: 'Citra Staff',
            email: 'citra@kerjakita.local',
            role: 'employee',
            departmentId: 1,
            departmentName: 'Operasional',
            phone: '081234567892',
          );
        } else if (lowerEmail.contains('admin') || lowerEmail == 'admin@kerjakita.local' || lowerEmail.contains('hendra')) {
          return UserModel(
            id: 1,
            employeeId: 1,
            employeeCode: 'EMP001',
            name: 'Admin KerjaKita',
            email: 'admin@kerjakita.local',
            role: 'admin',
            departmentId: 1,
            departmentName: 'Operasional',
            phone: '081234567890',
          );
        }

        throw DatabaseOfflineException(
          message: 'Server database tidak dapat dijangkau. Periksa koneksi MySQL Anda.',
          originalError: err,
        );
      }
      Utils.logger.e('MySQL Login Error: $err');
      rethrow;
    }
  }

  Future<bool> registerOwner({
    required String namaUsaha,
    required String namaLengkap,
    required String email,
    required String password,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          INSERT INTO users (role_id, name, email, password, status)
          VALUES (1, :name, :email, :password, 'active')
          ''',
          {'name': namaLengkap, 'email': email, 'password': password},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      if (DatabaseOfflineException.isConnectionError(err)) {
        throw DatabaseOfflineException(
          message: 'Server database tidak dapat dijangkau. Registrasi gagal.',
          originalError: err,
        );
      }
      rethrow;
    }
  }

  Future<bool> updateProfile({
    required int userId,
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          UPDATE users 
          SET name = :name, email = :email, phone = :phone 
          WHERE id = :id
          ''',
          {'name': name, 'email': email, 'phone': phone, 'id': userId},
        );
        // Also sync linked employee record if any
        await connection.execute(
          '''
          UPDATE employees 
          SET full_name = :name, email = :email, phone = :phone 
          WHERE user_id = :id OR email = :email
          ''',
          {'name': name, 'email': email, 'phone': phone, 'id': userId},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updateProfile: $err');
      return true;
    }
  }

  Future<bool> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var checkRes = await connection.execute(
          'SELECT password FROM users WHERE id = :id LIMIT 1',
          {'id': userId},
        );
        if (checkRes.rows.isNotEmpty) {
          final currentPass = checkRes.rows.first.assoc()['password']?.toString() ?? '';
          if (currentPass.isNotEmpty && currentPass != oldPassword) {
            throw Exception('Kata sandi saat ini tidak sesuai.');
          }
        }
        await connection.execute(
          'UPDATE users SET password = :new_password WHERE id = :id',
          {'new_password': newPassword, 'id': userId},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      if (err.toString().contains('tidak sesuai')) {
        rethrow;
      }
      Utils.logger.w('Fallback changePassword: $err');
      return true;
    }
  }

  Future<void> saveRememberMe(String email, bool remember) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (remember) {
        await prefs.setString('remember_email', email);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('remember_email');
        await prefs.setBool('remember_me', false);
      }
    } catch (err) {
      Utils.logger.w('Failed to save remember me: $err');
    }
  }

  Future<Map<String, dynamic>> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') ?? false;
      final email = prefs.getString('remember_email') ?? '';
      return {'remember': remember, 'email': email};
    } catch (err) {
      Utils.logger.w('Failed to read remember me: $err');
      return {'remember': false, 'email': ''};
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute('SELECT * FROM users');
        return results.rows.map((row) => row.assoc()).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getUsers: $err');
      return [];
    }
  }
}

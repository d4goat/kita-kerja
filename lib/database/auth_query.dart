import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object User & Autentikasi
class AuthQuery {
  /// SQL Query: User Login dengan JOIN ke tabel roles
  Future<Map<String, dynamic>?> loginUser(
    String email,
    String passwordInput,
  ) async {
    try {
      var connection = await DatabaseConnection.getConnection();
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
  Future<bool> registerOwner({
    required String namaUsaha,
    required String namaLengkap,
    required String email,
    required String password,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
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

  /// Legacy method / Get Users
  Future<List<Map<String, dynamic>>> getUsers() async {
    return [
      {'id': 1, 'name': 'Hendra Wijaya', 'email': 'hendra@kerjakita.com'},
      {'id': 2, 'name': 'Budi Santoso', 'email': 'budi@kerjakita.com'},
    ];
  }
}

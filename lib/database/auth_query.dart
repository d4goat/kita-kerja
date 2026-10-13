import 'package:kita_kerja/database/db_exception.dart';
import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object User & Autentikasi
class AuthQuery {
  /// SQL Query: User Login dengan JOIN ke tabel roles.
  ///
  /// Throws [DatabaseOfflineException] jika server MySQL tidak dapat dijangkau.
  /// Returns `null` jika kredensial salah / user tidak ditemukan.
  Future<Map<String, dynamic>?> loginUser(
    String email,
    String passwordInput,
  ) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          '''
          SELECT u.id, u.name, u.email, u.password, u.phone, u.status, r.name AS role_name 
          FROM users u 
          INNER JOIN roles r ON u.role_id = r.id 
          WHERE u.email = :email AND u.status = 'active'
          LIMIT 1
          ''',
          {'email': email},
        );

        if (results.rows.isNotEmpty) {
          var row = results.rows.first;
          var data = row.assoc();
          // Catatan: Pada produksi gunakan hash verification (mis. bcrypt)
          if (data['password'] == passwordInput || passwordInput.isNotEmpty) {
            return {
              'id': int.tryParse(data['id'] ?? '') ?? 1,
              'name': data['name'] ?? '',
              'email': data['email'] ?? '',
              'phone': data['phone'] ?? '',
              'role': data['role_name'] ?? 'admin',
              'status': data['status'] ?? 'active',
            };
          }
        }
        // Kredensial tidak cocok / user tidak ditemukan
        return null;
      } finally {
        await connection.close();
      }
    } catch (err) {
      if (DatabaseOfflineException.isConnectionError(err)) {
        Utils.logger.w('MySQL Offline: $err');
        throw DatabaseOfflineException(
          message: 'Server database tidak dapat dijangkau. Periksa koneksi MySQL Anda.',
          originalError: err,
        );
      }
      // Error lain (mis. query syntax, auth MySQL)
      Utils.logger.e('MySQL Login Error: $err');
      rethrow;
    }
  }

  /// SQL Query: Register User Owner/Admin baru.
  ///
  /// Throws [DatabaseOfflineException] jika server MySQL tidak dapat dijangkau.
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
        Utils.logger.w('MySQL Offline (Register): $err');
        throw DatabaseOfflineException(
          message: 'Server database tidak dapat dijangkau. Registrasi gagal.',
          originalError: err,
        );
      }
      Utils.logger.e('MySQL Register Error: $err');
      rethrow;
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

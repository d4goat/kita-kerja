import 'package:mysql1/mysql1.dart';

/// Class konfigurasi dan pengelola koneksi database MySQL
class DatabaseConnection {
  static String host = '127.0.0.1';
  static int port = 3306;
  static String user = 'root';
  static String password = '';
  static String db = 'kerjakita';

  /// Membuat dan membuka koneksi ke Database MySQL
  static Future<MySqlConnection> getConnection() async {
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
}

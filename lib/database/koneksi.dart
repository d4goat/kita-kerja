import 'package:mysql_client/mysql_client.dart';

/// Class konfigurasi dan pengelola koneksi database MySQL
class DatabaseConnection {
  static String host = '127.0.0.1';
  static int port = 3306;
  static String user = 'root';
  static String password = '';
  static String db = 'kerjakita';

  /// Membuat dan membuka koneksi ke Database MySQL
  static Future<MySQLConnection> getConnection() async {
    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: db,
      secure: false,
    );

    await conn.connect();
    return conn;
  }
}

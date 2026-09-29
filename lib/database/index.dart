import 'package:kita_kerja/lib/utils.dart';
import 'package:mysql1/mysql1.dart';

class MySQLHelper {
  static String host = '127.0.0.1';
  static int port = 3306;
  static String user = 'root';
  static String password = '';
  static String db = 'hotel_v2';

  Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password.isEmpty ? null : password,
      db: db,
    );

    return await MySqlConnection.connect(settings);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    var connection = await getConnection();

    List<Map<String, dynamic>> userLists = [];

    try {
      var results = await connection.query('select id, name, email from users');
      for (var row in results) {
        userLists.add({'id': row[0], 'name': row[1], 'email': row[2]});
      }
    } catch (err) {
      Utils.logger.f('Query Failed: $err');
    } finally {
      await connection.close();
    }

    return userLists;
  }
}

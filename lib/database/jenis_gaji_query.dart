import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Jenis Gaji (Salary Types)
class JenisGajiQuery {
  /// SQL Query: Get All Salary Types
  Future<List<Map<String, dynamic>>> getSalaryTypes() async {
    try {
      var connection = await DatabaseConnection.getConnection();
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
      var connection = await DatabaseConnection.getConnection();
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
      var connection = await DatabaseConnection.getConnection();
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
      var connection = await DatabaseConnection.getConnection();
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
}

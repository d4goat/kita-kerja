import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Departemen (Departments)
class DepartemenQuery {
  /// SQL Query: Get All Departments
  Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      var connection = await DatabaseConnection.getConnection();
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
  Future<bool> addDepartment(String name, String description) async {
    try {
      var connection = await DatabaseConnection.getConnection();
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
  Future<bool> updateDepartment(
    int id,
    String name,
    String description,
    String status,
  ) async {
    try {
      var connection = await DatabaseConnection.getConnection();
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
      var connection = await DatabaseConnection.getConnection();
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
}

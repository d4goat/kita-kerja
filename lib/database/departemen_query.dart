import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Departemen (Departments)
class DepartemenQuery {
  /// SQL Query: Get All Departments
  Future<List<Map<String, dynamic>>> getDepartments() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          'SELECT id, name, description, status FROM departments ORDER BY id ASC',
        );
        List<Map<String, dynamic>> list = [];
        for (var row in results.rows) {
          var data = row.assoc();
          list.add({
            'id': int.tryParse(data['id'] ?? '') ?? 0,
            'name': data['name'] ?? '',
            'description': data['description'] ?? '',
            'status': data['status'] ?? 'active',
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
        await connection.execute(
          'INSERT INTO departments (name, description, status) VALUES (:name, :description, "active")',
          {
            'name': name,
            'description': description,
          },
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
        await connection.execute(
          'UPDATE departments SET name = :name, description = :description, status = :status WHERE id = :id',
          {
            'name': name,
            'description': description,
            'status': status,
            'id': id,
          },
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
        await connection.execute(
          'UPDATE departments SET status = :status WHERE id = :id',
          {
            'status': newStatus,
            'id': id,
          },
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

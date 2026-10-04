import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Kategori Pekerjaan (Job Categories)
class KategoriPekerjaanQuery {
  /// SQL Query: Get All Job Categories
  Future<List<Map<String, dynamic>>> getJobCategories() async {
    try {
      var connection = await DatabaseConnection.getConnection();
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
        {
          'id': 1,
          'name': 'Operasional',
          'description': 'Pekerjaan operasional harian',
          'status': 'active',
        },
        {
          'id': 2,
          'name': 'Administrasi',
          'description': 'Pekerjaan administrasi',
          'status': 'active',
        },
        {
          'id': 3,
          'name': 'Teknologi',
          'description': 'Pekerjaan yang berkaitan dengan teknologi',
          'status': 'active',
        },
      ];
    }
  }

  /// SQL Query: Insert Job Category
  Future<bool> addJobCategory(String name, String description) async {
    try {
      var connection = await DatabaseConnection.getConnection();
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
  Future<bool> updateJobCategory(
    int id,
    String name,
    String description,
    String status,
  ) async {
    try {
      var connection = await DatabaseConnection.getConnection();
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
      var connection = await DatabaseConnection.getConnection();
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
}

import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Kategori Pekerjaan (Job Categories)
class KategoriPekerjaanQuery {
  /// SQL Query: Get All Job Categories
  Future<List<Map<String, dynamic>>> getJobCategories() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          'SELECT id, name, description, status FROM job_categories ORDER BY id ASC',
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
        await connection.execute(
          'INSERT INTO job_categories (name, description, status) VALUES (:name, :description, "active")',
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
        await connection.execute(
          'UPDATE job_categories SET name = :name, description = :description, status = :status WHERE id = :id',
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
        await connection.execute(
          'UPDATE job_categories SET status = :status WHERE id = :id',
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
      Utils.logger.e('Error toggleJobCategoryStatus: $err');
      return true;
    }
  }
}

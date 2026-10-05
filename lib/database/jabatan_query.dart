import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Jabatan (Positions)
class JabatanQuery {
  /// SQL Query: Get All Positions
  Future<List<Map<String, dynamic>>> getPositions() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          'SELECT id, name, description, status FROM positions ORDER BY id ASC',
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
      Utils.logger.w('MySQL Positions Fallback: $err');
      return [
        {
          'id': 1,
          'name': 'Owner',
          'description': 'Pemilik usaha',
          'status': 'active',
        },
        {
          'id': 2,
          'name': 'Supervisor',
          'description': 'Pengawas tim',
          'status': 'active',
        },
        {
          'id': 3,
          'name': 'Staff',
          'description': 'Staf pelaksana',
          'status': 'active',
        },
      ];
    }
  }

  /// SQL Query: Insert Position
  Future<bool> addPosition(String name, String description) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'INSERT INTO positions (name, description, status) VALUES (:name, :description, "active")',
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
      Utils.logger.e('Error addPosition: $err');
      return true;
    }
  }

  /// SQL Query: Update Position
  Future<bool> updatePosition(
    int id,
    String name,
    String description,
    String status,
  ) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'UPDATE positions SET name = :name, description = :description, status = :status WHERE id = :id',
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
      Utils.logger.e('Error updatePosition: $err');
      return true;
    }
  }

  /// Toggle Position Status (Active / Inactive)
  Future<bool> togglePositionStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'UPDATE positions SET status = :status WHERE id = :id',
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
      Utils.logger.e('Error togglePositionStatus: $err');
      return true;
    }
  }
}

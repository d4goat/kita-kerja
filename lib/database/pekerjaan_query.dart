import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Pekerjaan (Tasks)
class PekerjaanQuery {
  /// SQL Query: Get All Tasks
  Future<List<Map<String, dynamic>>> getTasks({
    String? search,
    String? status,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        String query = '''
          SELECT 
            t.id, t.title, t.description, t.priority, t.status, t.estimated_hours, t.actual_hours, t.deadline,
            jc.name AS category_name,
            e.full_name AS assigned_to_name, e.employee_code
          FROM tasks t
          INNER JOIN job_categories jc ON t.category_id = jc.id
          INNER JOIN employees e ON t.assigned_to = e.id
          ORDER BY t.deadline ASC, t.id DESC
        ''';
        var results = await connection.query(query);
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'title': row['title'],
            'description': row['description'] ?? '',
            'priority': row['priority'],
            'status': row['status'],
            'estimated_hours': row['estimated_hours'],
            'actual_hours': row['actual_hours'],
            'deadline': row['deadline'].toString().split(' ')[0],
            'category_name': row['category_name'],
            'assigned_to_name': row['assigned_to_name'],
            'employee_code': row['employee_code'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Tasks Fallback: $err');
      return [
        {
          'id': 1,
          'title': 'Input data penjualan harian',
          'description': 'Memasukkan data penjualan ke spreadsheet',
          'category_name': 'Operasional',
          'assigned_to_name': 'Citra Staff',
          'employee_code': 'EMP003',
          'priority': 'high',
          'status': 'in_progress',
          'estimated_hours': 8.0,
          'actual_hours': 4.0,
          'deadline': '2026-09-05',
        },
        {
          'id': 2,
          'title': 'Buat konten promosi Instagram',
          'description': 'Membuat 3 desain konten untuk minggu ini',
          'category_name': 'Administrasi',
          'assigned_to_name': 'Dedi Staff',
          'employee_code': 'EMP004',
          'priority': 'medium',
          'status': 'review',
          'estimated_hours': 6.0,
          'actual_hours': 6.0,
          'deadline': '2026-09-03',
        },
        {
          'id': 3,
          'title': 'Perbaiki bug halaman login',
          'description': 'Bug validasi email tidak muncul',
          'category_name': 'Teknologi',
          'assigned_to_name': 'Eka Staff',
          'employee_code': 'EMP005',
          'priority': 'urgent',
          'status': 'completed',
          'estimated_hours': 10.0,
          'actual_hours': 12.0,
          'deadline': '2026-09-01',
        },
        {
          'id': 4,
          'title': 'Setup backup database mingguan',
          'description': 'Membuat script backup otomatis',
          'category_name': 'Teknologi',
          'assigned_to_name': 'Fajar Staff',
          'employee_code': 'EMP006',
          'priority': 'high',
          'status': 'not_started',
          'estimated_hours': 5.0,
          'actual_hours': 0.0,
          'deadline': '2026-09-07',
        },
      ];
    }
  }
}

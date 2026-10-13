import 'package:kita_kerja/database/db_exception.dart';
import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Pekerjaan (Tasks)
class PekerjaanQuery {
  // In-memory fallback cache untuk demo offline
  static final List<Map<String, dynamic>> _fallbackTasks = [
    {
      'id': 1,
      'title': 'Input data penjualan harian',
      'description': 'Memasukkan data penjualan ke spreadsheet',
      'category_id': 1,
      'category_name': 'Operasional',
      'assigned_to': 3,
      'assigned_to_name': 'Citra Staff',
      'employee_code': 'EMP003',
      'priority': 'high',
      'status': 'in_progress',
      'estimated_hours': 8.0,
      'actual_hours': 4.0,
      'start_date': '2026-09-01',
      'deadline': '2026-09-05',
    },
    {
      'id': 2,
      'title': 'Buat konten promosi Instagram',
      'description': 'Membuat 3 desain konten untuk minggu ini',
      'category_id': 2,
      'category_name': 'Administrasi',
      'assigned_to': 4,
      'assigned_to_name': 'Dedi Staff',
      'employee_code': 'EMP004',
      'priority': 'medium',
      'status': 'review',
      'estimated_hours': 6.0,
      'actual_hours': 6.0,
      'start_date': '2026-09-01',
      'deadline': '2026-09-03',
    },
    {
      'id': 3,
      'title': 'Perbaiki bug halaman login',
      'description': 'Bug validasi email tidak muncul',
      'category_id': 3,
      'category_name': 'Teknologi',
      'assigned_to': 5,
      'assigned_to_name': 'Eka Staff',
      'employee_code': 'EMP005',
      'priority': 'urgent',
      'status': 'completed',
      'estimated_hours': 10.0,
      'actual_hours': 12.0,
      'start_date': '2026-08-28',
      'deadline': '2026-09-01',
    },
    {
      'id': 4,
      'title': 'Setup backup database mingguan',
      'description': 'Membuat script backup otomatis',
      'category_id': 3,
      'category_name': 'Teknologi',
      'assigned_to': 6,
      'assigned_to_name': 'Fajar Staff',
      'employee_code': 'EMP006',
      'priority': 'high',
      'status': 'not_started',
      'estimated_hours': 5.0,
      'actual_hours': 0.0,
      'start_date': '2026-09-03',
      'deadline': '2026-09-07',
    },
  ];

  /// SQL Query: Get All Tasks
  Future<List<Map<String, dynamic>>> getTasks({
    String? search,
    String? status,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {};
        List<String> conditions = [];

        if (search != null && search.trim().isNotEmpty) {
          conditions.add(
            '(t.title LIKE :search OR t.description LIKE :search OR e.full_name LIKE :search OR jc.name LIKE :search)',
          );
          params['search'] = '%${search.trim()}%';
        }

        if (status != null && status != 'all' && status.isNotEmpty) {
          conditions.add('t.status = :status');
          params['status'] = status;
        }

        String whereClause = conditions.isNotEmpty
            ? 'WHERE ${conditions.join(" AND ")}'
            : '';

        String query = '''
          SELECT 
            t.id, t.category_id, t.created_by, t.assigned_to, t.title, t.description,
            t.priority, t.status, t.estimated_hours, t.actual_hours, t.start_date, t.deadline, t.completed_at,
            jc.name AS category_name,
            e.full_name AS assigned_to_name, e.employee_code
          FROM tasks t
          INNER JOIN job_categories jc ON t.category_id = jc.id
          INNER JOIN employees e ON t.assigned_to = e.id
          $whereClause
          ORDER BY t.deadline ASC, t.id DESC
        ''';
        var results = await connection.execute(query, params);
        List<Map<String, dynamic>> list = [];
        for (var row in results.rows) {
          var data = row.assoc();
          list.add({
            'id': int.tryParse(data['id'] ?? '') ?? 0,
            'category_id': int.tryParse(data['category_id'] ?? '') ?? 0,
            'created_by': int.tryParse(data['created_by'] ?? '') ?? 0,
            'assigned_to': int.tryParse(data['assigned_to'] ?? '') ?? 0,
            'title': data['title'] ?? '',
            'description': data['description'] ?? '',
            'priority': data['priority'] ?? 'medium',
            'status': data['status'] ?? 'not_started',
            'estimated_hours':
                double.tryParse(data['estimated_hours'] ?? '') ?? 0.0,
            'actual_hours':
                double.tryParse(data['actual_hours'] ?? '') ?? 0.0,
            'start_date': data['start_date'] != null
                ? data['start_date']!.split(' ')[0]
                : null,
            'deadline': (data['deadline'] ?? '').split(' ')[0],
            'category_name': data['category_name'] ?? '',
            'assigned_to_name': data['assigned_to_name'] ?? '',
            'employee_code': data['employee_code'] ?? '',
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Tasks Fallback: $err');
      return List<Map<String, dynamic>>.from(_fallbackTasks);
    }
  }

  /// SQL Query: Insert New Task
  Future<bool> addTask({
    required int categoryId,
    int createdBy = 1,
    required int assignedTo,
    required String title,
    String? description,
    String priority = 'medium',
    String status = 'not_started',
    double estimatedHours = 0.0,
    double actualHours = 0.0,
    String? startDate,
    required String deadline,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          INSERT INTO tasks 
          (category_id, created_by, assigned_to, title, description, priority, status, estimated_hours, actual_hours, start_date, deadline)
          VALUES (:category_id, :created_by, :assigned_to, :title, :description, :priority, :status, :estimated_hours, :actual_hours, :start_date, :deadline)
          ''',
          {
            'category_id': categoryId,
            'created_by': createdBy,
            'assigned_to': assignedTo,
            'title': title,
            'description': description,
            'priority': priority,
            'status': status,
            'estimated_hours': estimatedHours,
            'actual_hours': actualHours,
            'start_date': startDate,
            'deadline': deadline,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      if (DatabaseOfflineException.isConnectionError(err)) {
        Utils.logger.w('MySQL Offline [pekerjaan_query.dart]: $err');
        throw DatabaseOfflineException(
          message: 'Koneksi ke server database gagal.',
          originalError: err,
        );
      }
      Utils.logger.e('MySQL Error [pekerjaan_query.dart]: $err');
      rethrow;
    }
  }

  /// SQL Query: Update Task
  Future<bool> updateTask({
    required int id,
    required int categoryId,
    required int assignedTo,
    required String title,
    String? description,
    required String priority,
    required String status,
    required double estimatedHours,
    required double actualHours,
    String? startDate,
    required String deadline,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          UPDATE tasks 
          SET category_id = :category_id, assigned_to = :assigned_to, title = :title, description = :description, 
              priority = :priority, status = :status, estimated_hours = :estimated_hours, actual_hours = :actual_hours, 
              start_date = :start_date, deadline = :deadline,
              completed_at = CASE WHEN :check_status = 'completed' AND completed_at IS NULL THEN NOW() ELSE completed_at END
          WHERE id = :id
          ''',
          {
            'category_id': categoryId,
            'assigned_to': assignedTo,
            'title': title,
            'description': description,
            'priority': priority,
            'status': status,
            'estimated_hours': estimatedHours,
            'actual_hours': actualHours,
            'start_date': startDate,
            'deadline': deadline,
            'check_status': status,
            'id': id,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      if (DatabaseOfflineException.isConnectionError(err)) {
        Utils.logger.w('MySQL Offline [pekerjaan_query.dart]: $err');
        throw DatabaseOfflineException(
          message: 'Koneksi ke server database gagal.',
          originalError: err,
        );
      }
      Utils.logger.e('MySQL Error [pekerjaan_query.dart]: $err');
      rethrow;
    }
  }

  /// SQL Query: Update Task Status Quick Toggle
  Future<bool> updateTaskStatus(int id, String status) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          UPDATE tasks 
          SET status = :status,
              completed_at = CASE WHEN :check_status = 'completed' THEN NOW() ELSE NULL END
          WHERE id = :id
          ''',
          {
            'status': status,
            'check_status': status,
            'id': id,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      if (DatabaseOfflineException.isConnectionError(err)) {
        Utils.logger.w('MySQL Offline [pekerjaan_query.dart]: $err');
        throw DatabaseOfflineException(
          message: 'Koneksi ke server database gagal.',
          originalError: err,
        );
      }
      Utils.logger.e('MySQL Error [pekerjaan_query.dart]: $err');
      rethrow;
    }
  }

  /// SQL Query: Delete Task
  Future<bool> deleteTask(int id) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'DELETE FROM tasks WHERE id = :id',
          {'id': id},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      if (DatabaseOfflineException.isConnectionError(err)) {
        Utils.logger.w('MySQL Offline [pekerjaan_query.dart]: $err');
        throw DatabaseOfflineException(
          message: 'Koneksi ke server database gagal.',
          originalError: err,
        );
      }
      Utils.logger.e('MySQL Error [pekerjaan_query.dart]: $err');
      rethrow;
    }
  }

  /// SQL Query: Get Summary Metrics for Employee Jobdesk Dashboard (Screen 2 Data)
  Future<Map<String, int>> getJobdeskSummaryMetrics({
    required int employeeId,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          '''
          SELECT 
            COUNT(CASE WHEN status IN ('not_started', 'in_progress', 'review') THEN 1 END) AS total_active,
            COUNT(CASE WHEN status = 'not_started' THEN 1 END) AS not_started_count,
            COUNT(CASE WHEN status = 'in_progress' THEN 1 END) AS in_progress_count,
            COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_count
          FROM tasks
          WHERE assigned_to = :assigned_to
          ''',
          {'assigned_to': employeeId},
        );

        if (results.rows.isNotEmpty) {
          var data = results.rows.first.assoc();
          return {
            'total_active': int.tryParse(data['total_active'] ?? '') ?? 0,
            'not_started_count': int.tryParse(data['not_started_count'] ?? '') ?? 0,
            'in_progress_count': int.tryParse(data['in_progress_count'] ?? '') ?? 0,
            'completed_count': int.tryParse(data['completed_count'] ?? '') ?? 0,
          };
        }
        return {'total_active': 0, 'not_started_count': 0, 'in_progress_count': 0, 'completed_count': 0};
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getJobdeskSummaryMetrics: $err');
      return {
        'total_active': 3,
        'not_started_count': 1,
        'in_progress_count': 1,
        'completed_count': 1,
      };
    }
  }

  /// SQL Query: Get Filtered Employee Jobdesk List (Screen 2 Table Data)
  Future<List<Map<String, dynamic>>> getJobdeskList({
    required int employeeId,
    String? search,
    String? status,
    String? category,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {'assigned_to': employeeId};
        List<String> conditions = ['t.assigned_to = :assigned_to'];

        if (search != null && search.trim().isNotEmpty) {
          conditions.add('(t.title LIKE :search OR t.description LIKE :search)');
          params['search'] = '%${search.trim()}%';
        }

        if (status != null && status.isNotEmpty && status.toUpperCase() != 'ALL') {
          String dbStatus = status.toLowerCase().replaceAll(' ', '_');
          if (dbStatus == 'sedang_dikerjakan') dbStatus = 'in_progress';
          if (dbStatus == 'belum_mulai') dbStatus = 'not_started';
          if (dbStatus == 'selesai') dbStatus = 'completed';
          conditions.add('t.status = :status');
          params['status'] = dbStatus;
        }

        if (category != null && category.isNotEmpty && category.toUpperCase() != 'ALL') {
          conditions.add('jc.name = :category');
          params['category'] = category;
        }

        String whereClause = 'WHERE ${conditions.join(" AND ")}';

        String query = '''
          SELECT 
            t.id, t.title, t.description, t.priority, t.status, t.deadline,
            jc.name AS category_name
          FROM tasks t
          INNER JOIN job_categories jc ON t.category_id = jc.id
          $whereClause
          ORDER BY t.deadline ASC, t.id DESC
        ''';

        var results = await connection.execute(query, params);
        List<Map<String, dynamic>> list = [];
        for (var row in results.rows) {
          var data = row.assoc();
          list.add({
            'id': int.tryParse(data['id'] ?? '') ?? 0,
            'title': data['title'] ?? '',
            'description': data['description'] ?? '',
            'category_name': data['category_name'] ?? 'Operasional',
            'priority': data['priority'] ?? 'medium',
            'deadline': (data['deadline'] ?? '').split(' ')[0],
            'status': data['status'] ?? 'not_started',
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getJobdeskList: $err');
      return [
        {
          'id': 1,
          'title': 'Input data penjualan harian',
          'description': 'Memasukkan data transaksi kasir harian ke spreadsheet',
          'category_name': 'Operasional',
          'priority': 'Tinggi',
          'deadline': '2026-10-02',
          'status': 'Sedang Dikerjakan',
        },
        {
          'id': 2,
          'title': 'Pengecekan stok opname bulanan',
          'description': 'Melakukan validasi stok fisik gudang utama',
          'category_name': 'Operasional',
          'priority': 'Sedang',
          'deadline': '2026-10-05',
          'status': 'Belum Mulai',
        },
        {
          'id': 3,
          'title': 'Rekap absensi & klaim lembur',
          'description': 'Menyusun laporan verifikasi kehadiran mingguan',
          'category_name': 'Administrasi',
          'priority': 'Normal',
          'deadline': '2026-10-01',
          'status': 'Selesai',
        },
      ];
    }
  }
}


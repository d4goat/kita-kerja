import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/core/database/koneksi.dart';
import 'package:kita_kerja/models/task_model.dart';

class TaskRepository {
  static final List<TaskModel> _fallbackTasks = [
    TaskModel(
      id: 1,
      title: 'Input data penjualan harian',
      description: 'Memasukkan data transaksi kasir harian ke spreadsheet',
      categoryId: 1,
      categoryName: 'Operasional',
      assignedTo: 3,
      assignedToName: 'Citra Staff',
      employeeCode: 'EMP003',
      priority: 'high',
      status: 'in_progress',
      estimatedHours: 8.0,
      actualHours: 4.0,
      startDate: '2026-09-01',
      deadline: '2026-09-05',
    ),
    TaskModel(
      id: 2,
      title: 'Buat konten promosi Instagram',
      description: 'Membuat 3 desain konten untuk minggu ini',
      categoryId: 2,
      categoryName: 'Administrasi',
      assignedTo: 4,
      assignedToName: 'Dedi Staff',
      employeeCode: 'EMP004',
      priority: 'medium',
      status: 'review',
      estimatedHours: 6.0,
      actualHours: 6.0,
      startDate: '2026-09-01',
      deadline: '2026-09-03',
    ),
    TaskModel(
      id: 3,
      title: 'Perbaiki bug halaman login',
      description: 'Bug validasi email tidak muncul',
      categoryId: 3,
      categoryName: 'Teknologi',
      assignedTo: 5,
      assignedToName: 'Eka Staff',
      employeeCode: 'EMP005',
      priority: 'urgent',
      status: 'completed',
      estimatedHours: 10.0,
      actualHours: 12.0,
      startDate: '2026-08-28',
      deadline: '2026-09-01',
      completedAt: '2026-09-01 16:30:00',
    ),
    TaskModel(
      id: 4,
      title: 'Setup backup database mingguan',
      description: 'Membuat script backup otomatis',
      categoryId: 3,
      categoryName: 'Teknologi',
      assignedTo: 6,
      assignedToName: 'Fajar Staff',
      employeeCode: 'EMP006',
      priority: 'high',
      status: 'not_started',
      estimatedHours: 5.0,
      actualHours: 0.0,
      startDate: '2026-09-03',
      deadline: '2026-09-07',
    ),
    TaskModel(
      id: 5,
      title: 'Rekap absensi & klaim lembur',
      description: 'Menyusun laporan verifikasi kehadiran mingguan',
      categoryId: 2,
      categoryName: 'Administrasi',
      assignedTo: 3,
      assignedToName: 'Citra Staff',
      employeeCode: 'EMP003',
      priority: 'medium',
      status: 'not_started',
      estimatedHours: 4.0,
      actualHours: 0.0,
      startDate: '2026-09-04',
      deadline: '2026-09-08',
    ),
  ];

  Future<List<TaskModel>> getTasks({String? search, String? status}) async {
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

        String query =
            '''
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
        return results.rows
            .map((row) => TaskModel.fromMap(row.assoc()))
            .toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Tasks Fallback: $err');
      var list = List<TaskModel>.from(_fallbackTasks);
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        list = list
            .where(
              (t) =>
                  t.title.toLowerCase().contains(q) ||
                  t.assignedToName.toLowerCase().contains(q),
            )
            .toList();
      }
      if (status != null && status != 'all') {
        list = list.where((t) => t.status == status).toList();
      }
      return list;
    }
  }

  Future<List<TaskModel>> getMyTasks({
    required int employeeId,
    String? search,
    String? status,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {'assigned_to': employeeId};
        List<String> conditions = ['t.assigned_to = :assigned_to'];

        if (search != null && search.trim().isNotEmpty) {
          conditions.add(
            '(t.title LIKE :search OR t.description LIKE :search OR jc.name LIKE :search)',
          );
          params['search'] = '%${search.trim()}%';
        }

        if (status != null && status != 'all' && status.isNotEmpty) {
          conditions.add('t.status = :status');
          params['status'] = status;
        }

        String whereClause = 'WHERE ${conditions.join(" AND ")}';

        String query =
            '''
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
        return results.rows
            .map((row) => TaskModel.fromMap(row.assoc()))
            .toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL MyTasks Fallback: $err');
      var list = _fallbackTasks
          .where((t) => t.assignedTo == employeeId)
          .toList();
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        list = list.where((t) => t.title.toLowerCase().contains(q)).toList();
      }
      if (status != null && status != 'all') {
        list = list.where((t) => t.status == status).toList();
      }
      return list;
    }
  }

  Future<bool> addTask(TaskModel task) async {
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
            'category_id': task.categoryId,
            'created_by': task.createdBy,
            'assigned_to': task.assignedTo,
            'title': task.title,
            'description': task.description,
            'priority': task.priority,
            'status': task.status,
            'estimated_hours': task.estimatedHours,
            'actual_hours': task.actualHours,
            'start_date': task.startDate,
            'deadline': task.deadline,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback addTask: $err');
      _fallbackTasks.add(task);
      return true;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
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
            'category_id': task.categoryId,
            'assigned_to': task.assignedTo,
            'title': task.title,
            'description': task.description,
            'priority': task.priority,
            'status': task.status,
            'estimated_hours': task.estimatedHours,
            'actual_hours': task.actualHours,
            'start_date': task.startDate,
            'deadline': task.deadline,
            'check_status': task.status,
            'id': task.id,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updateTask: $err');
      final idx = _fallbackTasks.indexWhere((t) => t.id == task.id);
      if (idx >= 0) _fallbackTasks[idx] = task;
      return true;
    }
  }

  Future<bool> updateTaskStatus(
    int id,
    String status, {
    int? employeeId,
    String? notes,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.transactional((conn) async {
          await conn.execute(
            '''
            UPDATE tasks 
            SET status = :status,
                completed_at = CASE WHEN :check_status = 'completed' THEN NOW() ELSE NULL END
            WHERE id = :id
            ''',
            {'status': status, 'check_status': status, 'id': id},
          );

          if (employeeId != null) {
            int pct = (status == 'completed')
                ? 100
                : (status == 'review'
                      ? 90
                      : (status == 'in_progress' ? 50 : 0));
            await conn.execute(
              '''
              INSERT INTO task_progress (task_id, employee_id, status, progress_percentage, notes)
              VALUES (:task_id, :employee_id, :status, :pct, :notes)
              ''',
              {
                'task_id': id,
                'employee_id': employeeId,
                'status': status,
                'pct': pct,
                'notes': notes ?? 'Status diperbarui menjadi $status',
              },
            );
          }
        });
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updateTaskStatus: $err');
      final idx = _fallbackTasks.indexWhere((t) => t.id == id);
      if (idx >= 0) {
        final t = _fallbackTasks[idx];
        _fallbackTasks[idx] = TaskModel(
          id: t.id,
          categoryId: t.categoryId,
          categoryName: t.categoryName,
          createdBy: t.createdBy,
          assignedTo: t.assignedTo,
          assignedToName: t.assignedToName,
          employeeCode: t.employeeCode,
          title: t.title,
          description: t.description,
          priority: t.priority,
          status: status,
          estimatedHours: t.estimatedHours,
          actualHours: t.actualHours,
          startDate: t.startDate,
          deadline: t.deadline,
          completedAt: status == 'completed'
              ? DateTime.now().toIso8601String()
              : null,
        );
      }
      return true;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute('DELETE FROM tasks WHERE id = :id', {
          'id': id,
        });
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback deleteTask: $err');
      _fallbackTasks.removeWhere((t) => t.id == id);
      return true;
    }
  }

  Future<Map<String, int>> getJobdeskSummaryMetrics(int employeeId) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          '''
          SELECT 
            COUNT(CASE WHEN status IN ('not_started', 'in_progress', 'review') THEN 1 END) AS total_active,
            COUNT(CASE WHEN status = 'not_started' THEN 1 END) AS not_started_count,
            COUNT(CASE WHEN status = 'in_progress' THEN 1 END) AS in_progress_count,
            COUNT(CASE WHEN status = 'review' THEN 1 END) AS review_count,
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
            'not_started_count':
                int.tryParse(data['not_started_count'] ?? '') ?? 0,
            'in_progress_count':
                int.tryParse(data['in_progress_count'] ?? '') ?? 0,
            'review_count': int.tryParse(data['review_count'] ?? '') ?? 0,
            'completed_count': int.tryParse(data['completed_count'] ?? '') ?? 0,
          };
        }
        return {
          'total_active': 0,
          'not_started_count': 0,
          'in_progress_count': 0,
          'review_count': 0,
          'completed_count': 0,
        };
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getJobdeskSummaryMetrics: $err');
      final myTasks = _fallbackTasks.where((t) => t.assignedTo == employeeId);
      return {
        'total_active': myTasks.where((t) => t.status != 'completed').length,
        'not_started_count': myTasks
            .where((t) => t.status == 'not_started')
            .length,
        'in_progress_count': myTasks
            .where((t) => t.status == 'in_progress')
            .length,
        'review_count': myTasks.where((t) => t.status == 'review').length,
        'completed_count': myTasks.where((t) => t.status == 'completed').length,
      };
    }
  }
}

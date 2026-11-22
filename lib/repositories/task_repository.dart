import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/core/database/koneksi.dart';
import 'package:kita_kerja/models/task_model.dart';
import 'package:kita_kerja/models/task_progress_model.dart';

class TaskRepository {
  static List<TaskProgressModel> _fallbackTaskProgress = _createInitialTaskProgress();
  static List<TaskModel> _fallbackTasks = _createInitialTasks();

  static void resetFallbackData() {
    _fallbackTaskProgress = _createInitialTaskProgress();
    _fallbackTasks = _createInitialTasks();
  }

  static List<TaskProgressModel> _createInitialTaskProgress() => [
    TaskProgressModel(
      id: 1,
      taskId: 1,
      taskTitle: 'Input data penjualan harian',
      employeeId: 3,
      employeeName: 'Citra Staff',
      employeeCode: 'EMP003',
      status: 'in_progress',
      progressPercentage: 50,
      notes: 'Data penjualan tanggal 1-2 sudah diinput',
      recordedAt: '2026-09-02 10:00:00',
    ),
    TaskProgressModel(
      id: 2,
      taskId: 2,
      taskTitle: 'Buat konten promosi Instagram',
      employeeId: 4,
      employeeName: 'Dedi Staff',
      employeeCode: 'EMP004',
      status: 'review',
      progressPercentage: 100,
      notes: 'Menunggu review manager',
      recordedAt: '2026-09-02 14:00:00',
    ),
    TaskProgressModel(
      id: 3,
      taskId: 3,
      taskTitle: 'Perbaiki bug halaman login',
      employeeId: 5,
      employeeName: 'Eka Staff',
      employeeCode: 'EMP005',
      status: 'completed',
      progressPercentage: 100,
      notes: 'Bug sudah diperbaiki dan dites',
      recordedAt: '2026-09-01 16:30:00',
    ),
    TaskProgressModel(
      id: 4,
      taskId: 4,
      taskTitle: 'Setup backup database mingguan',
      employeeId: 6,
      employeeName: 'Fajar Staff',
      employeeCode: 'EMP006',
      status: 'not_started',
      progressPercentage: 0,
      notes: 'Belum mulai',
      recordedAt: '2026-09-03 08:00:00',
    ),
  ];

  static List<TaskModel> _createInitialTasks() => [
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
      progressPercentage: 50,
      latestNotes: 'Data penjualan tanggal 1-2 sudah diinput',
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
      progressPercentage: 100,
      latestNotes: 'Menunggu review manager',
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
      progressPercentage: 100,
      latestNotes: 'Bug sudah diperbaiki dan dites',
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
      progressPercentage: 0,
      latestNotes: 'Belum mulai',
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
      progressPercentage: 0,
    ),
  ];

  Future<List<TaskModel>> getTasks({
    String? search,
    String? status,
    int? supervisorId,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {};
        List<String> conditions = [];
        String joinSupervisor = '';

        if (supervisorId != null && supervisorId > 0) {
          joinSupervisor = 'LEFT JOIN employee_supervisors es ON t.assigned_to = es.employee_id';
          conditions.add('(es.supervisor_id = :sup_id OR t.assigned_to = :sup_id OR t.created_by = :sup_id)');
          params['sup_id'] = supervisorId;
        }

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
            e.full_name AS assigned_to_name, e.employee_code,
            COALESCE(ltp.progress_percentage, CASE WHEN t.status = 'completed' THEN 100 WHEN t.status = 'review' THEN 90 WHEN t.status = 'in_progress' THEN 50 ELSE 0 END) AS progress_percentage,
            ltp.notes AS latest_notes
          FROM tasks t
          INNER JOIN job_categories jc ON t.category_id = jc.id
          INNER JOIN employees e ON t.assigned_to = e.id
          LEFT JOIN (
            SELECT tp1.task_id, tp1.progress_percentage, tp1.notes
            FROM task_progress tp1
            INNER JOIN (
              SELECT task_id, MAX(id) AS max_id FROM task_progress GROUP BY task_id
            ) tp2 ON tp1.id = tp2.max_id
          ) ltp ON t.id = ltp.task_id
          $joinSupervisor
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
            e.full_name AS assigned_to_name, e.employee_code,
            COALESCE(ltp.progress_percentage, CASE WHEN t.status = 'completed' THEN 100 WHEN t.status = 'review' THEN 90 WHEN t.status = 'in_progress' THEN 50 ELSE 0 END) AS progress_percentage,
            ltp.notes AS latest_notes
          FROM tasks t
          INNER JOIN job_categories jc ON t.category_id = jc.id
          INNER JOIN employees e ON t.assigned_to = e.id
          LEFT JOIN (
            SELECT tp1.task_id, tp1.progress_percentage, tp1.notes
            FROM task_progress tp1
            INNER JOIN (
              SELECT task_id, MAX(id) AS max_id FROM task_progress GROUP BY task_id
            ) tp2 ON tp1.id = tp2.max_id
          ) ltp ON t.id = ltp.task_id
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

  Future<List<TaskProgressModel>> getTaskProgress(int taskId) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          '''
          SELECT 
            tp.id, tp.task_id, tp.employee_id, tp.status, tp.progress_percentage, tp.notes, tp.recorded_at,
            t.title AS task_title,
            e.full_name AS employee_name, e.employee_code
          FROM task_progress tp
          INNER JOIN tasks t ON tp.task_id = t.id
          INNER JOIN employees e ON tp.employee_id = e.id
          WHERE tp.task_id = :task_id
          ORDER BY tp.recorded_at DESC, tp.id DESC
          ''',
          {'task_id': taskId},
        );
        return results.rows
            .map((row) => TaskProgressModel.fromMap(row.assoc()))
            .toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getTaskProgress: $err');
      return _fallbackTaskProgress
          .where((p) => p.taskId == taskId)
          .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    }
  }

  Future<bool> addTaskProgress({
    required int taskId,
    required int employeeId,
    required String status,
    required int progressPercentage,
    String? notes,
    double? actualHours,
    String? employeeName,
    String? employeeCode,
    String? taskTitle,
  }) async {
    final nowStr = DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19);
    final cleanNotes = (notes != null && notes.trim().isNotEmpty)
        ? notes.trim()
        : 'Update progres $progressPercentage% (${status.replaceAll('_', ' ')})';

    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.transactional((conn) async {
          await conn.execute(
            '''
            INSERT INTO task_progress (task_id, employee_id, status, progress_percentage, notes, recorded_at)
            VALUES (:task_id, :employee_id, :status, :pct, :notes, NOW())
            ''',
            {
              'task_id': taskId,
              'employee_id': employeeId,
              'status': status,
              'pct': progressPercentage,
              'notes': cleanNotes,
            },
          );

          await conn.execute(
            '''
            UPDATE tasks
            SET 
              status = :status,
              actual_hours = CASE WHEN :actual_hours > 0 THEN :actual_hours ELSE actual_hours END,
              completed_at = CASE WHEN :status = 'completed' THEN NOW() ELSE NULL END
            WHERE id = :task_id
            ''',
            {
              'task_id': taskId,
              'status': status,
              'actual_hours': actualHours ?? 0.0,
            },
          );
        });
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback addTaskProgress: $err');
      final newProg = TaskProgressModel(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        taskId: taskId,
        taskTitle: taskTitle,
        employeeId: employeeId,
        employeeName: employeeName ?? 'Karyawan',
        employeeCode: employeeCode ?? 'EMP003',
        status: status,
        progressPercentage: progressPercentage,
        notes: cleanNotes,
        recordedAt: nowStr,
      );
      _fallbackTaskProgress.insert(0, newProg);

      final idx = _fallbackTasks.indexWhere((t) => t.id == taskId);
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
          actualHours: (actualHours != null && actualHours > 0) ? actualHours : t.actualHours,
          startDate: t.startDate,
          deadline: t.deadline,
          completedAt: status == 'completed' ? nowStr : null,
          progressPercentage: progressPercentage,
          latestNotes: cleanNotes,
        );
      }
      return true;
    }
  }

  Future<bool> updateTaskStatus(
    int id,
    String status, {
    int? employeeId,
    String? notes,
    int? progressPercentage,
    double? actualHours,
    String? employeeName,
    String? employeeCode,
  }) async {
    int pct = progressPercentage ??
        (status == 'completed'
            ? 100
            : (status == 'review'
                ? 90
                : (status == 'in_progress' ? 50 : 0)));

    if (employeeId != null) {
      return addTaskProgress(
        taskId: id,
        employeeId: employeeId,
        status: status,
        progressPercentage: pct,
        notes: notes,
        actualHours: actualHours,
        employeeName: employeeName,
        employeeCode: employeeCode,
      );
    }

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
          {'status': status, 'check_status': status, 'id': id},
        );
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
          progressPercentage: pct,
          latestNotes: notes ?? t.latestNotes,
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

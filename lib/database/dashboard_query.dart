import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk Dashboard & Workload Records
class DashboardQuery {
  /// SQL Query: Mengambil ringkasan data komprehensif untuk Dashboard
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        // 1. Total Karyawan Aktif
        var empResults = await connection.execute(
          "SELECT COUNT(*) AS total_count FROM employees WHERE status = 'active'",
        );
        int totalEmployees = empResults.rows.isNotEmpty
            ? (int.tryParse(empResults.rows.first.assoc()['total_count'] ?? '') ?? 0)
            : 0;

        // 2. Kehadiran Hari Ini (atau tanggal kehadiran terbaru)
        var maxDateRes = await connection.execute(
          "SELECT MAX(attendance_date) AS max_date FROM attendances",
        );
        String? latestDateStr = maxDateRes.rows.isNotEmpty
            ? maxDateRes.rows.first.assoc()['max_date']
            : null;
        if (latestDateStr != null && latestDateStr.contains(' ')) {
          latestDateStr = latestDateStr.split(' ')[0];
        }

        int presentToday = 0;
        int overtimeCount = 0;

        if (latestDateStr != null && latestDateStr.isNotEmpty) {
          var attSummaryRes = await connection.execute(
            '''
            SELECT 
              COUNT(CASE WHEN status IN ('present', 'late') THEN 1 END) AS present_count,
              COUNT(CASE WHEN overtime_minutes > 0 THEN 1 END) AS overtime_count
            FROM attendances
            WHERE attendance_date = :att_date
            ''',
            {'att_date': latestDateStr},
          );
          if (attSummaryRes.rows.isNotEmpty) {
            var data = attSummaryRes.rows.first.assoc();
            presentToday =
                int.tryParse(data['present_count'] ?? '') ?? 0;
            overtimeCount =
                int.tryParse(data['overtime_count'] ?? '') ?? 0;
          }
        }

        // 3. Pekerjaan Aktif & Jumlah Tim
        var taskSummaryRes = await connection.execute('''
          SELECT 
            COUNT(*) AS active_tasks,
            COUNT(DISTINCT e.department_id) AS active_teams
          FROM tasks t
          INNER JOIN employees e ON t.assigned_to = e.id
          WHERE t.status IN ('not_started', 'in_progress', 'review')
          ''');
        int activeTasks = 0;
        int activeTeams = 0;
        if (taskSummaryRes.rows.isNotEmpty) {
          var data = taskSummaryRes.rows.first.assoc();
          activeTasks =
              int.tryParse(data['active_tasks'] ?? '') ?? 0;
          activeTeams =
              int.tryParse(data['active_teams'] ?? '') ?? 0;
        }

        // 4. Beban Kerja Per Karyawan (Workload Records)
        var workloadResults = await connection.execute('''
          SELECT 
            w.id, w.capacity_hours, w.assigned_hours, w.actual_hours, w.workload_percentage, w.status,
            e.full_name AS employee_name, e.employee_code, d.name AS department_name
          FROM workload_records w
          INNER JOIN employees e ON w.employee_id = e.id
          LEFT JOIN departments d ON e.department_id = d.id
          ORDER BY w.workload_percentage DESC, w.id DESC
          LIMIT 6
          ''');

        List<Map<String, dynamic>> workloadList = [];
        Map<String, dynamic>? overloadedEmployee;

        for (var row in workloadResults.rows) {
          var data = row.assoc();
          double pct =
              double.tryParse(data['workload_percentage'] ?? '') ?? 0.0;
          double capHours =
              double.tryParse(data['capacity_hours'] ?? '') ?? 0.0;
          double assHours =
              double.tryParse(data['assigned_hours'] ?? '') ?? 0.0;
          double actHours =
              double.tryParse(data['actual_hours'] ?? '') ?? 0.0;
          int id = int.tryParse(data['id'] ?? '') ?? 0;
          String status = data['status'] ?? 'normal';

          final item = {
            'id': id,
            'name': data['employee_name'] ?? '',
            'employee_code': data['employee_code'] ?? '',
            'department_name': data['department_name'] ?? '',
            'capacity_hours': capHours,
            'assigned_hours': assHours,
            'actual_hours': actHours,
            'percentage': pct,
            'factor': pct / 100.0,
            'percentage_text':
                '${pct.toStringAsFixed(1).replaceAll('.', ',')}%',
            'is_overload':
                pct > 100.0 ||
                status == 'high' ||
                status == 'overload',
            'status': status,
          };
          workloadList.add(item);
          if (overloadedEmployee == null && item['is_overload'] == true) {
            overloadedEmployee = item;
          }
        }

        // 5. Daftar Kehadiran Hari Ini (5 Teratas)
        List<Map<String, dynamic>> attendanceList = [];
        if (latestDateStr != null && latestDateStr.isNotEmpty) {
          var attListRes = await connection.execute(
            '''
            SELECT 
              a.id, a.clock_in, a.clock_out, a.overtime_minutes, a.status,
              e.full_name AS employee_name, e.employee_code
            FROM attendances a
            INNER JOIN employees e ON a.employee_id = e.id
            WHERE a.attendance_date = :att_date
            ORDER BY a.clock_in ASC, a.id ASC
            LIMIT 5
            ''',
            {'att_date': latestDateStr},
          );
          for (var row in attListRes.rows) {
            var data = row.assoc();
            String clockInStr = '-';
            if (data['clock_in'] != null && data['clock_in']!.isNotEmpty) {
              final s = data['clock_in']!;
              clockInStr = s.contains(' ')
                  ? s.split(' ')[1].substring(0, 5)
                  : (s.length >= 5 ? s.substring(0, 5) : s);
            }
            String clockOutStr = '-';
            if (data['clock_out'] != null && data['clock_out']!.isNotEmpty) {
              final s = data['clock_out']!;
              clockOutStr = s.contains(' ')
                  ? s.split(' ')[1].substring(0, 5)
                  : (s.length >= 5 ? s.substring(0, 5) : s);
            }

            int otMin = int.tryParse(data['overtime_minutes'] ?? '') ?? 0;
            attendanceList.add({
              'id': int.tryParse(data['id'] ?? '') ?? 0,
              'employee_name': data['employee_name'] ?? '',
              'clock_in': clockInStr,
              'clock_out': clockOutStr,
              'is_overtime': otMin > 0,
              'overtime_minutes': otMin,
              'status': data['status'] ?? 'present',
            });
          }
        }

        // 6. Pekerjaan Mendekati Deadline (Tasks)
        var taskListRes = await connection.execute('''
          SELECT 
            t.id, t.title, t.priority, t.status, t.deadline,
            e.full_name AS assigned_to_name,
            jc.name AS category_name
          FROM tasks t
          INNER JOIN employees e ON t.assigned_to = e.id
          LEFT JOIN job_categories jc ON t.category_id = jc.id
          WHERE t.status != 'completed'
          ORDER BY t.deadline ASC, t.id DESC
          LIMIT 5
          ''');
        List<Map<String, dynamic>> taskList = [];
        for (var row in taskListRes.rows) {
          var data = row.assoc();
          taskList.add({
            'id': int.tryParse(data['id'] ?? '') ?? 0,
            'title': data['title'] ?? '',
            'assigned_to_name': data['assigned_to_name'] ?? '',
            'deadline': (data['deadline'] ?? '').split(' ')[0],
            'status': data['status'] ?? 'not_started',
            'priority': data['priority'] ?? 'medium',
            'category_name': data['category_name'] ?? '',
          });
        }

        double presentPct = totalEmployees > 0
            ? (presentToday / totalEmployees) * 100
            : 0.0;

        return {
          'total_employees': totalEmployees,
          'present_today': presentToday,
          'present_percentage': '${presentPct.toStringAsFixed(1)}%',
          'active_tasks': activeTasks,
          'active_teams_count': activeTeams,
          'overtime_count': overtimeCount,
          'overloaded_employee': overloadedEmployee,
          'workload_list': workloadList,
          'attendance_list': attendanceList,
          'task_list': taskList,
        };
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Dashboard Fallback: $err');
      return _getDashboardFallbackData();
    }
  }

  Map<String, dynamic> _getDashboardFallbackData() {
    return {
      'total_employees': 6,
      'present_today': 4,
      'present_percentage': '66.7%',
      'active_tasks': 3,
      'active_teams_count': 3,
      'overtime_count': 1,
      'overloaded_employee': {
        'name': 'Dedi Staff',
        'percentage_text': '112,5%',
        'percentage': 112.5,
      },
      'workload_list': [
        {
          'id': 2,
          'name': 'Dedi Staff',
          'factor': 1.125,
          'percentage': 112.5,
          'percentage_text': '112,5%',
          'is_overload': true,
        },
        {
          'id': 3,
          'name': 'Eka Staff',
          'factor': 0.875,
          'percentage': 87.5,
          'percentage_text': '87,5%',
          'is_overload': false,
        },
        {
          'id': 1,
          'name': 'Citra Staff',
          'factor': 0.75,
          'percentage': 75.0,
          'percentage_text': '75%',
          'is_overload': false,
        },
        {
          'id': 4,
          'name': 'Fajar Staff',
          'factor': 0.375,
          'percentage': 37.5,
          'percentage_text': '37,5%',
          'is_overload': false,
        },
      ],
      'attendance_list': [
        {
          'id': 1,
          'employee_name': 'Citra Staff',
          'clock_in': '08:00',
          'clock_out': '17:00',
          'is_overtime': false,
          'status': 'present',
        },
        {
          'id': 3,
          'employee_name': 'Dedi Staff',
          'clock_in': '07:00',
          'clock_out': '15:00',
          'is_overtime': false,
          'status': 'present',
        },
        {
          'id': 5,
          'employee_name': 'Eka Staff',
          'clock_in': '08:05',
          'clock_out': '18:00',
          'is_overtime': true,
          'status': 'present',
        },
        {
          'id': 6,
          'employee_name': 'Fajar Staff',
          'clock_in': '08:00',
          'clock_out': '17:00',
          'is_overtime': false,
          'status': 'present',
        },
      ],
      'task_list': [
        {
          'id': 1,
          'title': 'Input data penjualan harian',
          'assigned_to_name': 'Citra Staff',
          'deadline': '2026-09-05',
          'status': 'in_progress',
          'priority': 'high',
        },
        {
          'id': 2,
          'title': 'Buat konten promosi Instagram',
          'assigned_to_name': 'Dedi Staff',
          'deadline': '2026-09-03',
          'status': 'review',
          'priority': 'medium',
        },
        {
          'id': 4,
          'title': 'Setup backup database mingguan',
          'assigned_to_name': 'Fajar Staff',
          'deadline': '2026-09-07',
          'status': 'not_started',
          'priority': 'high',
        },
      ],
    };
  }
}

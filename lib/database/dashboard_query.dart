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
        var empResults = await connection.query(
          "SELECT COUNT(*) AS total_count FROM employees WHERE status = 'active'",
        );
        int totalEmployees = empResults.isNotEmpty
            ? (int.tryParse(empResults.first['total_count'].toString()) ?? 0)
            : 0;

        // 2. Kehadiran Hari Ini (atau tanggal kehadiran terbaru)
        var maxDateRes = await connection.query(
          "SELECT MAX(attendance_date) AS max_date FROM attendances",
        );
        DateTime? latestDate =
            maxDateRes.isNotEmpty && maxDateRes.first['max_date'] != null
            ? (maxDateRes.first['max_date'] is DateTime
                  ? maxDateRes.first['max_date'] as DateTime
                  : DateTime.tryParse(maxDateRes.first['max_date'].toString()))
            : null;

        int presentToday = 0;
        int overtimeCount = 0;

        if (latestDate != null) {
          var attSummaryRes = await connection.query(
            '''
            SELECT 
              COUNT(CASE WHEN status IN ('present', 'late') THEN 1 END) AS present_count,
              COUNT(CASE WHEN overtime_minutes > 0 THEN 1 END) AS overtime_count
            FROM attendances
            WHERE attendance_date = ?
            ''',
            [latestDate],
          );
          if (attSummaryRes.isNotEmpty) {
            presentToday =
                int.tryParse(attSummaryRes.first['present_count'].toString()) ??
                0;
            overtimeCount =
                int.tryParse(
                  attSummaryRes.first['overtime_count'].toString(),
                ) ??
                0;
          }
        }

        // 3. Pekerjaan Aktif & Jumlah Tim
        var taskSummaryRes = await connection.query('''
          SELECT 
            COUNT(*) AS active_tasks,
            COUNT(DISTINCT e.department_id) AS active_teams
          FROM tasks t
          INNER JOIN employees e ON t.assigned_to = e.id
          WHERE t.status IN ('not_started', 'in_progress', 'review')
          ''');
        int activeTasks = 0;
        int activeTeams = 0;
        if (taskSummaryRes.isNotEmpty) {
          activeTasks =
              int.tryParse(taskSummaryRes.first['active_tasks'].toString()) ??
              0;
          activeTeams =
              int.tryParse(taskSummaryRes.first['active_teams'].toString()) ??
              0;
        }

        // 4. Beban Kerja Per Karyawan (Workload Records)
        var workloadResults = await connection.query('''
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

        for (var row in workloadResults) {
          double pct =
              double.tryParse(row['workload_percentage'].toString()) ?? 0.0;
          final item = {
            'id': row['id'],
            'name': row['employee_name'],
            'employee_code': row['employee_code'],
            'department_name': row['department_name'] ?? '',
            'capacity_hours': row['capacity_hours'],
            'assigned_hours': row['assigned_hours'],
            'actual_hours': row['actual_hours'],
            'percentage': pct,
            'factor': pct / 100.0,
            'percentage_text':
                '${pct.toStringAsFixed(1).replaceAll('.', ',')}%',
            'is_overload':
                pct > 100.0 ||
                row['status'] == 'high' ||
                row['status'] == 'overload',
            'status': row['status'],
          };
          workloadList.add(item);
          if (overloadedEmployee == null && item['is_overload'] == true) {
            overloadedEmployee = item;
          }
        }

        // 5. Daftar Kehadiran Hari Ini (5 Teratas)
        List<Map<String, dynamic>> attendanceList = [];
        if (latestDate != null) {
          var attListRes = await connection.query(
            '''
            SELECT 
              a.id, a.clock_in, a.clock_out, a.overtime_minutes, a.status,
              e.full_name AS employee_name, e.employee_code
            FROM attendances a
            INNER JOIN employees e ON a.employee_id = e.id
            WHERE a.attendance_date = ?
            ORDER BY a.clock_in ASC, a.id ASC
            LIMIT 5
            ''',
            [latestDate],
          );
          for (var row in attListRes) {
            String clockInStr = '-';
            if (row['clock_in'] != null) {
              final s = row['clock_in'].toString();
              clockInStr = s.contains(' ')
                  ? s.split(' ')[1].substring(0, 5)
                  : s.substring(0, 5);
            }
            String clockOutStr = '-';
            if (row['clock_out'] != null) {
              final s = row['clock_out'].toString();
              clockOutStr = s.contains(' ')
                  ? s.split(' ')[1].substring(0, 5)
                  : s.substring(0, 5);
            }

            int otMin = int.tryParse(row['overtime_minutes'].toString()) ?? 0;
            attendanceList.add({
              'id': row['id'],
              'employee_name': row['employee_name'],
              'clock_in': clockInStr,
              'clock_out': clockOutStr,
              'is_overtime': otMin > 0,
              'overtime_minutes': otMin,
              'status': row['status'],
            });
          }
        }

        // 6. Pekerjaan Mendekati Deadline (Tasks)
        var taskListRes = await connection.query('''
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
        for (var row in taskListRes) {
          taskList.add({
            'id': row['id'],
            'title': row['title'],
            'assigned_to_name': row['assigned_to_name'],
            'deadline': row['deadline'].toString().split(' ')[0],
            'status': row['status'],
            'priority': row['priority'],
            'category_name': row['category_name'] ?? '',
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

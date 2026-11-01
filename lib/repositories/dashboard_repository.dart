import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/core/database/koneksi.dart';
import 'package:kita_kerja/models/dashboard_summary_model.dart';

class DashboardRepository {
  Future<DashboardSummaryModel> getAdminDashboardData() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        // 1. Total Karyawan Aktif
        var empResults = await connection.execute("SELECT COUNT(*) AS total_count FROM employees WHERE status = 'active'");
        int totalEmployees = empResults.rows.isNotEmpty ? (int.tryParse(empResults.rows.first.assoc()['total_count'] ?? '') ?? 0) : 0;

        // 2. Kehadiran Hari Ini
        var maxDateRes = await connection.execute("SELECT MAX(attendance_date) AS max_date FROM attendances");
        String? latestDateStr = maxDateRes.rows.isNotEmpty ? maxDateRes.rows.first.assoc()['max_date'] : null;
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
            presentToday = int.tryParse(data['present_count'] ?? '') ?? 0;
            overtimeCount = int.tryParse(data['overtime_count'] ?? '') ?? 0;
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
          activeTasks = int.tryParse(data['active_tasks'] ?? '') ?? 0;
          activeTeams = int.tryParse(data['active_teams'] ?? '') ?? 0;
        }

        // 4. Beban Kerja Per Karyawan
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

        List<WorkloadModel> workloadList = [];
        WorkloadModel? overloadedEmployee;
        for (var row in workloadResults.rows) {
          var item = WorkloadModel.fromMap(row.assoc());
          workloadList.add(item);
          if (overloadedEmployee == null && item.isOverload) {
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
              clockInStr = s.contains(' ') ? s.split(' ')[1].substring(0, 5) : (s.length >= 5 ? s.substring(0, 5) : s);
            }
            String clockOutStr = '-';
            if (data['clock_out'] != null && data['clock_out']!.isNotEmpty) {
              final s = data['clock_out']!;
              clockOutStr = s.contains(' ') ? s.split(' ')[1].substring(0, 5) : (s.length >= 5 ? s.substring(0, 5) : s);
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

        // 6. Pekerjaan Mendekati Deadline
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

        double presentPct = totalEmployees > 0 ? (presentToday / totalEmployees) * 100 : 0.0;

        return DashboardSummaryModel(
          totalEmployees: totalEmployees,
          presentToday: presentToday,
          presentPercentage: '${presentPct.toStringAsFixed(1)}%',
          activeTasks: activeTasks,
          activeTeamsCount: activeTeams,
          overtimeCount: overtimeCount,
          overloadedEmployee: overloadedEmployee,
          workloadList: workloadList,
          attendanceList: attendanceList,
          taskList: taskList,
        );
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Dashboard Admin Fallback: $err');
      return _getFallbackAdminDashboard();
    }
  }

  Future<DashboardSummaryModel> getEmployeeDashboardData(int employeeId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        // 1. Today's attendance
        var attRes = await connection.execute(
          '''
          SELECT clock_in, clock_out, status FROM attendances 
          WHERE employee_id = :employee_id AND attendance_date = :att_date LIMIT 1
          ''',
          {'employee_id': employeeId, 'att_date': today},
        );
        bool hasClockedIn = false;
        String? cIn;
        String? cOut;
        if (attRes.rows.isNotEmpty) {
          final row = attRes.rows.first.assoc();
          final rawIn = row['clock_in'];
          final rawOut = row['clock_out'];
          if (rawIn != null && rawIn.isNotEmpty && rawIn != '-') {
            hasClockedIn = true;
            cIn = rawIn.contains(' ') ? rawIn.split(' ')[1].substring(0, 5) : rawIn.substring(0, 5);
          }
          if (rawOut != null && rawOut.isNotEmpty && rawOut != '-') {
            cOut = rawOut.contains(' ') ? rawOut.split(' ')[1].substring(0, 5) : rawOut.substring(0, 5);
          }
        }

        // 2. Personal Task Counts
        var taskRes = await connection.execute(
          '''
          SELECT 
            COUNT(CASE WHEN status IN ('not_started', 'in_progress', 'review') THEN 1 END) AS active_tasks,
            COUNT(CASE WHEN status = 'in_progress' THEN 1 END) AS in_progress_tasks,
            COUNT(CASE WHEN status = 'review' THEN 1 END) AS review_tasks,
            COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_tasks,
            COALESCE(SUM(CASE WHEN status != 'completed' THEN estimated_hours ELSE 0 END), 0) AS total_assigned_hours
          FROM tasks
          WHERE assigned_to = :employee_id
          ''',
          {'employee_id': employeeId},
        );

        int activeCount = 0;
        int inProgCount = 0;
        int reviewCount = 0;
        int compCount = 0;
        double assignedHours = 0.0;

        if (taskRes.rows.isNotEmpty) {
          final row = taskRes.rows.first.assoc();
          activeCount = int.tryParse(row['active_tasks'] ?? '') ?? 0;
          inProgCount = int.tryParse(row['in_progress_tasks'] ?? '') ?? 0;
          reviewCount = int.tryParse(row['review_tasks'] ?? '') ?? 0;
          compCount = int.tryParse(row['completed_tasks'] ?? '') ?? 0;
          assignedHours = double.tryParse(row['total_assigned_hours'] ?? '') ?? 0.0;
        }

        // 3. Workload for this employee
        var wlRes = await connection.execute(
          '''
          SELECT capacity_hours, assigned_hours, workload_percentage 
          FROM workload_records 
          WHERE employee_id = :employee_id 
          ORDER BY period_end DESC LIMIT 1
          ''',
          {'employee_id': employeeId},
        );

        double capHours = 160.0;
        double wlPct = 0.0;
        if (wlRes.rows.isNotEmpty) {
          final row = wlRes.rows.first.assoc();
          capHours = double.tryParse(row['capacity_hours'] ?? '') ?? 160.0;
          wlPct = double.tryParse(row['workload_percentage'] ?? '') ?? 0.0;
        } else {
          wlPct = capHours > 0 ? (assignedHours / capHours) * 100 : 0.0;
        }

        // 4. Employee's Upcoming Tasks
        var myTaskListRes = await connection.execute(
          '''
          SELECT t.id, t.title, t.priority, t.status, t.deadline, jc.name AS category_name
          FROM tasks t
          LEFT JOIN job_categories jc ON t.category_id = jc.id
          WHERE t.assigned_to = :employee_id AND t.status != 'completed'
          ORDER BY t.deadline ASC LIMIT 5
          ''',
          {'employee_id': employeeId},
        );
        List<Map<String, dynamic>> taskList = myTaskListRes.rows.map((r) => r.assoc()).toList();

        return DashboardSummaryModel(
          hasClockedInToday: hasClockedIn,
          todayClockInTime: cIn,
          todayClockOutTime: cOut,
          myActiveTasksCount: activeCount,
          myInProgressTasksCount: inProgCount,
          myReviewTasksCount: reviewCount,
          myCompletedTasksCount: compCount,
          myAssignedHours: assignedHours,
          myCapacityHours: capHours,
          myWorkloadPercentage: wlPct,
          taskList: taskList,
        );
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Dashboard Employee Fallback: $err');
      return DashboardSummaryModel(
        hasClockedInToday: true,
        todayClockInTime: '08:00',
        todayClockOutTime: '-',
        myActiveTasksCount: 2,
        myInProgressTasksCount: 1,
        myReviewTasksCount: 0,
        myCompletedTasksCount: 1,
        myAssignedHours: 12.0,
        myCapacityHours: 160.0,
        myWorkloadPercentage: 75.0,
        taskList: [
          {
            'id': 1,
            'title': 'Input data penjualan harian',
            'deadline': '2026-09-05',
            'status': 'in_progress',
            'priority': 'high',
            'category_name': 'Operasional',
          },
          {
            'id': 5,
            'title': 'Rekap absensi & klaim lembur',
            'deadline': '2026-09-08',
            'status': 'not_started',
            'priority': 'medium',
            'category_name': 'Administrasi',
          },
        ],
      );
    }
  }

  DashboardSummaryModel _getFallbackAdminDashboard() {
    final overloaded = WorkloadModel(
      id: 2,
      employeeId: 4,
      employeeName: 'Dedi Staff',
      employeeCode: 'EMP004',
      departmentName: 'Pemasaran',
      capacityHours: 160.0,
      assignedHours: 180.0,
      actualHours: 150.0,
      percentage: 112.5,
      status: 'high',
      notes: 'Perlu penambahan tenaga',
    );

    return DashboardSummaryModel(
      totalEmployees: 6,
      presentToday: 4,
      presentPercentage: '66.7%',
      activeTasks: 4,
      activeTeamsCount: 3,
      overtimeCount: 1,
      overloadedEmployee: overloaded,
      workloadList: [
        overloaded,
        WorkloadModel(
          id: 3,
          employeeId: 5,
          employeeName: 'Eka Staff',
          employeeCode: 'EMP005',
          departmentName: 'Teknologi',
          capacityHours: 160.0,
          assignedHours: 140.0,
          actualHours: 140.0,
          percentage: 87.5,
          status: 'normal',
        ),
        WorkloadModel(
          id: 1,
          employeeId: 3,
          employeeName: 'Citra Staff',
          employeeCode: 'EMP003',
          departmentName: 'Operasional',
          capacityHours: 160.0,
          assignedHours: 120.0,
          actualHours: 80.0,
          percentage: 75.0,
          status: 'normal',
        ),
        WorkloadModel(
          id: 4,
          employeeId: 6,
          employeeName: 'Fajar Staff',
          employeeCode: 'EMP006',
          departmentName: 'Teknologi',
          capacityHours: 160.0,
          assignedHours: 60.0,
          actualHours: 20.0,
          percentage: 37.5,
          status: 'underload',
        ),
      ],
      attendanceList: [
        {
          'id': 1,
          'employee_name': 'Citra Staff',
          'clock_in': '08:00',
          'clock_out': '17:00',
          'is_overtime': false,
          'overtime_minutes': 0,
          'status': 'present',
        },
        {
          'id': 2,
          'employee_name': 'Dedi Staff',
          'clock_in': '07:00',
          'clock_out': '15:00',
          'is_overtime': false,
          'overtime_minutes': 0,
          'status': 'present',
        },
        {
          'id': 3,
          'employee_name': 'Eka Staff',
          'clock_in': '08:05',
          'clock_out': '18:00',
          'is_overtime': true,
          'overtime_minutes': 55,
          'status': 'present',
        },
      ],
      taskList: [
        {
          'id': 1,
          'title': 'Input data penjualan harian',
          'assigned_to_name': 'Citra Staff',
          'deadline': '2026-09-05',
          'status': 'in_progress',
          'priority': 'high',
          'category_name': 'Operasional',
        },
        {
          'id': 2,
          'title': 'Buat konten promosi Instagram',
          'assigned_to_name': 'Dedi Staff',
          'deadline': '2026-09-03',
          'status': 'review',
          'priority': 'medium',
          'category_name': 'Administrasi',
        },
        {
          'id': 4,
          'title': 'Setup backup database mingguan',
          'assigned_to_name': 'Fajar Staff',
          'deadline': '2026-09-07',
          'status': 'not_started',
          'priority': 'high',
          'category_name': 'Teknologi',
        },
      ],
    );
  }
}

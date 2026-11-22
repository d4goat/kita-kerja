import 'package:flutter/material.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/core/database/koneksi.dart';
import 'package:kita_kerja/models/dashboard_summary_model.dart';
import 'package:kita_kerja/models/report_model.dart';

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

  /// Mengambil data pelaporan analitik dari database MySQL menggunakan query agregasi
  /// dengan kemampuan data filtering (periode, departemen, status) dan data grouping.
  Future<DashboardReportData> getReportData(
    ReportFilter filter, {
    int? supervisorId,
    int? employeeId,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        // 1. Siapkan Filter Kondisi SQL
        final taskConditions = <String>[];
        final taskParams = <String, dynamic>{};

        if (filter.department != 'all') {
          taskConditions.add('d.name = :dept_name');
          taskParams['dept_name'] = filter.department;
        }

        if (filter.status == 'active') {
          taskConditions.add("t.status IN ('not_started', 'in_progress', 'review')");
        } else if (filter.status == 'completed') {
          taskConditions.add("t.status = 'completed'");
        }

        if (employeeId != null) {
          taskConditions.add('t.assigned_to = :emp_id');
          taskParams['emp_id'] = employeeId;
        } else if (supervisorId != null) {
          taskConditions.add(
            '(es.supervisor_id = :sup_id OR t.assigned_to = :sup_id OR t.created_by = :sup_id)',
          );
          taskParams['sup_id'] = supervisorId;
        }

        String taskWhereClause = taskConditions.isNotEmpty
            ? 'WHERE ${taskConditions.join(" AND ")}'
            : '';

        String joinSupervisor = (supervisorId != null)
            ? 'LEFT JOIN employee_supervisors es ON t.assigned_to = es.employee_id'
            : '';

        // 2. Query Bar Chart Berdasarkan Data Grouping
        String groupColumn;
        String groupSelect;
        String fromTable;

        switch (filter.groupBy) {
          case 'category':
            groupSelect = 'jc.name';
            groupColumn = 'jc.name';
            fromTable = '''
              tasks t
              INNER JOIN employees e ON t.assigned_to = e.id
              INNER JOIN job_categories jc ON t.category_id = jc.id
              LEFT JOIN departments d ON e.department_id = d.id
              $joinSupervisor
            ''';
            break;
          case 'priority':
            groupSelect = 't.priority';
            groupColumn = 't.priority';
            fromTable = '''
              tasks t
              INNER JOIN employees e ON t.assigned_to = e.id
              LEFT JOIN departments d ON e.department_id = d.id
              $joinSupervisor
            ''';
            break;
          case 'status':
            groupSelect = 't.status';
            groupColumn = 't.status';
            fromTable = '''
              tasks t
              INNER JOIN employees e ON t.assigned_to = e.id
              LEFT JOIN departments d ON e.department_id = d.id
              $joinSupervisor
            ''';
            break;
          case 'department':
          default:
            groupSelect = 'd.name';
            groupColumn = 'd.name';
            fromTable = '''
              tasks t
              INNER JOIN employees e ON t.assigned_to = e.id
              INNER JOIN departments d ON e.department_id = d.id
              $joinSupervisor
            ''';
            break;
        }

        final barQuery = '''
          SELECT 
            $groupSelect AS group_label,
            COUNT(t.id) AS total_count,
            COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS completed_count,
            COUNT(CASE WHEN t.status IN ('in_progress', 'review') THEN 1 END) AS in_progress_count,
            COALESCE(SUM(t.estimated_hours), 0) AS total_estimated_hours,
            COALESCE(SUM(t.actual_hours), 0) AS total_actual_hours
          FROM $fromTable
          $taskWhereClause
          GROUP BY $groupColumn
          ORDER BY total_count DESC
        ''';

        final barResults = await connection.execute(barQuery, taskParams);

        final barChartData = <BarChartItem>[];
        final tableData = <ReportTableRowData>[];

        int totalTasksAll = 0;
        int completedTasksAll = 0;
        double totalEstHoursAll = 0;
        double totalActHoursAll = 0;

        for (var row in barResults.rows) {
          final data = row.assoc();
          final label = data['group_label']?.toString() ?? '-';
          final total = int.tryParse(data['total_count'] ?? '') ?? 0;
          final completed = int.tryParse(data['completed_count'] ?? '') ?? 0;
          final inProg = int.tryParse(data['in_progress_count'] ?? '') ?? 0;
          final estH = double.tryParse(data['total_estimated_hours'] ?? '') ?? 0.0;
          final actH = double.tryParse(data['total_actual_hours'] ?? '') ?? 0.0;
          final rate = total > 0 ? (completed / total) * 100.0 : 0.0;

          totalTasksAll += total;
          completedTasksAll += completed;
          totalEstHoursAll += estH;
          totalActHoursAll += actH;

          barChartData.add(BarChartItem(
            label: _formatGroupLabel(label, filter.groupBy),
            primaryValue: total.toDouble(),
            secondaryValue: completed.toDouble(),
          ));

          tableData.add(ReportTableRowData(
            groupName: _formatGroupLabel(label, filter.groupBy),
            totalTasks: total,
            completedTasks: completed,
            inProgressTasks: inProg,
            totalEstimatedHours: estH,
            totalActualHours: actH,
            completionRate: rate,
          ));
        }

        // 3. Query Line Chart (Tren Kehadiran & Jam Kerja Harian)
        final attConditions = <String>[];
        final attParams = <String, dynamic>{};

        if (filter.department != 'all') {
          attConditions.add('d.name = :dept_name');
          attParams['dept_name'] = filter.department;
        }

        if (employeeId != null) {
          attConditions.add('a.employee_id = :emp_id');
          attParams['emp_id'] = employeeId;
        } else if (supervisorId != null) {
          attConditions.add('(es.supervisor_id = :sup_id OR a.employee_id = :sup_id)');
          attParams['sup_id'] = supervisorId;
        }

        String attWhereClause = attConditions.isNotEmpty
            ? 'WHERE ${attConditions.join(" AND ")}'
            : '';

        String joinSupervisorAtt = (supervisorId != null)
            ? 'LEFT JOIN employee_supervisors es ON a.employee_id = es.employee_id'
            : '';

        final lineQuery = '''
          SELECT 
            a.attendance_date,
            COUNT(CASE WHEN a.status IN ('present', 'late') THEN 1 END) AS present_count,
            COUNT(CASE WHEN a.status = 'late' THEN 1 END) AS late_count,
            COALESCE(SUM(a.overtime_minutes), 0) AS total_overtime,
            COALESCE(ROUND(AVG(a.working_minutes) / 60.0, 1), 0.0) AS avg_working_hours
          FROM attendances a
          INNER JOIN employees e ON a.employee_id = e.id
          LEFT JOIN departments d ON e.department_id = d.id
          $joinSupervisorAtt
          $attWhereClause
          GROUP BY a.attendance_date
          ORDER BY a.attendance_date ASC
          LIMIT 14
        ''';

        final lineResults = await connection.execute(lineQuery, attParams);
        final lineChartData = <LineChartPoint>[];

        for (var row in lineResults.rows) {
          final data = row.assoc();
          final rawDate = data['attendance_date']?.toString() ?? '';
          final parts = rawDate.split(' ')[0].split('-');
          final shortDate = parts.length == 3 ? '${parts[2]}/${parts[1]}' : rawDate;
          final presentCount = double.tryParse(data['present_count'] ?? '') ?? 0.0;
          final avgHours = double.tryParse(data['avg_working_hours'] ?? '') ?? 0.0;

          lineChartData.add(LineChartPoint(
            xLabel: shortDate,
            value: presentCount,
            secondaryValue: avgHours,
            tooltip: 'Hadir: ${presentCount.toInt()} orang, Rata-rata: ${avgHours}j',
          ));
        }

        // 4. Query Pie Chart (Distribusi Status Tugas)
        final pieQuery = '''
          SELECT 
            t.status AS slice_label,
            COUNT(*) AS slice_count
          FROM tasks t
          INNER JOIN employees e ON t.assigned_to = e.id
          LEFT JOIN departments d ON e.department_id = d.id
          $joinSupervisor
          $taskWhereClause
          GROUP BY t.status
          ORDER BY slice_count DESC
        ''';

        final pieResults = await connection.execute(pieQuery, taskParams);
        final pieChartData = <PieChartSlice>[];

        for (var row in pieResults.rows) {
          final data = row.assoc();
          final statusKey = data['slice_label']?.toString() ?? 'not_started';
          final count = double.tryParse(data['slice_count'] ?? '') ?? 0.0;

          pieChartData.add(PieChartSlice(
            label: _formatStatusLabel(statusKey),
            value: count,
            color: _getStatusColor(statusKey),
          ));
        }

        // Hitung Summary KPIs
        final overallCompletionRate = totalTasksAll > 0
            ? (completedTasksAll / totalTasksAll) * 100.0
            : 0.0;

        final summaryKPIs = {
          'total_tasks': totalTasksAll,
          'completed_tasks': completedTasksAll,
          'completion_rate': overallCompletionRate,
          'total_estimated_hours': totalEstHoursAll,
          'total_actual_hours': totalActHoursAll,
          'efficiency_ratio': totalEstHoursAll > 0
              ? (totalActHoursAll / totalEstHoursAll) * 100.0
              : 100.0,
        };

        return DashboardReportData(
          activeFilter: filter,
          barChartData: barChartData,
          lineChartData: lineChartData,
          pieChartData: pieChartData,
          tableData: tableData,
          summaryKPIs: summaryKPIs,
        );
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Dashboard Report Fallback: $err');
      return _getFallbackReportData(filter, supervisorId, employeeId);
    }
  }

  static String _formatGroupLabel(String key, String groupBy) {
    if (groupBy == 'status') {
      return _formatStatusLabel(key);
    } else if (groupBy == 'priority') {
      switch (key.toLowerCase()) {
        case 'urgent':
          return 'Mendesak';
        case 'high':
          return 'Tinggi';
        case 'medium':
          return 'Sedang';
        case 'low':
        default:
          return 'Rendah';
      }
    }
    return key;
  }

  static String _formatStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Selesai';
      case 'review':
        return 'Ditinjau';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'not_started':
      default:
        return 'Belum Mulai';
    }
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Utils.neoGreen;
      case 'review':
        return Utils.neoYellow;
      case 'in_progress':
        return Utils.neoBlue;
      case 'not_started':
      default:
        return Utils.neoRed;
    }
  }

  DashboardReportData _getFallbackReportData(
    ReportFilter filter,
    int? supervisorId,
    int? employeeId,
  ) {
    // Dataset fallback representatif PRD untuk simulasi offline & testing
    final rawTasks = [
      {'title': 'Input data penjualan harian', 'dept': 'Operasional', 'cat': 'Operasional', 'priority': 'high', 'status': 'in_progress', 'est': 8.0, 'act': 4.0, 'emp': 3},
      {'title': 'Buat konten promosi Instagram', 'dept': 'Pemasaran', 'cat': 'Administrasi', 'priority': 'medium', 'status': 'review', 'est': 6.0, 'act': 6.0, 'emp': 4},
      {'title': 'Perbaiki bug halaman login', 'dept': 'Teknologi', 'cat': 'Teknologi', 'priority': 'urgent', 'status': 'completed', 'est': 10.0, 'act': 12.0, 'emp': 5},
      {'title': 'Setup backup database mingguan', 'dept': 'Teknologi', 'cat': 'Teknologi', 'priority': 'high', 'status': 'not_started', 'est': 5.0, 'act': 0.0, 'emp': 6},
      {'title': 'Rekap absensi & klaim lembur', 'dept': 'Operasional', 'cat': 'Administrasi', 'priority': 'medium', 'status': 'not_started', 'est': 4.0, 'act': 0.0, 'emp': 3},
      {'title': 'Audit kepatuhan SOP cabang', 'dept': 'Operasional', 'cat': 'Operasional', 'priority': 'low', 'status': 'completed', 'est': 7.0, 'act': 7.0, 'emp': 3},
      {'title': 'Riset kampanye akhir tahun', 'dept': 'Pemasaran', 'cat': 'Administrasi', 'priority': 'high', 'status': 'in_progress', 'est': 12.0, 'act': 5.0, 'emp': 4},
      {'title': 'Migrasi server cloud AWS', 'dept': 'Teknologi', 'cat': 'Teknologi', 'priority': 'urgent', 'status': 'in_progress', 'est': 16.0, 'act': 8.0, 'emp': 5},
    ];

    // Filter tasks
    var filtered = rawTasks.where((t) {
      if (employeeId != null && t['emp'] != employeeId) return false;
      if (filter.department != 'all') {
        final deptStr = (t['dept'] as String).toLowerCase();
        final filterDept = filter.department.toLowerCase();
        if (!deptStr.contains(filterDept) && !filterDept.contains(deptStr)) {
          return false;
        }
      }
      if (filter.status == 'active' && t['status'] == 'completed') return false;
      if (filter.status == 'completed' && t['status'] != 'completed') return false;
      return true;
    }).toList();

    // Grouping
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (var t in filtered) {
      String key;
      if (filter.groupBy == 'category') {
        key = t['cat'] as String;
      } else if (filter.groupBy == 'priority') {
        key = _formatGroupLabel(t['priority'] as String, 'priority');
      } else if (filter.groupBy == 'status') {
        key = _formatStatusLabel(t['status'] as String);
      } else {
        key = t['dept'] as String;
      }
      groups.putIfAbsent(key, () => []).add(t);
    }

    final barChartData = <BarChartItem>[];
    final tableData = <ReportTableRowData>[];
    int totalAll = 0;
    int completedAll = 0;
    double totalEstH = 0;
    double totalActH = 0;

    groups.forEach((label, list) {
      final total = list.length;
      final completed = list.where((x) => x['status'] == 'completed').length;
      final inProg = list.where((x) => x['status'] == 'in_progress' || x['status'] == 'review').length;
      final estH = list.fold<double>(0.0, (sum, x) => sum + (x['est'] as double));
      final actH = list.fold<double>(0.0, (sum, x) => sum + (x['act'] as double));
      final rate = total > 0 ? (completed / total) * 100.0 : 0.0;

      totalAll += total;
      completedAll += completed;
      totalEstH += estH;
      totalActH += actH;

      barChartData.add(BarChartItem(
        label: label,
        primaryValue: total.toDouble(),
        secondaryValue: completed.toDouble(),
      ));

      tableData.add(ReportTableRowData(
        groupName: label,
        totalTasks: total,
        completedTasks: completed,
        inProgressTasks: inProg,
        totalEstimatedHours: estH,
        totalActualHours: actH,
        completionRate: rate,
      ));
    });

    // Line Chart: Trend Kehadiran Harian
    final lineChartData = [
      const LineChartPoint(xLabel: '01 Sep', value: 4.0, secondaryValue: 7.5, tooltip: 'Hadir: 4, Jam Kerja: 7.5j'),
      const LineChartPoint(xLabel: '02 Sep', value: 4.0, secondaryValue: 8.0, tooltip: 'Hadir: 4, Jam Kerja: 8.0j'),
      const LineChartPoint(xLabel: '03 Sep', value: 5.0, secondaryValue: 8.2, tooltip: 'Hadir: 5, Jam Kerja: 8.2j'),
      const LineChartPoint(xLabel: '04 Sep', value: 5.0, secondaryValue: 8.0, tooltip: 'Hadir: 5, Jam Kerja: 8.0j'),
      const LineChartPoint(xLabel: '05 Sep', value: 6.0, secondaryValue: 8.5, tooltip: 'Hadir: 6, Jam Kerja: 8.5j'),
      const LineChartPoint(xLabel: '06 Sep', value: 5.0, secondaryValue: 7.8, tooltip: 'Hadir: 5, Jam Kerja: 7.8j'),
      const LineChartPoint(xLabel: '07 Sep', value: 6.0, secondaryValue: 8.0, tooltip: 'Hadir: 6, Jam Kerja: 8.0j'),
    ];

    // Pie Chart: Status Breakdown
    final statusMap = <String, int>{};
    for (var t in filtered) {
      final s = t['status'] as String;
      statusMap[s] = (statusMap[s] ?? 0) + 1;
    }

    final pieChartData = statusMap.entries.map((e) {
      return PieChartSlice(
        label: _formatStatusLabel(e.key),
        value: e.value.toDouble(),
        color: _getStatusColor(e.key),
      );
    }).toList();

    final overallRate = totalAll > 0 ? (completedAll / totalAll) * 100.0 : 0.0;

    return DashboardReportData(
      activeFilter: filter,
      barChartData: barChartData,
      lineChartData: lineChartData,
      pieChartData: pieChartData,
      tableData: tableData,
      summaryKPIs: {
        'total_tasks': totalAll,
        'completed_tasks': completedAll,
        'completion_rate': overallRate,
        'total_estimated_hours': totalEstH,
        'total_actual_hours': totalActH,
        'efficiency_ratio': totalEstH > 0 ? (totalActH / totalEstH) * 100.0 : 100.0,
      },
    );
  }
}

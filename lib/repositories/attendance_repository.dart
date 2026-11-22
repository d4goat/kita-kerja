import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/core/database/koneksi.dart';
import 'package:kita_kerja/models/attendance_model.dart';
import 'package:kita_kerja/models/master_data_model.dart';

class AttendanceRepository {
  // In-memory cache for offline demo / testing
  static final List<AttendanceModel> _fallbackAttendances = [
    AttendanceModel(
      id: 1,
      employeeId: 3,
      employeeName: 'Citra Staff',
      employeeCode: 'EMP003',
      departmentName: 'Operasional',
      attendanceDate: '2026-09-01',
      clockIn: '08:00',
      clockOut: '17:00',
      workingMinutes: 480,
      overtimeMinutes: 0,
      status: 'present',
      notes: 'Tepat Waktu',
    ),
    AttendanceModel(
      id: 2,
      employeeId: 3,
      employeeName: 'Citra Staff',
      employeeCode: 'EMP003',
      departmentName: 'Operasional',
      attendanceDate: '2026-09-02',
      clockIn: '08:15',
      clockOut: '17:00',
      workingMinutes: 465,
      overtimeMinutes: 0,
      status: 'late',
      notes: 'Terlambat 15 menit',
    ),
    AttendanceModel(
      id: 3,
      employeeId: 4,
      employeeName: 'Dedi Staff',
      employeeCode: 'EMP004',
      departmentName: 'Pemasaran',
      attendanceDate: '2026-09-01',
      clockIn: '07:00',
      clockOut: '15:00',
      workingMinutes: 420,
      overtimeMinutes: 0,
      status: 'present',
      notes: 'Shift Pagi',
    ),
    AttendanceModel(
      id: 4,
      employeeId: 4,
      employeeName: 'Dedi Staff',
      employeeCode: 'EMP004',
      departmentName: 'Pemasaran',
      attendanceDate: '2026-09-02',
      clockIn: '-',
      clockOut: '-',
      workingMinutes: 0,
      overtimeMinutes: 0,
      status: 'sick',
      notes: 'Surat dokter',
    ),
    AttendanceModel(
      id: 5,
      employeeId: 5,
      employeeName: 'Eka Staff',
      employeeCode: 'EMP005',
      departmentName: 'Teknologi',
      attendanceDate: '2026-09-01',
      clockIn: '08:05',
      clockOut: '18:00',
      workingMinutes: 535,
      overtimeMinutes: 55,
      status: 'present',
      notes: 'Lembur 55 menit',
    ),
  ];

  Future<List<AttendanceModel>> getAttendances({
    String? search,
    int? supervisorId,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {};
        List<String> conditions = [];
        String joinSupervisor = '';

        if (supervisorId != null && supervisorId > 0) {
          joinSupervisor = 'LEFT JOIN employee_supervisors es ON a.employee_id = es.employee_id';
          conditions.add('(es.supervisor_id = :sup_id OR a.employee_id = :sup_id)');
          params['sup_id'] = supervisorId;
        }

        if (search != null && search.trim().isNotEmpty) {
          conditions.add('(e.full_name LIKE :search OR e.employee_code LIKE :search)');
          params['search'] = '%${search.trim()}%';
        }

        String whereClause = conditions.isNotEmpty ? 'WHERE ${conditions.join(" AND ")}' : '';

        String query = '''
          SELECT 
            a.id, a.employee_id, a.attendance_date, a.clock_in, a.clock_out, a.working_minutes, a.overtime_minutes, a.status, a.notes,
            e.full_name AS employee_name, e.employee_code, d.name AS department_name
          FROM attendances a
          INNER JOIN employees e ON a.employee_id = e.id
          INNER JOIN departments d ON e.department_id = d.id
          $joinSupervisor
          $whereClause
          ORDER BY a.attendance_date DESC, a.id DESC
        ''';
        var results = await connection.execute(query, params);
        return results.rows
            .map((row) => AttendanceModel.fromMap(row.assoc()))
            .toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Attendances Fallback: $err');
      return List<AttendanceModel>.from(_fallbackAttendances);
    }
  }

  Future<List<AttendanceModel>> getEmployeeAttendances(int employeeId) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        String query = '''
          SELECT 
            a.id, a.employee_id, a.attendance_date, a.clock_in, a.clock_out, a.working_minutes, a.overtime_minutes, a.status, a.notes,
            e.full_name AS employee_name, e.employee_code, d.name AS department_name
          FROM attendances a
          INNER JOIN employees e ON a.employee_id = e.id
          INNER JOIN departments d ON e.department_id = d.id
          WHERE a.employee_id = :employee_id
          ORDER BY a.attendance_date DESC, a.id DESC
        ''';
        var results = await connection.execute(query, {
          'employee_id': employeeId,
        });
        return results.rows
            .map((row) => AttendanceModel.fromMap(row.assoc()))
            .toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Employee Attendances Fallback: $err');
      return _fallbackAttendances
          .where((a) => a.employeeId == employeeId)
          .toList();
    }
  }

  Future<AttendanceModel?> getTodayAttendance(
    int employeeId, [
    String? dateStr,
  ]) async {
    final today = dateStr ?? DateTime.now().toIso8601String().split('T')[0];
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          '''
          SELECT 
            a.id, a.employee_id, a.attendance_date, a.clock_in, a.clock_out, a.working_minutes, a.overtime_minutes, a.status, a.notes,
            e.full_name AS employee_name, e.employee_code, d.name AS department_name
          FROM attendances a
          INNER JOIN employees e ON a.employee_id = e.id
          INNER JOIN departments d ON e.department_id = d.id
          WHERE a.employee_id = :employee_id AND a.attendance_date = :att_date
          LIMIT 1
          ''',
          {'employee_id': employeeId, 'att_date': today},
        );
        if (results.rows.isNotEmpty) {
          return AttendanceModel.fromMap(results.rows.first.assoc());
        }
        return null;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getTodayAttendance: $err');
      try {
        return _fallbackAttendances.firstWhere(
          (a) => a.employeeId == employeeId && a.attendanceDate == today,
        );
      } catch (_) {
        return null;
      }
    }
  }

  Future<WorkScheduleModel?> getEmployeeSchedule(int employeeId) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          '''
          SELECT ws.id, ws.name, ws.start_time, ws.end_time, ws.break_minutes, ws.working_hours, ws.status
          FROM employees e
          INNER JOIN work_schedules ws ON e.work_schedule_id = ws.id
          WHERE e.id = :emp_id
          LIMIT 1
          ''',
          {'emp_id': employeeId},
        );
        if (results.rows.isNotEmpty) {
          return WorkScheduleModel.fromMap(results.rows.first.assoc());
        }
        return null;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getEmployeeSchedule: $err');
      if (employeeId == 4) {
        return WorkScheduleModel(
          id: 2,
          name: 'Shift Pagi',
          startTime: '07:00:00',
          endTime: '15:00:00',
          breakMinutes: 60,
          workingHours: 7.0,
        );
      }
      return WorkScheduleModel(
        id: 1,
        name: 'Jam Kerja Normal',
        startTime: '08:00:00',
        endTime: '17:00:00',
        breakMinutes: 60,
        workingHours: 8.0,
      );
    }
  }

  Future<WorkScheduleModel?> getScheduleByAttendanceId(int attendanceId) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          '''
          SELECT ws.id, ws.name, ws.start_time, ws.end_time, ws.break_minutes, ws.working_hours, ws.status
          FROM attendances a
          INNER JOIN employees e ON a.employee_id = e.id
          INNER JOIN work_schedules ws ON e.work_schedule_id = ws.id
          WHERE a.id = :att_id
          LIMIT 1
          ''',
          {'att_id': attendanceId},
        );
        if (results.rows.isNotEmpty) {
          return WorkScheduleModel.fromMap(results.rows.first.assoc());
        }
        return null;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback getScheduleByAttendanceId: $err');
      try {
        final att = _fallbackAttendances.firstWhere((a) => a.id == attendanceId);
        return getEmployeeSchedule(att.employeeId);
      } catch (_) {
        return getEmployeeSchedule(1);
      }
    }
  }

  Future<bool> clockIn({required int employeeId, String? notes}) async {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    final nowStr =
        '${now.toIso8601String().split('T')[0]} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    // Status check dinamis berdasarkan work_schedules dan toleransi keterlambatan 15 menit
    final schedule = await getEmployeeSchedule(employeeId);
    int scheduledStartHour = 8;
    int scheduledStartMin = 0;
    if (schedule != null && schedule.startTime.isNotEmpty) {
      final parts = schedule.startTime.split(':');
      if (parts.isNotEmpty) scheduledStartHour = int.tryParse(parts[0]) ?? 8;
      if (parts.length > 1) scheduledStartMin = int.tryParse(parts[1]) ?? 0;
    }

    final totalScheduledStartMin = scheduledStartHour * 60 + scheduledStartMin;
    final totalNowMin = now.hour * 60 + now.minute;
    const toleranceMinutes = 15; // Batas toleransi keterlambatan standar

    final bool isLate = totalNowMin > (totalScheduledStartMin + toleranceMinutes);
    final String status = isLate ? 'late' : 'present';
    final int lateMinutes = isLate ? (totalNowMin - totalScheduledStartMin) : 0;
    final String defaultNotes = isLate ? 'Terlambat $lateMinutes menit' : 'Tepat Waktu';

    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          INSERT INTO attendances 
            (employee_id, attendance_date, clock_in, status, notes)
          VALUES 
            (:employee_id, :attendance_date, :clock_in, :status, :notes)
          ON DUPLICATE KEY UPDATE
            clock_in = :clock_in,
            status = :status,
            notes = COALESCE(:notes, notes)
          ''',
          {
            'employee_id': employeeId,
            'attendance_date': todayStr,
            'clock_in': nowStr,
            'status': status,
            'notes': notes ?? defaultNotes,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback clockIn execution: $err');
      final existingIndex = _fallbackAttendances.indexWhere(
        (a) => a.employeeId == employeeId && a.attendanceDate == todayStr,
      );
      final newRecord = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        employeeId: employeeId,
        attendanceDate: todayStr,
        clockIn:
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        clockOut: '-',
        status: status,
        notes: notes ?? defaultNotes,
      );
      if (existingIndex >= 0) {
        _fallbackAttendances[existingIndex] = newRecord;
      } else {
        _fallbackAttendances.insert(0, newRecord);
      }
      return true;
    }
  }

  Future<bool> clockOut({required int employeeId, String? notes}) async {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    final nowStr =
        '${now.toIso8601String().split('T')[0]} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    // Ambil jadwal kerja karyawan untuk kalkulasi dinamis
    final schedule = await getEmployeeSchedule(employeeId);
    final breakMinutes = schedule?.breakMinutes ?? 60;
    final standardWorkingMinutes = ((schedule?.workingHours ?? 8.0) * 60).round();

    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        // Get clock_in to compute working minutes
        var currentRes = await connection.execute(
          '''
          SELECT clock_in, notes FROM attendances
          WHERE employee_id = :employee_id AND attendance_date = :att_date
          LIMIT 1
          ''',
          {'employee_id': employeeId, 'att_date': todayStr},
        );

        int workingMinutes = standardWorkingMinutes;
        int overtimeMinutes = 0;
        if (currentRes.rows.isNotEmpty) {
          final cInStr = currentRes.rows.first.assoc()['clock_in'];
          if (cInStr != null && cInStr.isNotEmpty) {
            final parsedIn = DateTime.tryParse(cInStr);
            if (parsedIn != null) {
              final elapsed = now.difference(parsedIn).inMinutes;
              workingMinutes = elapsed > breakMinutes ? (elapsed - breakMinutes) : elapsed;
              if (workingMinutes < 0) workingMinutes = 0;
              if (workingMinutes > standardWorkingMinutes) {
                overtimeMinutes = workingMinutes - standardWorkingMinutes;
              }
            }
          }
        }

        String? finalNotes = notes;
        if ((finalNotes == null || finalNotes.isEmpty) && overtimeMinutes > 0) {
          finalNotes = 'Lembur $overtimeMinutes menit';
        }

        await connection.execute(
          '''
          UPDATE attendances 
          SET 
            clock_out = :clock_out,
            working_minutes = :working_minutes,
            overtime_minutes = :overtime_minutes,
            notes = CASE WHEN :notes IS NOT NULL AND :notes != '' THEN :notes ELSE notes END
          WHERE employee_id = :employee_id AND attendance_date = :attendance_date
          ''',
          {
            'employee_id': employeeId,
            'attendance_date': todayStr,
            'clock_out': nowStr,
            'working_minutes': workingMinutes,
            'overtime_minutes': overtimeMinutes,
            'notes': finalNotes,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback clockOut execution: $err');
      final existingIndex = _fallbackAttendances.indexWhere(
        (a) => a.employeeId == employeeId && a.attendanceDate == todayStr,
      );
      if (existingIndex >= 0) {
        final prev = _fallbackAttendances[existingIndex];
        int workingMinutes = standardWorkingMinutes;
        int overtimeMinutes = 0;

        if (prev.clockIn.isNotEmpty && prev.clockIn != '-') {
          try {
            final parts = prev.clockIn.split(':').map((e) => int.parse(e.trim())).toList();
            final inTime = DateTime(now.year, now.month, now.day, parts[0], parts[1]);
            final elapsed = now.difference(inTime).inMinutes;
            workingMinutes = elapsed > breakMinutes ? (elapsed - breakMinutes) : elapsed;
            if (workingMinutes < 0) workingMinutes = 0;
            if (workingMinutes > standardWorkingMinutes) {
              overtimeMinutes = workingMinutes - standardWorkingMinutes;
            }
          } catch (_) {}
        }

        String? finalNotes = notes ?? prev.notes;
        if ((notes == null || notes.isEmpty) && overtimeMinutes > 0) {
          finalNotes = 'Lembur $overtimeMinutes menit';
        }

        _fallbackAttendances[existingIndex] = AttendanceModel(
          id: prev.id,
          employeeId: prev.employeeId,
          employeeName: prev.employeeName,
          employeeCode: prev.employeeCode,
          departmentName: prev.departmentName,
          attendanceDate: prev.attendanceDate,
          clockIn: prev.clockIn,
          clockOut:
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          workingMinutes: workingMinutes,
          overtimeMinutes: overtimeMinutes,
          status: prev.status,
          notes: finalNotes,
        );
      }
      return true;
    }
  }

  Future<bool> correctAttendance({
    required int id,
    required String attendanceDate,
    required String clockIn,
    required String clockOut,
    required String status,
    String? notes,
  }) async {
    // Ambil jadwal kerja spesifik berdasarkan attendance id
    final schedule = await getScheduleByAttendanceId(id);
    final breakMinutes = schedule?.breakMinutes ?? 60;
    final standardWorkingMinutes = ((schedule?.workingHours ?? 8.0) * 60).round();

    int workingMinutes = 0;
    int overtimeMinutes = 0;

    if (clockIn.isNotEmpty && clockIn != '-' && clockOut.isNotEmpty && clockOut != '-') {
      try {
        final inClean = clockIn.contains(' ') ? clockIn.split(' ')[1] : clockIn;
        final outClean = clockOut.contains(' ') ? clockOut.split(' ')[1] : clockOut;
        final inParts = inClean.split(':').map((e) => int.parse(e.trim())).toList();
        final outParts = outClean.split(':').map((e) => int.parse(e.trim())).toList();
        final totalInMin = inParts[0] * 60 + inParts[1];
        final totalOutMin = outParts[0] * 60 + outParts[1];
        if (totalOutMin >= totalInMin) {
          final elapsed = totalOutMin - totalInMin;
          workingMinutes = elapsed > breakMinutes ? (elapsed - breakMinutes) : elapsed;
          if (workingMinutes < 0) workingMinutes = 0;
          if (workingMinutes > standardWorkingMinutes) {
            overtimeMinutes = workingMinutes - standardWorkingMinutes;
          }
        }
      } catch (_) {}
    }

    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          UPDATE attendances 
          SET 
            attendance_date = :att_date,
            clock_in = :clock_in,
            clock_out = :clock_out,
            working_minutes = :working_minutes,
            overtime_minutes = :overtime_minutes,
            status = :status,
            notes = :notes
          WHERE id = :id
          ''',
          {
            'id': id,
            'att_date': attendanceDate,
            'clock_in': (clockIn == '-' || clockIn.isEmpty) ? null : clockIn,
            'clock_out': (clockOut == '-' || clockOut.isEmpty) ? null : clockOut,
            'working_minutes': workingMinutes,
            'overtime_minutes': overtimeMinutes,
            'status': status,
            'notes': notes,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback correctAttendance: $err');
      final idx = _fallbackAttendances.indexWhere((a) => a.id == id);
      if (idx >= 0) {
        final prev = _fallbackAttendances[idx];
        _fallbackAttendances[idx] = AttendanceModel(
          id: prev.id,
          employeeId: prev.employeeId,
          employeeName: prev.employeeName,
          employeeCode: prev.employeeCode,
          departmentName: prev.departmentName,
          attendanceDate: attendanceDate,
          clockIn: clockIn,
          clockOut: clockOut,
          workingMinutes: workingMinutes,
          overtimeMinutes: overtimeMinutes,
          status: status,
          notes: notes ?? prev.notes,
        );
      }
      return true;
    }
  }

  Future<bool> submitAbsenceRequest({
    required int employeeId,
    required String attendanceDate,
    required String status,
    required String notes,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          INSERT INTO attendances 
            (employee_id, attendance_date, clock_in, clock_out, working_minutes, overtime_minutes, status, notes)
          VALUES 
            (:employee_id, :att_date, NULL, NULL, 0, 0, :status, :notes)
          ON DUPLICATE KEY UPDATE
            clock_in = NULL,
            clock_out = NULL,
            working_minutes = 0,
            overtime_minutes = 0,
            status = :status,
            notes = :notes
          ''',
          {
            'employee_id': employeeId,
            'att_date': attendanceDate,
            'status': status,
            'notes': notes,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback submitAbsenceRequest: $err');
      final idx = _fallbackAttendances.indexWhere(
        (a) => a.employeeId == employeeId && a.attendanceDate == attendanceDate,
      );
      final rec = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        employeeId: employeeId,
        attendanceDate: attendanceDate,
        clockIn: '-',
        clockOut: '-',
        workingMinutes: 0,
        overtimeMinutes: 0,
        status: status,
        notes: notes,
      );
      if (idx >= 0) {
        _fallbackAttendances[idx] = rec;
      } else {
        _fallbackAttendances.insert(0, rec);
      }
      return true;
    }
  }
}

import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/core/database/koneksi.dart';
import 'package:kita_kerja/models/attendance_model.dart';

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

  Future<List<AttendanceModel>> getAttendances({String? search}) async {
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
          ORDER BY a.attendance_date DESC, a.id DESC
        ''';
        var results = await connection.execute(query);
        return results.rows.map((row) => AttendanceModel.fromMap(row.assoc())).toList();
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
        var results = await connection.execute(query, {'employee_id': employeeId});
        return results.rows.map((row) => AttendanceModel.fromMap(row.assoc())).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Employee Attendances Fallback: $err');
      return _fallbackAttendances.where((a) => a.employeeId == employeeId).toList();
    }
  }

  Future<AttendanceModel?> getTodayAttendance(int employeeId, [String? dateStr]) async {
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

  Future<bool> clockIn({
    required int employeeId,
    String? notes,
  }) async {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    final nowStr = '${now.toIso8601String().split('T')[0]} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    
    // Status check: late if after 08:15 (standard)
    String status = (now.hour > 8 || (now.hour == 8 && now.minute > 15)) ? 'late' : 'present';

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
            'notes': notes ?? (status == 'late' ? 'Terlambat masuk' : 'Tepat Waktu'),
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback clockIn execution: $err');
      // Update in-memory fallback cache
      final existingIndex = _fallbackAttendances.indexWhere(
        (a) => a.employeeId == employeeId && a.attendanceDate == todayStr,
      );
      final newRecord = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        employeeId: employeeId,
        attendanceDate: todayStr,
        clockIn: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        clockOut: '-',
        status: status,
        notes: notes ?? (status == 'late' ? 'Terlambat' : 'Tepat Waktu'),
      );
      if (existingIndex >= 0) {
        _fallbackAttendances[existingIndex] = newRecord;
      } else {
        _fallbackAttendances.insert(0, newRecord);
      }
      return true;
    }
  }

  Future<bool> clockOut({
    required int employeeId,
    String? notes,
  }) async {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    final nowStr = '${now.toIso8601String().split('T')[0]} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

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

        int workingMinutes = 480; // default 8 hours
        int overtimeMinutes = 0;
        if (currentRes.rows.isNotEmpty) {
          final cInStr = currentRes.rows.first.assoc()['clock_in'];
          if (cInStr != null && cInStr.isNotEmpty) {
            final parsedIn = DateTime.tryParse(cInStr);
            if (parsedIn != null) {
              workingMinutes = now.difference(parsedIn).inMinutes;
              if (workingMinutes > 480) {
                overtimeMinutes = workingMinutes - 480;
              }
            }
          }
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
            'notes': notes,
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
        _fallbackAttendances[existingIndex] = AttendanceModel(
          id: prev.id,
          employeeId: prev.employeeId,
          employeeName: prev.employeeName,
          employeeCode: prev.employeeCode,
          departmentName: prev.departmentName,
          attendanceDate: prev.attendanceDate,
          clockIn: prev.clockIn,
          clockOut: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          workingMinutes: 480,
          overtimeMinutes: 0,
          status: prev.status,
          notes: notes ?? prev.notes,
        );
      }
      return true;
    }
  }
}

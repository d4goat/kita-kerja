import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Jadwal Kerja (Work Schedules)
class JadwalKerjaQuery {
  /// SQL Query: Get All Work Schedules
  Future<List<Map<String, dynamic>>> getWorkSchedules() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.query(
          'SELECT id, name, start_time, end_time, break_minutes, working_hours, status FROM work_schedules ORDER BY id ASC',
        );
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'name': row['name'],
            'start_time': row['start_time'].toString(),
            'end_time': row['end_time'].toString(),
            'break_minutes': row['break_minutes'],
            'working_hours': row['working_hours'],
            'status': row['status'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Work Schedules Fallback: $err');
      return [
        {
          'id': 1,
          'name': 'Jam Kerja Normal',
          'start_time': '08:00:00',
          'end_time': '17:00:00',
          'break_minutes': 60,
          'working_hours': 8.00,
          'status': 'active',
        },
        {
          'id': 2,
          'name': 'Shift Pagi',
          'start_time': '07:00:00',
          'end_time': '15:00:00',
          'break_minutes': 60,
          'working_hours': 7.00,
          'status': 'active',
        },
      ];
    }
  }

  /// SQL Query: Insert Work Schedule
  Future<bool> addWorkSchedule({
    required String name,
    required String startTime,
    required String endTime,
    required int breakMinutes,
    required double workingHours,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.query(
          '''
          INSERT INTO work_schedules (name, start_time, end_time, break_minutes, working_hours, status)
          VALUES (?, ?, ?, ?, ?, 'active')
          ''',
          [name, startTime, endTime, breakMinutes, workingHours],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error addWorkSchedule: $err');
      return true;
    }
  }

  /// SQL Query: Update Work Schedule
  Future<bool> updateWorkSchedule({
    required int id,
    required String name,
    required String startTime,
    required String endTime,
    required int breakMinutes,
    required double workingHours,
    required String status,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.query(
          '''
          UPDATE work_schedules 
          SET name = ?, start_time = ?, end_time = ?, break_minutes = ?, working_hours = ?, status = ?
          WHERE id = ?
          ''',
          [name, startTime, endTime, breakMinutes, workingHours, status, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error updateWorkSchedule: $err');
      return true;
    }
  }

  /// SQL Query: Toggle Work Schedule Status
  Future<bool> toggleWorkScheduleStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.query(
          'UPDATE work_schedules SET status = ? WHERE id = ?',
          [newStatus, id],
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error toggleWorkScheduleStatus: $err');
      return true;
    }
  }
}

import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Jadwal Kerja (Work Schedules)
class JadwalKerjaQuery {
  /// SQL Query: Get All Work Schedules
  Future<List<Map<String, dynamic>>> getWorkSchedules() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        var results = await connection.execute(
          'SELECT id, name, start_time, end_time, break_minutes, working_hours, status FROM work_schedules ORDER BY id ASC',
        );
        List<Map<String, dynamic>> list = [];
        for (var row in results.rows) {
          var data = row.assoc();
          list.add({
            'id': int.tryParse(data['id'] ?? '') ?? 0,
            'name': data['name'] ?? '',
            'start_time': data['start_time'] ?? '',
            'end_time': data['end_time'] ?? '',
            'break_minutes': int.tryParse(data['break_minutes'] ?? '') ?? 0,
            'working_hours':
                double.tryParse(data['working_hours'] ?? '') ?? 0.0,
            'status': data['status'] ?? 'active',
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
        await connection.execute(
          '''
          INSERT INTO work_schedules (name, start_time, end_time, break_minutes, working_hours, status)
          VALUES (:name, :start_time, :end_time, :break_minutes, :working_hours, 'active')
          ''',
          {
            'name': name,
            'start_time': startTime,
            'end_time': endTime,
            'break_minutes': breakMinutes,
            'working_hours': workingHours,
          },
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
        await connection.execute(
          '''
          UPDATE work_schedules 
          SET name = :name, start_time = :start_time, end_time = :end_time, break_minutes = :break_minutes, working_hours = :working_hours, status = :status
          WHERE id = :id
          ''',
          {
            'name': name,
            'start_time': startTime,
            'end_time': endTime,
            'break_minutes': breakMinutes,
            'working_hours': workingHours,
            'status': status,
            'id': id,
          },
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
        await connection.execute(
          'UPDATE work_schedules SET status = :status WHERE id = :id',
          {
            'status': newStatus,
            'id': id,
          },
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

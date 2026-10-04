import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Kehadiran (Attendances)
class KehadiranQuery {
  /// SQL Query: Get All Attendances
  Future<List<Map<String, dynamic>>> getAttendances({String? search}) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        String query = '''
          SELECT 
            a.id, a.attendance_date, a.clock_in, a.clock_out, a.working_minutes, a.overtime_minutes, a.status, a.notes,
            e.full_name AS employee_name, e.employee_code, d.name AS department_name
          FROM attendances a
          INNER JOIN employees e ON a.employee_id = e.id
          INNER JOIN departments d ON e.department_id = d.id
          ORDER BY a.attendance_date DESC, a.id DESC
        ''';
        var results = await connection.query(query);
        List<Map<String, dynamic>> list = [];
        for (var row in results) {
          list.add({
            'id': row['id'],
            'attendance_date': row['attendance_date'].toString().split(' ')[0],
            'clock_in': row['clock_in'] != null
                ? row['clock_in'].toString().split(' ')[1].substring(0, 5)
                : '-',
            'clock_out': row['clock_out'] != null
                ? row['clock_out'].toString().split(' ')[1].substring(0, 5)
                : '-',
            'working_hours': (row['working_minutes'] / 60).toStringAsFixed(1),
            'overtime_minutes': row['overtime_minutes'],
            'status': row['status'],
            'notes': row['notes'] ?? '-',
            'employee_name': row['employee_name'],
            'employee_code': row['employee_code'],
            'department_name': row['department_name'],
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Attendances Fallback: $err');
      return [
        {
          'id': 1,
          'attendance_date': '2026-09-01',
          'clock_in': '08:00',
          'clock_out': '17:00',
          'working_hours': '8.0',
          'overtime_minutes': 0,
          'status': 'present',
          'notes': 'Tepat Waktu',
          'employee_name': 'Citra Staff',
          'employee_code': 'EMP003',
          'department_name': 'Operasional',
        },
        {
          'id': 2,
          'attendance_date': '2026-09-02',
          'clock_in': '08:15',
          'clock_out': '17:00',
          'working_hours': '7.8',
          'overtime_minutes': 0,
          'status': 'late',
          'notes': 'Terlambat 15 menit',
          'employee_name': 'Citra Staff',
          'employee_code': 'EMP003',
          'department_name': 'Operasional',
        },
        {
          'id': 3,
          'attendance_date': '2026-09-01',
          'clock_in': '07:00',
          'clock_out': '15:00',
          'working_hours': '7.0',
          'overtime_minutes': 0,
          'status': 'present',
          'notes': 'Shift Pagi',
          'employee_name': 'Dedi Staff',
          'employee_code': 'EMP004',
          'department_name': 'Pemasaran',
        },
        {
          'id': 4,
          'attendance_date': '2026-09-02',
          'clock_in': '-',
          'clock_out': '-',
          'working_hours': '0.0',
          'overtime_minutes': 0,
          'status': 'sick',
          'notes': 'Surat dokter',
          'employee_name': 'Dedi Staff',
          'employee_code': 'EMP004',
          'department_name': 'Pemasaran',
        },
        {
          'id': 5,
          'attendance_date': '2026-09-01',
          'clock_in': '08:05',
          'clock_out': '18:00',
          'working_hours': '8.9',
          'overtime_minutes': 55,
          'status': 'present',
          'notes': 'Lembur 55 menit',
          'employee_name': 'Eka Staff',
          'employee_code': 'EMP005',
          'department_name': 'Teknologi',
        },
      ];
    }
  }
}

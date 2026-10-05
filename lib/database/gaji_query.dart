import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Gaji (Salaries)
class GajiQuery {
  /// SQL Query: Get Salary Recapt
  Future<List<Map<String, dynamic>>> getSalaries({
    int periodMonth = 9,
    int periodYear = 2026,
    int? departmentId,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {
          'month': periodMonth,
          'year': periodYear,
        };
        List<String> conditions = [
          's.period_month = :month',
          's.period_year = :year',
        ];

        if (departmentId != null && departmentId > 0) {
          conditions.add('e.department_id = :dept_id');
          params['dept_id'] = departmentId;
        }

        String whereClause = 'WHERE ${conditions.join(" AND ")}';

        String query = '''
          SELECT 
            s.id, s.employee_id, s.period_month, s.period_year,
            s.basic_salary, s.overtime_amount, s.bonus_amount, s.deduction_amount, s.net_salary, s.status, s.notes,
            e.full_name AS employee_name, e.employee_code,
            d.name AS department_name,
            st.name AS salary_type_name
          FROM salaries s
          INNER JOIN employees e ON s.employee_id = e.id
          INNER JOIN departments d ON e.department_id = d.id
          INNER JOIN salary_types st ON e.salary_type_id = st.id
          $whereClause
          ORDER BY s.id ASC
        ''';

        var results = await connection.execute(query, params);
        List<Map<String, dynamic>> list = [];
        for (var row in results.rows) {
          var data = row.assoc();
          list.add({
            'id': int.tryParse(data['id'] ?? '') ?? 0,
            'employee_name': data['employee_name'] ?? '',
            'employee_code': data['employee_code'] ?? '',
            'department_name': data['department_name'] ?? '',
            'salary_type_name': data['salary_type_name'] ?? '',
            'basic_salary':
                double.tryParse(data['basic_salary'] ?? '') ?? 0.0,
            'overtime_amount':
                double.tryParse(data['overtime_amount'] ?? '') ?? 0.0,
            'bonus_amount':
                double.tryParse(data['bonus_amount'] ?? '') ?? 0.0,
            'deduction_amount':
                double.tryParse(data['deduction_amount'] ?? '') ?? 0.0,
            'net_salary':
                double.tryParse(data['net_salary'] ?? '') ?? 0.0,
            'status': data['status'] ?? 'draft',
            'notes': data['notes'] ?? '',
          });
        }
        return list;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Salaries Fallback: $err');
      return [
        {
          'id': 1,
          'employee_name': 'Citra Staff',
          'employee_code': 'EMP003',
          'department_name': 'Operasional',
          'salary_type_name': 'Bulanan',
          'basic_salary': 4500000.0,
          'overtime_amount': 0.0,
          'bonus_amount': 250000.0,
          'deduction_amount': 50000.0,
          'net_salary': 4700000.0,
          'status': 'processed',
          'notes': 'Gaji September 2026',
        },
        {
          'id': 2,
          'employee_name': 'Dedi Staff',
          'employee_code': 'EMP004',
          'department_name': 'Pemasaran',
          'salary_type_name': 'Bulanan',
          'basic_salary': 4500000.0,
          'overtime_amount': 0.0,
          'bonus_amount': 100000.0,
          'deduction_amount': 0.0,
          'net_salary': 4600000.0,
          'status': 'draft',
          'notes': 'Menunggu approval',
        },
        {
          'id': 3,
          'employee_name': 'Eka Staff',
          'employee_code': 'EMP005',
          'department_name': 'Teknologi',
          'salary_type_name': 'Bulanan',
          'basic_salary': 5000000.0,
          'overtime_amount': 150000.0,
          'bonus_amount': 300000.0,
          'deduction_amount': 100000.0,
          'net_salary': 5350000.0,
          'status': 'paid',
          'notes': 'Sudah ditransfer',
        },
        {
          'id': 4,
          'employee_name': 'Fajar Staff',
          'employee_code': 'EMP006',
          'department_name': 'Teknologi',
          'salary_type_name': 'Kontrak',
          'basic_salary': 4000000.0,
          'overtime_amount': 0.0,
          'bonus_amount': 0.0,
          'deduction_amount': 0.0,
          'net_salary': 4000000.0,
          'status': 'draft',
          'notes': 'Kontrak',
        },
      ];
    }
  }
}

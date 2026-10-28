import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/models/salary_model.dart';

class SalaryRepository {
  static final List<SalaryModel> _fallbackSalaries = [
    SalaryModel(
      id: 1,
      employeeId: 3,
      employeeName: 'Citra Staff',
      employeeCode: 'EMP003',
      departmentName: 'Operasional',
      salaryTypeName: 'Bulanan',
      periodMonth: 9,
      periodYear: 2026,
      basicSalary: 4500000.0,
      overtimeAmount: 0.0,
      bonusAmount: 250000.0,
      deductionAmount: 50000.0,
      netSalary: 4700000.0,
      status: 'processed',
      notes: 'Gaji September 2026',
    ),
    SalaryModel(
      id: 2,
      employeeId: 4,
      employeeName: 'Dedi Staff',
      employeeCode: 'EMP004',
      departmentName: 'Pemasaran',
      salaryTypeName: 'Bulanan',
      periodMonth: 9,
      periodYear: 2026,
      basicSalary: 4500000.0,
      overtimeAmount: 0.0,
      bonusAmount: 100000.0,
      deductionAmount: 0.0,
      netSalary: 4600000.0,
      status: 'draft',
      notes: 'Menunggu approval',
    ),
    SalaryModel(
      id: 3,
      employeeId: 5,
      employeeName: 'Eka Staff',
      employeeCode: 'EMP005',
      departmentName: 'Teknologi',
      salaryTypeName: 'Bulanan',
      periodMonth: 9,
      periodYear: 2026,
      basicSalary: 5000000.0,
      overtimeAmount: 150000.0,
      bonusAmount: 300000.0,
      deductionAmount: 100000.0,
      netSalary: 5350000.0,
      status: 'paid',
      notes: 'Sudah ditransfer',
    ),
    SalaryModel(
      id: 4,
      employeeId: 6,
      employeeName: 'Fajar Staff',
      employeeCode: 'EMP006',
      departmentName: 'Teknologi',
      salaryTypeName: 'Kontrak',
      periodMonth: 9,
      periodYear: 2026,
      basicSalary: 4000000.0,
      overtimeAmount: 0.0,
      bonusAmount: 0.0,
      deductionAmount: 0.0,
      netSalary: 4000000.0,
      status: 'draft',
      notes: 'Kontrak',
    ),
  ];

  Future<List<SalaryModel>> getSalaries({
    int periodMonth = 9,
    int periodYear = 2026,
    int? departmentId,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {'month': periodMonth, 'year': periodYear};
        List<String> conditions = ['s.period_month = :month', 's.period_year = :year'];

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
        return results.rows.map((row) => SalaryModel.fromMap(row.assoc())).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Salaries Fallback: $err');
      return _fallbackSalaries.where((s) {
        bool m = s.periodMonth == periodMonth && s.periodYear == periodYear;
        return m;
      }).toList();
    }
  }

  Future<List<SalaryModel>> getMySalaries({
    required int employeeId,
    int? periodYear,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {'employee_id': employeeId};
        List<String> conditions = ['s.employee_id = :employee_id'];

        if (periodYear != null) {
          conditions.add('s.period_year = :year');
          params['year'] = periodYear;
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
          ORDER BY s.period_year DESC, s.period_month DESC
        ''';

        var results = await connection.execute(query, params);
        return results.rows.map((row) => SalaryModel.fromMap(row.assoc())).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL MySalaries Fallback: $err');
      return _fallbackSalaries.where((s) => s.employeeId == employeeId).toList();
    }
  }

  Future<bool> updateSalaryStatus(int id, String status) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'UPDATE salaries SET status = :status WHERE id = :id',
          {'id': id, 'status': status},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updateSalaryStatus: $err');
      return true;
    }
  }
}

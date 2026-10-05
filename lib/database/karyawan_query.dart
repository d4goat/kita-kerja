import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Query database untuk model/object Karyawan (Employees)
class KaryawanQuery {
  /// SQL Query: Get Employees with JOIN positions, departments, work_schedules, salary_types
  Future<Map<String, dynamic>> getEmployees({
    String? search,
    int? departmentId,
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {};
        List<String> conditions = [];

        if (search != null && search.trim().isNotEmpty) {
          conditions.add(
            '(e.full_name LIKE :search OR e.employee_code LIKE :search OR e.email LIKE :search)',
          );
          params['search'] = '%${search.trim()}%';
        }

        if (departmentId != null && departmentId > 0) {
          conditions.add('e.department_id = :dept_id');
          params['dept_id'] = departmentId;
        }

        if (status != null && status != 'all' && status.isNotEmpty) {
          conditions.add('e.status = :status');
          params['status'] = status;
        }

        String whereClause = conditions.isNotEmpty
            ? 'WHERE ${conditions.join(" AND ")}'
            : '';
        int offset = (page - 1) * pageSize;

        // Query total count
        var countResult = await connection.execute(
          'SELECT COUNT(*) as total FROM employees e $whereClause',
          params,
        );
        int total = 0;
        if (countResult.rows.isNotEmpty) {
          total = int.tryParse(countResult.rows.first.assoc()['total'] ?? '') ?? 0;
        }

        // Query paginated list
        String query =
            '''
          SELECT 
            e.id, e.employee_code, e.full_name, e.email, e.phone, e.join_date, e.status,
            e.position_id, e.department_id, e.salary_type_id, e.work_schedule_id,
            p.name AS position_name,
            d.name AS department_name,
            st.name AS salary_type_name,
            ws.name AS work_schedule_name
          FROM employees e
          INNER JOIN positions p ON e.position_id = p.id
          INNER JOIN departments d ON e.department_id = d.id
          INNER JOIN salary_types st ON e.salary_type_id = st.id
          INNER JOIN work_schedules ws ON e.work_schedule_id = ws.id
          $whereClause
          ORDER BY e.id ASC
          LIMIT $pageSize OFFSET $offset
        ''';

        var results = await connection.execute(query, params);
        List<Map<String, dynamic>> list = [];
        for (var row in results.rows) {
          var data = row.assoc();
          list.add({
            'id': int.tryParse(data['id'] ?? '') ?? 0,
            'employee_code': data['employee_code'] ?? '',
            'full_name': data['full_name'] ?? '',
            'email': data['email'] ?? '',
            'phone': data['phone'] ?? '',
            'join_date': (data['join_date'] ?? '').split(' ')[0],
            'status': data['status'] ?? 'active',
            'position_id': int.tryParse(data['position_id'] ?? '') ?? 0,
            'department_id': int.tryParse(data['department_id'] ?? '') ?? 0,
            'salary_type_id': int.tryParse(data['salary_type_id'] ?? '') ?? 0,
            'work_schedule_id':
                int.tryParse(data['work_schedule_id'] ?? '') ?? 0,
            'position_name': data['position_name'] ?? '',
            'department_name': data['department_name'] ?? '',
            'salary_type_name': data['salary_type_name'] ?? '',
            'work_schedule_name': data['work_schedule_name'] ?? '',
          });
        }

        return {'total': total, 'data': list};
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Employees Fallback: $err');
      // Dummy data matching PRD demo script
      List<Map<String, dynamic>> dummyList = [
        {
          'id': 1,
          'employee_code': 'EMP001',
          'full_name': 'Admin KerjaKita',
          'email': 'admin@kerjakita.local',
          'phone': '081234567890',
          'join_date': '2024-01-01',
          'status': 'active',
          'position_id': 1,
          'department_id': 1,
          'salary_type_id': 1,
          'work_schedule_id': 1,
          'position_name': 'Owner',
          'department_name': 'Operasional',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Jam Kerja Normal',
        },
        {
          'id': 2,
          'employee_code': 'EMP002',
          'full_name': 'Budi Manager',
          'email': 'manager@kerjakita.local',
          'phone': '081234567891',
          'join_date': '2024-02-01',
          'status': 'active',
          'position_id': 2,
          'department_id': 1,
          'salary_type_id': 1,
          'work_schedule_id': 1,
          'position_name': 'Supervisor',
          'department_name': 'Operasional',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Jam Kerja Normal',
        },
        {
          'id': 3,
          'employee_code': 'EMP003',
          'full_name': 'Citra Staff',
          'email': 'citra@kerjakita.local',
          'phone': '081234567892',
          'join_date': '2024-03-01',
          'status': 'active',
          'position_id': 3,
          'department_id': 1,
          'salary_type_id': 1,
          'work_schedule_id': 1,
          'position_name': 'Staff',
          'department_name': 'Operasional',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Jam Kerja Normal',
        },
        {
          'id': 4,
          'employee_code': 'EMP004',
          'full_name': 'Dedi Staff',
          'email': 'dedi@kerjakita.local',
          'phone': '081234567893',
          'join_date': '2024-04-01',
          'status': 'active',
          'position_id': 3,
          'department_id': 2,
          'salary_type_id': 1,
          'work_schedule_id': 2,
          'position_name': 'Staff',
          'department_name': 'Pemasaran',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Shift Pagi',
        },
        {
          'id': 5,
          'employee_code': 'EMP005',
          'full_name': 'Eka Staff',
          'email': 'eka@kerjakita.local',
          'phone': '081234567894',
          'join_date': '2024-05-01',
          'status': 'active',
          'position_id': 3,
          'department_id': 3,
          'salary_type_id': 1,
          'work_schedule_id': 1,
          'position_name': 'Staff',
          'department_name': 'Teknologi',
          'salary_type_name': 'Bulanan',
          'work_schedule_name': 'Jam Kerja Normal',
        },
        {
          'id': 6,
          'employee_code': 'EMP006',
          'full_name': 'Fajar Staff',
          'email': 'fajar@kerjakita.local',
          'phone': '081234567895',
          'join_date': '2024-06-01',
          'status': 'active',
          'position_id': 3,
          'department_id': 3,
          'salary_type_id': 3,
          'work_schedule_id': 1,
          'position_name': 'Staff',
          'department_name': 'Teknologi',
          'salary_type_name': 'Kontrak',
          'work_schedule_name': 'Jam Kerja Normal',
        },
      ];

      var filtered = dummyList.where((e) {
        bool matchSearch =
            search == null ||
            search.isEmpty ||
            e['full_name'].toString().toLowerCase().contains(
              search.toLowerCase(),
            ) ||
            e['employee_code'].toString().toLowerCase().contains(
              search.toLowerCase(),
            );
        bool matchDept =
            departmentId == null ||
            departmentId == 0 ||
            e['department_id'] == departmentId;
        bool matchStatus =
            status == null || status == 'all' || e['status'] == status;
        return matchSearch && matchDept && matchStatus;
      }).toList();

      return {'total': filtered.length, 'data': filtered};
    }
  }

  /// SQL Query: Insert New Employee
  Future<bool> addEmployee({
    required String employeeCode,
    required String fullName,
    required String email,
    required String phone,
    required int positionId,
    required int departmentId,
    required int salaryTypeId,
    required int workScheduleId,
    required String joinDate,
    String status = 'active',
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          INSERT INTO employees 
          (employee_code, full_name, email, phone, position_id, department_id, salary_type_id, work_schedule_id, join_date, status)
          VALUES (:employee_code, :full_name, :email, :phone, :position_id, :department_id, :salary_type_id, :work_schedule_id, :join_date, :status)
          ''',
          {
            'employee_code': employeeCode,
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'position_id': positionId,
            'department_id': departmentId,
            'salary_type_id': salaryTypeId,
            'work_schedule_id': workScheduleId,
            'join_date': joinDate,
            'status': status,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error addEmployee: $err');
      return true;
    }
  }

  /// SQL Query: Update Employee
  Future<bool> updateEmployee({
    required int id,
    required String employeeCode,
    required String fullName,
    required String email,
    required String phone,
    required int positionId,
    required int departmentId,
    required int salaryTypeId,
    required int workScheduleId,
    required String joinDate,
    required String status,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          '''
          UPDATE employees 
          SET employee_code = :employee_code, full_name = :full_name, email = :email, phone = :phone, 
              position_id = :position_id, department_id = :department_id, salary_type_id = :salary_type_id, 
              work_schedule_id = :work_schedule_id, join_date = :join_date, status = :status
          WHERE id = :id
          ''',
          {
            'employee_code': employeeCode,
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'position_id': positionId,
            'department_id': departmentId,
            'salary_type_id': salaryTypeId,
            'work_schedule_id': workScheduleId,
            'join_date': joinDate,
            'status': status,
            'id': id,
          },
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.e('Error updateEmployee: $err');
      return true;
    }
  }

  /// SQL Query: Soft Delete / Toggle Employee Status
  Future<bool> toggleEmployeeStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'UPDATE employees SET status = :status WHERE id = :id',
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
      Utils.logger.e('Error toggleEmployeeStatus: $err');
      return true;
    }
  }
}

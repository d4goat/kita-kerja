import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/core/database/koneksi.dart';
import 'package:kita_kerja/models/employee_model.dart';

class EmployeeRepository {
  static final List<EmployeeModel> _fallbackEmployees = [
    EmployeeModel(
      id: 1,
      userId: 1,
      employeeCode: 'EMP001',
      fullName: 'Admin KerjaKita',
      email: 'admin@kerjakita.local',
      phone: '081234567890',
      joinDate: '2024-01-01',
      status: 'active',
      positionId: 1,
      positionName: 'Owner',
      departmentId: 1,
      departmentName: 'Operasional',
      salaryTypeId: 1,
      salaryTypeName: 'Bulanan',
      workScheduleId: 1,
      workScheduleName: 'Jam Kerja Normal',
    ),
    EmployeeModel(
      id: 2,
      userId: 2,
      employeeCode: 'EMP002',
      fullName: 'Budi Manager',
      email: 'manager@kerjakita.local',
      phone: '081234567891',
      joinDate: '2024-02-01',
      status: 'active',
      positionId: 2,
      positionName: 'Supervisor',
      departmentId: 1,
      departmentName: 'Operasional',
      salaryTypeId: 1,
      salaryTypeName: 'Bulanan',
      workScheduleId: 1,
      workScheduleName: 'Jam Kerja Normal',
      supervisorId: 1,
      supervisorName: 'Admin KerjaKita',
    ),
    EmployeeModel(
      id: 3,
      userId: 3,
      employeeCode: 'EMP003',
      fullName: 'Citra Staff',
      email: 'citra@kerjakita.local',
      phone: '081234567892',
      joinDate: '2024-03-01',
      status: 'active',
      positionId: 3,
      positionName: 'Staff',
      departmentId: 1,
      departmentName: 'Operasional',
      salaryTypeId: 1,
      salaryTypeName: 'Bulanan',
      workScheduleId: 1,
      workScheduleName: 'Jam Kerja Normal',
      supervisorId: 2,
      supervisorName: 'Budi Manager',
    ),
    EmployeeModel(
      id: 4,
      userId: 4,
      employeeCode: 'EMP004',
      fullName: 'Dedi Staff',
      email: 'dedi@kerjakita.local',
      phone: '081234567893',
      joinDate: '2024-04-01',
      status: 'active',
      positionId: 3,
      positionName: 'Staff',
      departmentId: 2,
      departmentName: 'Pemasaran',
      salaryTypeId: 1,
      salaryTypeName: 'Bulanan',
      workScheduleId: 2,
      workScheduleName: 'Shift Pagi',
      supervisorId: 2,
      supervisorName: 'Budi Manager',
    ),
    EmployeeModel(
      id: 5,
      userId: 5,
      employeeCode: 'EMP005',
      fullName: 'Eka Staff',
      email: 'eka@kerjakita.local',
      phone: '081234567894',
      joinDate: '2024-05-01',
      status: 'active',
      positionId: 3,
      positionName: 'Staff',
      departmentId: 3,
      departmentName: 'Teknologi',
      salaryTypeId: 1,
      salaryTypeName: 'Bulanan',
      workScheduleId: 1,
      workScheduleName: 'Jam Kerja Normal',
      supervisorId: 2,
      supervisorName: 'Budi Manager',
    ),
    EmployeeModel(
      id: 6,
      userId: 6,
      employeeCode: 'EMP006',
      fullName: 'Fajar Staff',
      email: 'fajar@kerjakita.local',
      phone: '081234567895',
      joinDate: '2024-06-01',
      status: 'active',
      positionId: 3,
      positionName: 'Staff',
      departmentId: 3,
      departmentName: 'Teknologi',
      salaryTypeId: 3,
      salaryTypeName: 'Kontrak',
      workScheduleId: 1,
      workScheduleName: 'Jam Kerja Normal',
      supervisorId: 2,
      supervisorName: 'Budi Manager',
    ),
  ];

  Future<Map<String, dynamic>> getEmployees({
    String? search,
    int? departmentId,
    String? status,
    int? supervisorId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        Map<String, dynamic> params = {};
        List<String> conditions = [];

        if (search != null && search.trim().isNotEmpty) {
          conditions.add('(e.full_name LIKE :search OR e.employee_code LIKE :search OR e.email LIKE :search)');
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

        if (supervisorId != null && supervisorId > 0) {
          conditions.add('(es.supervisor_id = :supervisor_id OR e.id = :supervisor_id)');
          params['supervisor_id'] = supervisorId;
        }

        String whereClause = conditions.isNotEmpty ? 'WHERE ${conditions.join(" AND ")}' : '';
        int offset = (page - 1) * pageSize;

        var countResult = await connection.execute(
          'SELECT COUNT(DISTINCT e.id) as total FROM employees e LEFT JOIN employee_supervisors es ON e.id = es.employee_id $whereClause',
          params,
        );
        int total = 0;
        if (countResult.rows.isNotEmpty) {
          total = int.tryParse(countResult.rows.first.assoc()['total'] ?? '') ?? 0;
        }

        String query = '''
          SELECT 
            e.id, e.user_id, e.employee_code, e.full_name, e.email, e.phone, e.join_date, e.status,
            e.position_id, e.department_id, e.salary_type_id, e.work_schedule_id,
            p.name AS position_name,
            d.name AS department_name,
            st.name AS salary_type_name,
            ws.name AS work_schedule_name,
            es.supervisor_id,
            sup.full_name AS supervisor_name
          FROM employees e
          INNER JOIN positions p ON e.position_id = p.id
          INNER JOIN departments d ON e.department_id = d.id
          INNER JOIN salary_types st ON e.salary_type_id = st.id
          INNER JOIN work_schedules ws ON e.work_schedule_id = ws.id
          LEFT JOIN employee_supervisors es ON e.id = es.employee_id
          LEFT JOIN employees sup ON es.supervisor_id = sup.id
          $whereClause
          ORDER BY e.id ASC
          LIMIT $pageSize OFFSET $offset
        ''';

        var results = await connection.execute(query, params);
        List<EmployeeModel> list = results.rows.map((row) => EmployeeModel.fromMap(row.assoc())).toList();
        return {'total': total, 'data': list};
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('MySQL Employees Fallback: $err');
      var filtered = _fallbackEmployees.where((e) {
        bool matchSearch = search == null || search.isEmpty ||
            e.fullName.toLowerCase().contains(search.toLowerCase()) ||
            e.employeeCode.toLowerCase().contains(search.toLowerCase());
        bool matchDept = departmentId == null || departmentId == 0 || e.departmentId == departmentId;
        bool matchStatus = status == null || status == 'all' || e.status == status;
        bool matchSup = supervisorId == null || supervisorId == 0 || e.supervisorId == supervisorId || e.id == supervisorId;
        return matchSearch && matchDept && matchStatus && matchSup;
      }).toList();
      return {'total': filtered.length, 'data': filtered};
    }
  }

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
    String? password,
    int? supervisorId,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.transactional((conn) async {
          final res = await conn.execute(
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

          final newEmpId = res.lastInsertID.toInt();
          if (supervisorId != null && supervisorId > 0 && newEmpId > 0) {
            await conn.execute(
              '''
              INSERT INTO employee_supervisors (employee_id, supervisor_id)
              VALUES (:emp_id, :sup_id)
              ''',
              {'emp_id': newEmpId, 'sup_id': supervisorId},
            );
          }

          if (password != null && password.trim().isNotEmpty) {
            await conn.execute(
              '''
              INSERT INTO users (role_id, name, email, password, phone, status)
              VALUES (3, :name, :email, :password, :phone, :status)
              ''',
              {
                'name': fullName,
                'email': email,
                'password': password.trim(),
                'phone': phone,
                'status': status,
              },
            );
          }
        });
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback addEmployee: $err');
      _fallbackEmployees.add(
        EmployeeModel(
          id: _fallbackEmployees.length + 1,
          employeeCode: employeeCode,
          fullName: fullName,
          email: email,
          phone: phone,
          positionId: positionId,
          positionName: 'Staff',
          departmentId: departmentId,
          departmentName: 'Operasional',
          salaryTypeId: salaryTypeId,
          salaryTypeName: 'Bulanan',
          workScheduleId: workScheduleId,
          workScheduleName: 'Jam Kerja Normal',
          joinDate: joinDate,
          status: status,
          supervisorId: supervisorId,
          supervisorName: supervisorId != null
              ? _fallbackEmployees
                  .firstWhere((e) => e.id == supervisorId,
                      orElse: () => _fallbackEmployees.first)
                  .fullName
              : null,
        ),
      );
      return true;
    }
  }

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
    int? supervisorId,
  }) async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.transactional((conn) async {
          await conn.execute(
            '''
            UPDATE employees 
            SET employee_code = :employee_code, full_name = :full_name, email = :email, phone = :phone, 
                position_id = :position_id, department_id = :department_id, salary_type_id = :salary_type_id, 
                work_schedule_id = :work_schedule_id, join_date = :join_date, status = :status
            WHERE id = :id
            ''',
            {
              'id': id,
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

          await conn.execute(
            'DELETE FROM employee_supervisors WHERE employee_id = :id',
            {'id': id},
          );

          if (supervisorId != null && supervisorId > 0) {
            await conn.execute(
              '''
              INSERT INTO employee_supervisors (employee_id, supervisor_id)
              VALUES (:id, :sup_id)
              ''',
              {'id': id, 'sup_id': supervisorId},
            );
          }
        });
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback updateEmployee: $err');
      final idx = _fallbackEmployees.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        final prev = _fallbackEmployees[idx];
        _fallbackEmployees[idx] = EmployeeModel(
          id: id,
          userId: prev.userId,
          employeeCode: employeeCode,
          fullName: fullName,
          email: email,
          phone: phone,
          positionId: positionId,
          positionName: prev.positionName,
          departmentId: departmentId,
          departmentName: prev.departmentName,
          salaryTypeId: salaryTypeId,
          salaryTypeName: prev.salaryTypeName,
          workScheduleId: workScheduleId,
          workScheduleName: prev.workScheduleName,
          joinDate: joinDate,
          status: status,
          supervisorId: supervisorId,
          supervisorName: supervisorId != null
              ? _fallbackEmployees
                  .firstWhere((e) => e.id == supervisorId,
                      orElse: () => _fallbackEmployees.first)
                  .fullName
              : null,
        );
      }
      return true;
    }
  }

  Future<List<Map<String, dynamic>>> getSupervisors() async {
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        final query = '''
          SELECT e.id, e.employee_code, e.full_name, p.name AS position_name
          FROM employees e
          INNER JOIN positions p ON e.position_id = p.id
          WHERE e.status = 'active'
          ORDER BY e.full_name ASC
        ''';
        final results = await connection.execute(query);
        return results.rows.map((row) => row.assoc()).toList();
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('getSupervisors fallback: $err');
      return _fallbackEmployees.map((e) => {
        'id': e.id,
        'employee_code': e.employeeCode,
        'full_name': e.fullName,
        'position_name': e.positionName,
      }).toList();
    }
  }

  Future<bool> toggleEmployeeStatus(int id, String currentStatus) async {
    final nextStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      var connection = await DatabaseConnection.getConnection();
      try {
        await connection.execute(
          'UPDATE employees SET status = :status WHERE id = :id',
          {'id': id, 'status': nextStatus},
        );
        return true;
      } finally {
        await connection.close();
      }
    } catch (err) {
      Utils.logger.w('Fallback toggleEmployeeStatus: $err');
      final idx = _fallbackEmployees.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        final prev = _fallbackEmployees[idx];
        _fallbackEmployees[idx] = EmployeeModel(
          id: id,
          userId: prev.userId,
          employeeCode: prev.employeeCode,
          fullName: prev.fullName,
          email: prev.email,
          phone: prev.phone,
          positionId: prev.positionId,
          positionName: prev.positionName,
          departmentId: prev.departmentId,
          departmentName: prev.departmentName,
          salaryTypeId: prev.salaryTypeId,
          salaryTypeName: prev.salaryTypeName,
          workScheduleId: prev.workScheduleId,
          workScheduleName: prev.workScheduleName,
          joinDate: prev.joinDate,
          status: nextStatus,
        );
      }
      return true;
    }
  }
}

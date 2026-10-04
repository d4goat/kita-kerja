import 'package:mysql1/mysql1.dart';

import 'package:kita_kerja/database/koneksi.dart';
import 'package:kita_kerja/database/auth_query.dart';
import 'package:kita_kerja/database/jabatan_query.dart';
import 'package:kita_kerja/database/departemen_query.dart';
import 'package:kita_kerja/database/kategori_pekerjaan_query.dart';
import 'package:kita_kerja/database/jenis_gaji_query.dart';
import 'package:kita_kerja/database/jadwal_kerja_query.dart';
import 'package:kita_kerja/database/karyawan_query.dart';
import 'package:kita_kerja/database/gaji_query.dart';
import 'package:kita_kerja/database/kehadiran_query.dart';
import 'package:kita_kerja/database/pekerjaan_query.dart';
import 'package:kita_kerja/database/dashboard_query.dart';

// Export all modular queries for direct imports
export 'package:kita_kerja/database/koneksi.dart';
export 'package:kita_kerja/database/auth_query.dart';
export 'package:kita_kerja/database/jabatan_query.dart';
export 'package:kita_kerja/database/departemen_query.dart';
export 'package:kita_kerja/database/kategori_pekerjaan_query.dart';
export 'package:kita_kerja/database/jenis_gaji_query.dart';
export 'package:kita_kerja/database/jadwal_kerja_query.dart';
export 'package:kita_kerja/database/karyawan_query.dart';
export 'package:kita_kerja/database/gaji_query.dart';
export 'package:kita_kerja/database/kehadiran_query.dart';
export 'package:kita_kerja/database/pekerjaan_query.dart';
export 'package:kita_kerja/database/dashboard_query.dart';

/// Class facade helper untuk MySQL Database (DBMS: MySQL 8.x - Database: kerjakita)
/// Menggabungkan dan mendelegasikan pemanggilan query ke masing-masing file query modular.
class MySQLHelper {
  static String get host => DatabaseConnection.host;
  static set host(String value) => DatabaseConnection.host = value;

  static int get port => DatabaseConnection.port;
  static set port(int value) => DatabaseConnection.port = value;

  static String get user => DatabaseConnection.user;
  static set user(String value) => DatabaseConnection.user = value;

  static String get password => DatabaseConnection.password;
  static set password(String value) => DatabaseConnection.password = value;

  static String get db => DatabaseConnection.db;
  static set db(String value) => DatabaseConnection.db = value;

  // Instances of modular queries
  final AuthQuery auth = AuthQuery();
  final JabatanQuery jabatan = JabatanQuery();
  final DepartemenQuery departemen = DepartemenQuery();
  final KategoriPekerjaanQuery kategoriPekerjaan = KategoriPekerjaanQuery();
  final JenisGajiQuery jenisGaji = JenisGajiQuery();
  final JadwalKerjaQuery jadwalKerja = JadwalKerjaQuery();
  final KaryawanQuery karyawan = KaryawanQuery();
  final GajiQuery gaji = GajiQuery();
  final KehadiranQuery kehadiran = KehadiranQuery();
  final PekerjaanQuery pekerjaan = PekerjaanQuery();
  final DashboardQuery dashboard = DashboardQuery();

  /// Membuat koneksi ke Database MySQL
  Future<MySqlConnection> getConnection() async {
    return await DatabaseConnection.getConnection();
  }

  // =========================================================
  // 1. AUTENTIKASI (USERS & ROLES)
  // =========================================================

  Future<Map<String, dynamic>?> loginUser(
    String email,
    String passwordInput,
  ) => auth.loginUser(email, passwordInput);

  Future<bool> registerOwner({
    required String namaUsaha,
    required String namaLengkap,
    required String email,
    required String password,
  }) => auth.registerOwner(
    namaUsaha: namaUsaha,
    namaLengkap: namaLengkap,
    email: email,
    password: password,
  );

  Future<List<Map<String, dynamic>>> getUsers() => auth.getUsers();

  // =========================================================
  // 2. DATA MASTER: JABATAN (POSITIONS)
  // =========================================================

  Future<List<Map<String, dynamic>>> getPositions() => jabatan.getPositions();

  Future<bool> addPosition(String name, String description) =>
      jabatan.addPosition(name, description);

  Future<bool> updatePosition(
    int id,
    String name,
    String description,
    String status,
  ) => jabatan.updatePosition(id, name, description, status);

  Future<bool> togglePositionStatus(int id, String currentStatus) =>
      jabatan.togglePositionStatus(id, currentStatus);

  // =========================================================
  // 3. DATA MASTER: DEPARTEMEN (DEPARTMENTS)
  // =========================================================

  Future<List<Map<String, dynamic>>> getDepartments() =>
      departemen.getDepartments();

  Future<bool> addDepartment(String name, String description) =>
      departemen.addDepartment(name, description);

  Future<bool> updateDepartment(
    int id,
    String name,
    String description,
    String status,
  ) => departemen.updateDepartment(id, name, description, status);

  Future<bool> toggleDepartmentStatus(int id, String currentStatus) =>
      departemen.toggleDepartmentStatus(id, currentStatus);

  // =========================================================
  // 4. DATA MASTER: KATEGORI PEKERJAAN (JOB_CATEGORIES)
  // =========================================================

  Future<List<Map<String, dynamic>>> getJobCategories() =>
      kategoriPekerjaan.getJobCategories();

  Future<bool> addJobCategory(String name, String description) =>
      kategoriPekerjaan.addJobCategory(name, description);

  Future<bool> updateJobCategory(
    int id,
    String name,
    String description,
    String status,
  ) => kategoriPekerjaan.updateJobCategory(id, name, description, status);

  Future<bool> toggleJobCategoryStatus(int id, String currentStatus) =>
      kategoriPekerjaan.toggleJobCategoryStatus(id, currentStatus);

  // =========================================================
  // 5. DATA MASTER: JENIS GAJI (SALARY_TYPES)
  // =========================================================

  Future<List<Map<String, dynamic>>> getSalaryTypes() =>
      jenisGaji.getSalaryTypes();

  Future<bool> addSalaryType(String name, String description) =>
      jenisGaji.addSalaryType(name, description);

  Future<bool> updateSalaryType(
    int id,
    String name,
    String description,
    String status,
  ) => jenisGaji.updateSalaryType(id, name, description, status);

  Future<bool> toggleSalaryTypeStatus(int id, String currentStatus) =>
      jenisGaji.toggleSalaryTypeStatus(id, currentStatus);

  // =========================================================
  // 6. DATA MASTER: JADWAL KERJA (WORK_SCHEDULES)
  // =========================================================

  Future<List<Map<String, dynamic>>> getWorkSchedules() =>
      jadwalKerja.getWorkSchedules();

  Future<bool> addWorkSchedule({
    required String name,
    required String startTime,
    required String endTime,
    required int breakMinutes,
    required double workingHours,
  }) => jadwalKerja.addWorkSchedule(
    name: name,
    startTime: startTime,
    endTime: endTime,
    breakMinutes: breakMinutes,
    workingHours: workingHours,
  );

  Future<bool> updateWorkSchedule({
    required int id,
    required String name,
    required String startTime,
    required String endTime,
    required int breakMinutes,
    required double workingHours,
    required String status,
  }) => jadwalKerja.updateWorkSchedule(
    id: id,
    name: name,
    startTime: startTime,
    endTime: endTime,
    breakMinutes: breakMinutes,
    workingHours: workingHours,
    status: status,
  );

  Future<bool> toggleWorkScheduleStatus(int id, String currentStatus) =>
      jadwalKerja.toggleWorkScheduleStatus(id, currentStatus);

  // =========================================================
  // 7. EMPLOYEES (KARYAWAN)
  // =========================================================

  Future<Map<String, dynamic>> getEmployees({
    String? search,
    int? departmentId,
    String? status,
    int page = 1,
    int pageSize = 10,
  }) => karyawan.getEmployees(
    search: search,
    departmentId: departmentId,
    status: status,
    page: page,
    pageSize: pageSize,
  );

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
  }) => karyawan.addEmployee(
    employeeCode: employeeCode,
    fullName: fullName,
    email: email,
    phone: phone,
    positionId: positionId,
    departmentId: departmentId,
    salaryTypeId: salaryTypeId,
    workScheduleId: workScheduleId,
    joinDate: joinDate,
    status: status,
  );

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
  }) => karyawan.updateEmployee(
    id: id,
    employeeCode: employeeCode,
    fullName: fullName,
    email: email,
    phone: phone,
    positionId: positionId,
    departmentId: departmentId,
    salaryTypeId: salaryTypeId,
    workScheduleId: workScheduleId,
    joinDate: joinDate,
    status: status,
  );

  Future<bool> toggleEmployeeStatus(int id, String currentStatus) =>
      karyawan.toggleEmployeeStatus(id, currentStatus);

  // =========================================================
  // 8. SALARIES (REKAP GAJI)
  // =========================================================

  Future<List<Map<String, dynamic>>> getSalaries({
    int periodMonth = 9,
    int periodYear = 2026,
    int? departmentId,
  }) => gaji.getSalaries(
    periodMonth: periodMonth,
    periodYear: periodYear,
    departmentId: departmentId,
  );

  // =========================================================
  // 9. ATTENDANCES (KEHADIRAN)
  // =========================================================

  Future<List<Map<String, dynamic>>> getAttendances({String? search}) =>
      kehadiran.getAttendances(search: search);

  // =========================================================
  // 10. TASKS (PEKERJAAN)
  // =========================================================

  Future<List<Map<String, dynamic>>> getTasks({
    String? search,
    String? status,
  }) => pekerjaan.getTasks(search: search, status: status);

  Future<bool> addTask({
    required int categoryId,
    int createdBy = 1,
    required int assignedTo,
    required String title,
    String? description,
    String priority = 'medium',
    String status = 'not_started',
    double estimatedHours = 0.0,
    double actualHours = 0.0,
    String? startDate,
    required String deadline,
  }) => pekerjaan.addTask(
    categoryId: categoryId,
    createdBy: createdBy,
    assignedTo: assignedTo,
    title: title,
    description: description,
    priority: priority,
    status: status,
    estimatedHours: estimatedHours,
    actualHours: actualHours,
    startDate: startDate,
    deadline: deadline,
  );

  Future<bool> updateTask({
    required int id,
    required int categoryId,
    required int assignedTo,
    required String title,
    String? description,
    required String priority,
    required String status,
    required double estimatedHours,
    required double actualHours,
    String? startDate,
    required String deadline,
  }) => pekerjaan.updateTask(
    id: id,
    categoryId: categoryId,
    assignedTo: assignedTo,
    title: title,
    description: description,
    priority: priority,
    status: status,
    estimatedHours: estimatedHours,
    actualHours: actualHours,
    startDate: startDate,
    deadline: deadline,
  );

  Future<bool> updateTaskStatus(int id, String status) =>
      pekerjaan.updateTaskStatus(id, status);

  Future<bool> deleteTask(int id) => pekerjaan.deleteTask(id);

  // =========================================================
  // 11. DASHBOARD & WORKLOAD DATA
  // =========================================================

  Future<Map<String, dynamic>> getDashboardData() =>
      dashboard.getDashboardData();
}

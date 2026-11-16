import 'package:flutter/material.dart';
import 'package:kita_kerja/models/employee_model.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:kita_kerja/repositories/employee_repository.dart';

class EmployeeController extends ChangeNotifier {
  final EmployeeRepository _repository = EmployeeRepository();

  List<EmployeeModel> _employees = [];
  int _totalEmployees = 0;
  bool _isLoading = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  String _searchQuery = '';
  int _selectedDepartmentId = 0;
  String _selectedStatus = 'all';
  UserModel? _currentUser;

  List<EmployeeModel> get employees => _employees;
  int get totalEmployees => _totalEmployees;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  String get searchQuery => _searchQuery;
  int get selectedDepartmentId => _selectedDepartmentId;
  String get selectedStatus => _selectedStatus;
  UserModel? get currentUser => _currentUser;

  void initUser(UserModel? user) {
    _currentUser = user;
  }

  void setSearchQuery(String val) {
    _searchQuery = val;
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedDepartmentId(int val) {
    _selectedDepartmentId = val;
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedStatus(String val) {
    _selectedStatus = val;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    loadEmployees();
  }

  Future<void> loadEmployees({UserModel? currentUser}) async {
    if (currentUser != null) {
      _currentUser = currentUser;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final supId = (_currentUser != null && _currentUser!.isManager)
          ? _currentUser!.employeeId
          : null;
      final result = await _repository.getEmployees(
        search: _searchQuery,
        departmentId: _selectedDepartmentId > 0 ? _selectedDepartmentId : null,
        status: _selectedStatus,
        supervisorId: supId,
        page: _currentPage,
        pageSize: _pageSize,
      );
      _totalEmployees = result['total'] as int;
      _employees = List<EmployeeModel>.from(result['data']);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getSupervisors() async {
    return await _repository.getSupervisors();
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
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.addEmployee(
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
        password: password,
        supervisorId: supervisorId,
      );
      if (success) {
        await loadEmployees();
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.updateEmployee(
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
        supervisorId: supervisorId,
      );
      if (success) {
        await loadEmployees();
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleEmployeeStatus(int id, String currentStatus) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.toggleEmployeeStatus(id, currentStatus);
      if (success) {
        await loadEmployees();
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

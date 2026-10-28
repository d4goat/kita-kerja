import 'package:flutter/material.dart';
import 'package:kita_kerja/models/employee_model.dart';
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

  List<EmployeeModel> get employees => _employees;
  int get totalEmployees => _totalEmployees;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  String get searchQuery => _searchQuery;
  int get selectedDepartmentId => _selectedDepartmentId;
  String get selectedStatus => _selectedStatus;

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

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _repository.getEmployees(
        search: _searchQuery,
        departmentId: _selectedDepartmentId > 0 ? _selectedDepartmentId : null,
        status: _selectedStatus,
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

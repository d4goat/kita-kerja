import 'package:flutter/material.dart';
import 'package:kita_kerja/models/salary_model.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:kita_kerja/repositories/salary_repository.dart';

class SalaryController extends ChangeNotifier {
  final SalaryRepository _repository = SalaryRepository();

  List<SalaryModel> _salaries = [];
  List<SalaryModel> _mySalaries = [];
  bool _isLoading = false;
  int _selectedMonth = 9;
  int _selectedYear = 2026;
  int _selectedDeptId = 0;

  List<SalaryModel> get salaries => _salaries;
  List<SalaryModel> get mySalaries => _mySalaries;
  bool get isLoading => _isLoading;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  int get selectedDeptId => _selectedDeptId;

  void setSelectedMonth(int month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setSelectedYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setSelectedDeptId(int deptId) {
    _selectedDeptId = deptId;
    notifyListeners();
  }

  Future<void> loadSalaries(UserModel? currentUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (currentUser != null && currentUser.isEmployee) {
        _mySalaries = await _repository.getMySalaries(
          employeeId: currentUser.employeeId ?? 3,
          periodYear: _selectedYear,
        );
      } else {
        _salaries = await _repository.getSalaries(
          periodMonth: _selectedMonth,
          periodYear: _selectedYear,
          departmentId: _selectedDeptId > 0 ? _selectedDeptId : null,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSalaryStatus(int id, String status, UserModel? currentUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.updateSalaryStatus(id, status);
      if (success) {
        await loadSalaries(currentUser);
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:kita_kerja/models/master_data_model.dart';
import 'package:kita_kerja/repositories/master_data_repository.dart';

class MasterDataController extends ChangeNotifier {
  final MasterDataRepository _repository = MasterDataRepository();

  int _selectedTabIndex = 0;
  bool _isLoading = false;

  List<PositionModel> _positions = [];
  List<DepartmentModel> _departments = [];
  List<JobCategoryModel> _jobCategories = [];
  List<SalaryTypeModel> _salaryTypes = [];
  List<WorkScheduleModel> _workSchedules = [];

  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;

  List<PositionModel> get positions => _positions;
  List<DepartmentModel> get departments => _departments;
  List<JobCategoryModel> get jobCategories => _jobCategories;
  List<SalaryTypeModel> get salaryTypes => _salaryTypes;
  List<WorkScheduleModel> get workSchedules => _workSchedules;

  List<Map<String, dynamic>> get currentDataList {
    switch (_selectedTabIndex) {
      case 0:
        return _positions.map((e) => e.toMap()).toList();
      case 1:
        return _departments.map((e) => e.toMap()).toList();
      case 2:
        return _jobCategories.map((e) => e.toMap()).toList();
      case 3:
        return _salaryTypes.map((e) => e.toMap()).toList();
      case 4:
        return _workSchedules.map((e) => e.toMap()).toList();
      default:
        return [];
    }
  }

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    loadCurrentTab();
  }

  Future<void> loadCurrentTab() async {
    _isLoading = true;
    notifyListeners();
    try {
      switch (_selectedTabIndex) {
        case 0:
          _positions = await _repository.getPositions();
          break;
        case 1:
          _departments = await _repository.getDepartments();
          break;
        case 2:
          _jobCategories = await _repository.getJobCategories();
          break;
        case 3:
          _salaryTypes = await _repository.getSalaryTypes();
          break;
        case 4:
          _workSchedules = await _repository.getWorkSchedules();
          break;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _positions = await _repository.getPositions();
      _departments = await _repository.getDepartments();
      _jobCategories = await _repository.getJobCategories();
      _salaryTypes = await _repository.getSalaryTypes();
      _workSchedules = await _repository.getWorkSchedules();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Position Actions
  Future<bool> addPosition(String name, String desc) async {
    final ok = await _repository.addPosition(name, desc);
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> updatePosition(int id, String name, String desc, String status) async {
    final ok = await _repository.updatePosition(id, name, desc, status);
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> togglePositionStatus(int id, String currentStatus) async {
    final ok = await _repository.togglePositionStatus(id, currentStatus);
    if (ok) await loadCurrentTab();
    return ok;
  }

  // Department Actions
  Future<bool> addDepartment(String name, String desc) async {
    final ok = await _repository.addDepartment(name, desc);
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> updateDepartment(int id, String name, String desc, String status) async {
    final ok = await _repository.updateDepartment(id, name, desc, status);
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> toggleDepartmentStatus(int id, String currentStatus) async {
    final ok = await _repository.toggleDepartmentStatus(id, currentStatus);
    if (ok) await loadCurrentTab();
    return ok;
  }

  // Job Category Actions
  Future<bool> addJobCategory(String name, String desc) async {
    final ok = await _repository.addJobCategory(name, desc);
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> updateJobCategory(int id, String name, String desc, String status) async {
    final ok = await _repository.updateJobCategory(id, name, desc, status);
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> toggleJobCategoryStatus(int id, String currentStatus) async {
    final ok = await _repository.toggleJobCategoryStatus(id, currentStatus);
    if (ok) await loadCurrentTab();
    return ok;
  }

  // Salary Type Actions
  Future<bool> addSalaryType(String name, String desc) async {
    final ok = await _repository.addSalaryType(name, desc);
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> updateSalaryType(int id, String name, String desc, String status) async {
    final ok = await _repository.updateSalaryType(id, name, desc, status);
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> toggleSalaryTypeStatus(int id, String currentStatus) async {
    final ok = await _repository.toggleSalaryTypeStatus(id, currentStatus);
    if (ok) await loadCurrentTab();
    return ok;
  }

  // Work Schedule Actions
  Future<bool> addWorkSchedule({
    required String name,
    required String startTime,
    required String endTime,
    required int breakMinutes,
    required double workingHours,
  }) async {
    final ok = await _repository.addWorkSchedule(
      name: name,
      startTime: startTime,
      endTime: endTime,
      breakMinutes: breakMinutes,
      workingHours: workingHours,
    );
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> updateWorkSchedule({
    required int id,
    required String name,
    required String startTime,
    required String endTime,
    required int breakMinutes,
    required double workingHours,
    required String status,
  }) async {
    final ok = await _repository.updateWorkSchedule(
      id: id,
      name: name,
      startTime: startTime,
      endTime: endTime,
      breakMinutes: breakMinutes,
      workingHours: workingHours,
      status: status,
    );
    if (ok) await loadCurrentTab();
    return ok;
  }

  Future<bool> toggleWorkScheduleStatus(int id, String currentStatus) async {
    final ok = await _repository.toggleWorkScheduleStatus(id, currentStatus);
    if (ok) await loadCurrentTab();
    return ok;
  }
}

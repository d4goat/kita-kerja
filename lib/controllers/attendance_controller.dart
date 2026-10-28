import 'package:flutter/material.dart';
import 'package:kita_kerja/models/attendance_model.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:kita_kerja/repositories/attendance_repository.dart';

class AttendanceController extends ChangeNotifier {
  final AttendanceRepository _repository = AttendanceRepository();

  List<AttendanceModel> _attendances = [];
  AttendanceModel? _todayAttendance;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  List<AttendanceModel> get attendances => _attendances;
  AttendanceModel? get todayAttendance => _todayAttendance;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;

  bool get hasClockedInToday =>
      _todayAttendance != null && _todayAttendance!.hasClockedIn;
  bool get hasClockedOutToday =>
      _todayAttendance != null && _todayAttendance!.hasClockedOut;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> loadAttendances(UserModel? currentUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      final empId = currentUser?.employeeId ?? 3;
      if (currentUser != null && currentUser.isEmployee) {
        _attendances = await _repository.getEmployeeAttendances(empId);
        _todayAttendance = await _repository.getTodayAttendance(empId);
      } else {
        _attendances = await _repository.getAttendances(search: _searchQuery);
        _todayAttendance = await _repository.getTodayAttendance(empId);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clockIn(UserModel currentUser, {String? notes}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final empId = currentUser.employeeId ?? 3;
      final success = await _repository.clockIn(
        employeeId: empId,
        notes: notes,
      );
      if (success) {
        await loadAttendances(currentUser);
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clockOut(UserModel currentUser, {String? notes}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final empId = currentUser.employeeId ?? 3;
      final success = await _repository.clockOut(
        employeeId: empId,
        notes: notes,
      );
      if (success) {
        await loadAttendances(currentUser);
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AttendanceModel> get filteredAttendances {
    return _attendances.where((item) {
      final name = item.employeeName.toLowerCase();
      final code = item.employeeCode.toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty || name.contains(q) || code.contains(q);
      final matchStatus = _selectedStatus == 'all' || item.status == _selectedStatus;
      return matchSearch && matchStatus;
    }).toList();
  }
}

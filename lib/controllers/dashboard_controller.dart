import 'package:flutter/material.dart';
import 'package:kita_kerja/models/dashboard_summary_model.dart';
import 'package:kita_kerja/models/report_model.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:kita_kerja/repositories/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  DashboardSummaryModel? _dashboardData;
  DashboardReportData? _reportData;
  ReportFilter _reportFilter = const ReportFilter();
  bool _isLoading = false;
  bool _isReportLoading = false;

  DashboardSummaryModel? get dashboardData => _dashboardData;
  DashboardReportData? get reportData => _reportData;
  ReportFilter get reportFilter => _reportFilter;
  bool get isLoading => _isLoading;
  bool get isReportLoading => _isReportLoading;

  Future<void> loadDashboard(UserModel? currentUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (currentUser != null && currentUser.isEmployee) {
        _dashboardData = await _repository.getEmployeeDashboardData(
          currentUser.employeeId ?? 3,
        );
      } else {
        _dashboardData = await _repository.getAdminDashboardData();
      }
      // Muat juga data pelaporan analitik
      await loadReport(currentUser, notify: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReport(UserModel? currentUser, {bool notify = true}) async {
    _isReportLoading = true;
    if (notify) notifyListeners();
    try {
      final empId = currentUser != null && currentUser.isEmployee
          ? (currentUser.employeeId ?? 3)
          : null;
      final supId = currentUser != null && currentUser.isManager
          ? (currentUser.employeeId ?? 2)
          : null;

      _reportData = await _repository.getReportData(
        _reportFilter,
        employeeId: empId,
        supervisorId: supId,
      );
    } finally {
      _isReportLoading = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> updateFilter(ReportFilter newFilter, UserModel? currentUser) async {
    _reportFilter = newFilter;
    await loadReport(currentUser);
  }
}

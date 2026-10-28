import 'package:flutter/material.dart';
import 'package:kita_kerja/models/dashboard_summary_model.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:kita_kerja/repositories/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  DashboardSummaryModel? _dashboardData;
  bool _isLoading = false;

  DashboardSummaryModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;

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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

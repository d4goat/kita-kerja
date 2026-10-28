import 'package:flutter/material.dart';
import 'package:kita_kerja/models/task_model.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:kita_kerja/repositories/task_repository.dart';

class TaskController extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<TaskModel> _tasks = [];
  Map<String, int> _summaryMetrics = {
    'total_active': 0,
    'not_started_count': 0,
    'in_progress_count': 0,
    'review_count': 0,
    'completed_count': 0,
  };
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  List<TaskModel> get tasks => _tasks;
  Map<String, int> get summaryMetrics => _summaryMetrics;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> loadTasks(UserModel? currentUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      final empId = currentUser?.employeeId ?? 3;
      if (currentUser != null && currentUser.isEmployee) {
        _tasks = await _repository.getMyTasks(
          employeeId: empId,
          search: _searchQuery,
          status: _selectedStatus,
        );
        _summaryMetrics = await _repository.getJobdeskSummaryMetrics(empId);
      } else {
        _tasks = await _repository.getTasks(
          search: _searchQuery,
          status: _selectedStatus,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTaskStatus({
    required int taskId,
    required String status,
    UserModel? currentUser,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.updateTaskStatus(
        taskId,
        status,
        employeeId: currentUser?.employeeId,
        notes: notes,
      );
      if (success) {
        await loadTasks(currentUser);
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(TaskModel task, UserModel? currentUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.addTask(task);
      if (success) {
        await loadTasks(currentUser);
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTask(TaskModel task, UserModel? currentUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.updateTask(task);
      if (success) {
        await loadTasks(currentUser);
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTask(int id, UserModel? currentUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.deleteTask(id);
      if (success) {
        await loadTasks(currentUser);
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TaskModel> get filteredTasks {
    return _tasks.where((item) {
      final title = item.title.toLowerCase();
      final emp = item.assignedToName.toLowerCase();
      final cat = item.categoryName.toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty || title.contains(q) || emp.contains(q) || cat.contains(q);
      final matchStatus = _selectedStatus == 'all' || item.status == _selectedStatus;
      return matchSearch && matchStatus;
    }).toList();
  }
}

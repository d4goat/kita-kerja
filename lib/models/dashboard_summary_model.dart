import 'workload_model.dart';
export 'workload_model.dart';

class DashboardSummaryModel {
  final int totalEmployees;
  final int presentToday;
  final String presentPercentage;
  final int activeTasks;
  final int activeTeamsCount;
  final int overtimeCount;
  final WorkloadModel? overloadedEmployee;
  final List<WorkloadModel> workloadList;
  final List<Map<String, dynamic>> attendanceList;
  final List<Map<String, dynamic>> taskList;

  // Personal metrics for Karyawan role
  final bool hasClockedInToday;
  final String? todayClockInTime;
  final String? todayClockOutTime;
  final int myActiveTasksCount;
  final int myInProgressTasksCount;
  final int myReviewTasksCount;
  final int myCompletedTasksCount;
  final double myAssignedHours;
  final double myCapacityHours;
  final double myWorkloadPercentage;

  DashboardSummaryModel({
    this.totalEmployees = 0,
    this.presentToday = 0,
    this.presentPercentage = '0%',
    this.activeTasks = 0,
    this.activeTeamsCount = 0,
    this.overtimeCount = 0,
    this.overloadedEmployee,
    this.workloadList = const [],
    this.attendanceList = const [],
    this.taskList = const [],
    this.hasClockedInToday = false,
    this.todayClockInTime,
    this.todayClockOutTime,
    this.myActiveTasksCount = 0,
    this.myInProgressTasksCount = 0,
    this.myReviewTasksCount = 0,
    this.myCompletedTasksCount = 0,
    this.myAssignedHours = 0.0,
    this.myCapacityHours = 160.0,
    this.myWorkloadPercentage = 0.0,
  });
}

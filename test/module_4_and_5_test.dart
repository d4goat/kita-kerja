import 'package:flutter_test/flutter_test.dart';
import 'package:kita_kerja/models/master_data_model.dart';
import 'package:kita_kerja/models/task_model.dart';
import 'package:kita_kerja/models/task_progress_model.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:kita_kerja/repositories/attendance_repository.dart';
import 'package:kita_kerja/repositories/task_repository.dart';
import 'package:kita_kerja/controllers/task_controller.dart';

void main() {
  group('Modul 4: Kalkulasi Jam Kerja & Lembur Berdasarkan work_schedules', () {
    late AttendanceRepository attendanceRepo;

    setUp(() {
      attendanceRepo = AttendanceRepository();
    });

    test('getEmployeeSchedule mengembalikan jadwal normal atau shift pagi yang valid', () async {
      final normalSchedule = await attendanceRepo.getEmployeeSchedule(3); // Citra
      expect(normalSchedule, isNotNull);
      expect(normalSchedule!.workingHours, 8.0);
      expect(normalSchedule.breakMinutes, 60);

      final shiftSchedule = await attendanceRepo.getEmployeeSchedule(4); // Dedi - Shift Pagi
      expect(shiftSchedule, isNotNull);
      expect(shiftSchedule!.workingHours, 7.0);
      expect(shiftSchedule.startTime, contains('07:00'));
    });

    test('Kalkulasi jam kerja dan lembur dinamis sesuai jam kerja normal 8 jam', () {
      final normalSchedule = WorkScheduleModel(
        id: 1,
        name: 'Jam Kerja Normal',
        startTime: '08:00:00',
        endTime: '17:00:00',
        breakMinutes: 60,
        workingHours: 8.0,
      );

      // Skenario 1: Tepat waktu 08:00 sampai 17:00 (durasi 9 jam - 1 jam istirahat = 8 jam / 480 menit)
      final inTime1 = DateTime(2026, 9, 1, 8, 0);
      final outTime1 = DateTime(2026, 9, 1, 17, 0);
      final elapsed1 = outTime1.difference(inTime1).inMinutes;
      final workingMin1 = elapsed1 - normalSchedule.breakMinutes;
      final stdWorkingMin1 = (normalSchedule.workingHours * 60).round();
      final overtime1 = workingMin1 > stdWorkingMin1 ? workingMin1 - stdWorkingMin1 : 0;

      expect(workingMin1, 480);
      expect(overtime1, 0);

      // Skenario 2: Lembur 55 menit 08:05 sampai 18:00 (durasi 9 jam 55 menit - 1 jam istirahat = 535 menit)
      final inTime2 = DateTime(2026, 9, 1, 8, 5);
      final outTime2 = DateTime(2026, 9, 1, 18, 0);
      final elapsed2 = outTime2.difference(inTime2).inMinutes;
      final workingMin2 = elapsed2 - normalSchedule.breakMinutes;
      final overtime2 = workingMin2 > stdWorkingMin1 ? workingMin2 - stdWorkingMin1 : 0;

      expect(workingMin2, 535);
      expect(overtime2, 55);
    });

    test('Kalkulasi jam kerja dan lembur dinamis sesuai Shift Pagi 7 jam', () {
      final shiftSchedule = WorkScheduleModel(
        id: 2,
        name: 'Shift Pagi',
        startTime: '07:00:00',
        endTime: '15:00:00',
        breakMinutes: 60,
        workingHours: 7.0,
      );

      // Shift pagi: 07:00 sampai 15:00 (durasi 8 jam - 1 jam istirahat = 7 jam / 420 menit)
      final inTime = DateTime(2026, 9, 1, 7, 0);
      final outTime = DateTime(2026, 9, 1, 15, 0);
      final elapsed = outTime.difference(inTime).inMinutes;
      final workingMin = elapsed - shiftSchedule.breakMinutes;
      final stdWorkingMin = (shiftSchedule.workingHours * 60).round();
      final overtime = workingMin > stdWorkingMin ? workingMin - stdWorkingMin : 0;

      expect(workingMin, 420);
      expect(stdWorkingMin, 420);
      expect(overtime, 0);

      // Shift pagi lembur 1 jam sampai 16:00
      final outTimeOT = DateTime(2026, 9, 1, 16, 0);
      final elapsedOT = outTimeOT.difference(inTime).inMinutes;
      final workingMinOT = elapsedOT - shiftSchedule.breakMinutes;
      final overtimeOT = workingMinOT > stdWorkingMin ? workingMinOT - stdWorkingMin : 0;

      expect(workingMinOT, 480);
      expect(overtimeOT, 60);
    });
  });

  group('Modul 5: Manajemen Pekerjaan & Riwayat Progres (task_progress)', () {
    late TaskRepository taskRepo;

    setUp(() {
      TaskRepository.resetFallbackData();
      taskRepo = TaskRepository();
    });

    test('TaskProgressModel serialization & toMap roundtrip', () {
      final model = TaskProgressModel(
        id: 10,
        taskId: 1,
        taskTitle: 'Input data harian',
        employeeId: 3,
        employeeName: 'Citra Staff',
        employeeCode: 'EMP003',
        status: 'in_progress',
        progressPercentage: 65,
        notes: 'Selesai 65%',
        recordedAt: '2026-09-02 11:30:00',
      );

      final map = model.toMap();
      expect(map['task_id'], 1);
      expect(map['progress_percentage'], 65);
      expect(map['status'], 'in_progress');

      final fromMap = TaskProgressModel.fromMap(map);
      expect(fromMap.id, 10);
      expect(fromMap.progressPercentage, 65);
      expect(fromMap.statusLabel, 'Sedang Dikerjakan');
    });

    test('getTaskProgress mengembalikan daftar log timeline pekerjaan', () async {
      final list = await taskRepo.getTaskProgress(1);
      expect(list, isNotEmpty);
      expect(list.first.taskId, 1);
      expect(list.first.progressPercentage, anyOf(equals(50), equals(75), equals(90)));
      expect(list.first.notes, isNotEmpty);
    });

    test('addTaskProgress mencatat log baru dan memperbarui status task', () async {
      final ok = await taskRepo.addTaskProgress(
        taskId: 1,
        employeeId: 3,
        status: 'in_progress',
        progressPercentage: 75,
        notes: 'Merapikan tabel data',
        actualHours: 6.0,
      );
      expect(ok, isTrue);

      final progressList = await taskRepo.getTaskProgress(1);
      expect(progressList.first.progressPercentage, 75);
      expect(progressList.first.notes, 'Merapikan tabel data');

      final tasks = await taskRepo.getTasks();
      final task1 = tasks.firstWhere((t) => t.id == 1);
      expect(task1.progressPercentage, 75);
      expect(task1.latestNotes, 'Merapikan tabel data');
    });

    test('TaskController recordTaskProgress berfungsi secara terintegrasi', () async {
      final controller = TaskController();
      final user = UserModel(
        id: 3,
        employeeId: 3,
        employeeCode: 'EMP003',
        name: 'Citra Staff',
        email: 'citra@kerjakita.local',
        role: 'employee',
      );

      await controller.loadTasks(user);
      expect(controller.tasks, isNotEmpty);

      final success = await controller.recordTaskProgress(
        taskId: 1,
        employeeId: 3,
        status: 'review',
        progressPercentage: 90,
        notes: 'Siap direview atasan',
        currentUser: user,
      );
      expect(success, isTrue);

      final updatedTask = controller.tasks.firstWhere((t) => t.id == 1);
      expect(updatedTask.status, 'review');
      expect(updatedTask.progressPercentage, 90);
    });
  });
}

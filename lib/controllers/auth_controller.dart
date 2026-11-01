import 'package:flutter/material.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:kita_kerja/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool _isVerified = false;
  UserModel? _currentUser;
  bool _isLoading = false;

  bool get isVerified => _isVerified;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  bool get isAdmin => _currentUser == null || _currentUser!.isAdmin;
  bool get isManager => _currentUser != null && _currentUser!.isManager;
  bool get isEmployee => _currentUser != null && _currentUser!.isEmployee;

  String get initialRouteForRole {
    if (isEmployee) {
      return '/kehadiran';
    } else if (isManager) {
      return '/pekerjaan';
    } else {
      return '/dashboard';
    }
  }

  void loginSuccess(UserModel user) {
    _isVerified = true;
    _currentUser = user;
    notifyListeners();
  }

  Future<UserModel?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _repository.loginUser(email, password);
      if (user != null) {
        _isVerified = true;
        _currentUser = user;
      }
      return user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerOwner({
    required String namaUsaha,
    required String namaLengkap,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _repository.registerOwner(
        namaUsaha: namaUsaha,
        namaLengkap: namaLengkap,
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    return await _repository.getUsers();
  }

  void loginAsRole(String role) {
    _isVerified = true;
    if (role == 'manager' || role == 'supervisor') {
      _currentUser = UserModel(
        id: 2,
        employeeId: 2,
        employeeCode: 'EMP002',
        name: 'Budi Manager',
        email: 'manager@kerjakita.local',
        role: 'manager',
        departmentId: 1,
        departmentName: 'Operasional',
        phone: '081234567891',
      );
    } else if (role == 'employee' || role == 'karyawan' || role == 'staff') {
      _currentUser = UserModel(
        id: 3,
        employeeId: 3,
        employeeCode: 'EMP003',
        name: 'Citra Staff',
        email: 'citra@kerjakita.local',
        role: 'employee',
        departmentId: 1,
        departmentName: 'Operasional',
        phone: '081234567892',
      );
    } else {
      _currentUser = UserModel(
        id: 1,
        employeeId: 1,
        employeeCode: 'EMP001',
        name: 'Admin KerjaKita',
        email: 'admin@kerjakita.local',
        role: 'admin',
        departmentId: 1,
        departmentName: 'Operasional',
        phone: '081234567890',
      );
    }
    notifyListeners();
  }

  void logout() {
    _isVerified = false;
    _currentUser = null;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String email,
    String? phone,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        phone: phone,
      );
      notifyListeners();
    }
  }
}

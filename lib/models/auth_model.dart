import 'package:flutter/material.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // 'admin', 'manager', 'employee'
  final String? phone;
  final String status;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.status = 'active',
  });
}

class AuthModel extends ChangeNotifier {
  bool _isVerified = false;
  UserModel? _currentUser;

  bool get isVerified => _isVerified;
  UserModel? get currentUser => _currentUser;

  bool get isAdmin =>
      _currentUser == null ||
      _currentUser!.role.toLowerCase() == 'admin' ||
      _currentUser!.role.toLowerCase() == 'owner';

  bool get isManager =>
      _currentUser != null &&
      (_currentUser!.role.toLowerCase() == 'manager' ||
          _currentUser!.role.toLowerCase() == 'supervisor');

  bool get isEmployee =>
      _currentUser != null &&
      (_currentUser!.role.toLowerCase() == 'employee' ||
          _currentUser!.role.toLowerCase() == 'karyawan' ||
          _currentUser!.role.toLowerCase() == 'staff');

  /// Dynamic initial route depending on user role
  String get initialRouteForRole {
    if (isEmployee) {
      return '/kehadiran';
    } else if (isManager) {
      return '/pekerjaan';
    } else {
      return '/dashboard';
    }
  }

  // Default demo user (Admin / Owner Hendra Wijaya)
  void loginDemoUser({
    String role = 'admin',
    String name = 'Hendra Wijaya',
    String email = 'hendra@kerjakita.com',
  }) {
    _isVerified = true;
    _currentUser = UserModel(
      id: 1,
      name: name,
      email: email,
      role: role,
      phone: '081234567890',
    );
    notifyListeners();
  }

  // Login Demo Quick Role Switcher
  void loginAsRole(String role) {
    if (role == 'manager') {
      loginDemoUser(
        role: 'manager',
        name: 'Budi Santoso',
        email: 'budi.manager@kerjakita.com',
      );
    } else if (role == 'employee' || role == 'karyawan') {
      loginDemoUser(
        role: 'employee',
        name: 'Citra Staff',
        email: 'citra.staff@kerjakita.com',
      );
    } else {
      loginDemoUser(
        role: 'admin',
        name: 'Hendra Wijaya',
        email: 'hendra.admin@kerjakita.com',
      );
    }
  }

  void loginSuccess(UserModel user) {
    _isVerified = true;
    _currentUser = user;
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
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: name,
        email: email,
        role: _currentUser!.role,
        phone: phone,
        status: _currentUser!.status,
      );
      notifyListeners();
    }
  }
}


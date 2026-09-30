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

  // Default demo user (Admin / Owner Hendra Wijaya)
  void loginDemoUser({String role = 'admin', String name = 'Hendra Wijaya', String email = 'hendra@kerjakita.com'}) {
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

  void updateProfile({required String name, required String email, String? phone}) {
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


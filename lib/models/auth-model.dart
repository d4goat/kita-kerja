import 'package:flutter/material.dart';

class AuthModel extends ChangeNotifier {
  bool _isVerified = false;

  bool get isVerified {
    return _isVerified;
  }

  void loginSuccess() {
    _isVerified = true;
    notifyListeners();
  }
}

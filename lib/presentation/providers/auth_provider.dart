import 'package:flutter/material.dart';

// Simple Provider without Firebase for now
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userRole;
  
  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;

  void login(String role) {
    _isLoggedIn = true;
    _userRole = role;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userRole = null;
    notifyListeners();
  }
}

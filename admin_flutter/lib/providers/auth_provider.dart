import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;
  int? _userId;
  String? _username;
  String? _role;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  int? get userId => _userId;
  String? get username => _username;
  String? get role => _role;

  bool get isSuperAdmin => _role == 'SUPER_ADMIN';
  bool get isAdmin => _role == 'ADMIN';
  bool get isEmployee => _role == 'EMPLOYEE';

  Future<bool> checkLoginStatus() async {
    final hasToken = await TokenStorage.hasToken();
    if (hasToken) {
      _userId = await TokenStorage.getUserId();
      _username = await TokenStorage.getUsername();
      _role = await TokenStorage.getRole();
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.login(username, password);
      final token = data['token'] as String;
      final userId = data['userId'] as int;
      final uname = data['username'] as String;
      final role = data['role'] as String;

      await TokenStorage.saveLogin(token, userId, uname, role);

      _userId = userId;
      _username = uname;
      _role = role;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '用户名或密码错误';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    _isLoggedIn = false;
    _userId = null;
    _username = null;
    _role = null;
    notifyListeners();
  }
}
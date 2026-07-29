import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final _userService = UserService();

  List<User> _users = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 10;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> loadUsers({int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _userService.list(pageNum: page, pageSize: _pageSize);
      _users = (data['records'] as List).map((e) => User.fromJson(e)).toList();
      _totalPages = (data['pages'] ?? 1) as int;
      _currentPage = data['current'] ?? page;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createUser(User user) async {
    try {
      await _userService.create(user);
      await loadUsers(page: _currentPage);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateUser(int id, User user) async {
    try {
      await _userService.update(id, user);
      await loadUsers(page: _currentPage);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _userService.delete(id);
      await loadUsers(page: _currentPage);
      return true;
    } catch (_) {
      return false;
    }
  }
}
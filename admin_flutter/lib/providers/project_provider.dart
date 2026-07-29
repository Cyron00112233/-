import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/user.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  final _projectService = ProjectService();

  List<Project> _projects = [];
  List<User> _members = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  List<User> get members => _members;
  bool get isLoading => _isLoading;

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();
    try {
      _projects = await _projectService.list();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProject(Project project, {List<int>? memberIds}) async {
    try {
      await _projectService.create(project, memberIds: memberIds);
      await loadProjects();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProject(int id, Project project) async {
    try {
      await _projectService.update(id, project);
      await loadProjects();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProject(int id) async {
    try {
      await _projectService.delete(id);
      await loadProjects();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadMembers(int projectId) async {
    try {
      _members = await _projectService.getMembers(projectId);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> assignMembers(int projectId, List<int> memberIds) async {
    try {
      await _projectService.assignMembers(projectId, memberIds);
      await loadMembers(projectId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeMember(int projectId, int userId) async {
    try {
      await _projectService.removeMember(projectId, userId);
      await loadMembers(projectId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
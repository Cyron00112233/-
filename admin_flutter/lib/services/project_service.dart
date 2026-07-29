import '../models/project.dart';
import '../models/user.dart';
import 'api_service.dart';

class ProjectService {
  final _api = ApiService();

  Future<List<Project>> list({int pageNum = 1, int pageSize = 10}) async {
    final res = await _api.get('/api/projects', params: {
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    final list = res.data['data'] as List;
    return list.map((e) => Project.fromJson(e)).toList();
  }

  Future<List<Project>> myProjects({int pageNum = 1, int pageSize = 10}) async {
    final res = await _api.get('/api/projects/my', params: {
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    final list = res.data['data'] as List;
    return list.map((e) => Project.fromJson(e)).toList();
  }

  Future<void> create(Project project, {List<int>? memberIds}) async {
    await _api.post('/api/projects',
        data: project.toJson(),
        params: memberIds != null ? {'memberIds': memberIds.join(',')} : null);
  }

  Future<void> update(int id, Project project) async {
    await _api.put('/api/projects/$id', data: project.toJson());
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/projects/$id');
  }

  Future<List<User>> getMembers(int projectId) async {
    final res = await _api.get('/api/projects/$projectId/members');
    final list = res.data['data'] as List;
    return list.map((e) => User.fromJson(e)).toList();
  }

  Future<void> assignMembers(int projectId, List<int> memberIds) async {
    await _api.post('/api/projects/$projectId/members', data: memberIds);
  }

  Future<void> removeMember(int projectId, int userId) async {
    await _api.delete('/api/projects/$projectId/members/$userId');
  }
}
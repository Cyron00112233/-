import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final _api = ApiService();

  Future<Map<String, dynamic>> list({int pageNum = 1, int pageSize = 10}) async {
    final res = await _api.get('/api/users', params: {
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    return res.data['data'];
  }

  Future<User> getById(int id) async {
    final res = await _api.get('/api/users/$id');
    return User.fromJson(res.data['data']);
  }

  Future<void> create(User user) async {
    await _api.post('/api/users', data: user.toJson());
  }

  Future<void> update(int id, User user) async {
    await _api.put('/api/users/$id', data: user.toJson());
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/users/$id');
  }

  Future<void> changePassword(int id, String password) async {
    await _api.put('/api/users/$id/password', data: {'password': password});
  }
}
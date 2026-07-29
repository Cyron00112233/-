import 'api_service.dart';

class AuthService {
  final _api = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _api.post('/api/auth/login', data: {
      'username': username,
      'password': password,
    });
    return res.data['data'];
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _api.get('/api/auth/me');
    return res.data['data'];
  }
}
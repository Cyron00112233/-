class User {
  final int? id;
  final String username;
  final String? password;
  final String? realName;
  final String role;
  final String? createTime;
  final String? updateTime;

  User({
    this.id,
    required this.username,
    this.password,
    this.realName,
    required this.role,
    this.createTime,
    this.updateTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      password: json['password'],
      realName: json['realName'],
      role: json['role'] ?? 'EMPLOYEE',
      createTime: json['createTime'],
      updateTime: json['updateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'username': username,
      'password': password,
      'realName': realName,
      'role': role,
    };
    data.removeWhere((k, v) => v == null);
    return data;
  }

  String get roleLabel {
    switch (role) {
      case 'SUPER_ADMIN':
        return '超级管理员';
      case 'ADMIN':
        return '管理员';
      case 'EMPLOYEE':
        return '员工';
      default:
        return role;
    }
  }
}
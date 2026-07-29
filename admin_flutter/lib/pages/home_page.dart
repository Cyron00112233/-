import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sidebar.dart';
import 'user_management_page.dart';
import 'project_management_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _pages = <Widget>[];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _pages.add(const _DashboardPage());
    if (auth.isSuperAdmin || auth.isAdmin) {
      _pages.add(const UserManagementPage());
    }
    _pages.add(const ProjectManagementPage());
  }

  int _mapIndex(int raw) {
    final auth = context.read<AuthProvider>();
    if (auth.isEmployee) {
      // EMPLOYEE: 0=首页, 1=项目管理
      return raw == 1 ? 2 : raw;
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex.clamp(0, _pages.length - 1),
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('欢迎回来，${auth.username}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('当前角色：${_roleLabel(auth.role ?? '')}',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 40),
          Wrap(spacing: 20, runSpacing: 20, children: [
            _buildStatCard('用户数', '3+', Icons.people, const Color(0xFF1890FF)),
            _buildStatCard('项目数', '5+', Icons.folder, const Color(0xFF52C41A)),
            _buildStatCard('进行中', '2', Icons.rocket, const Color(0xFFFAAD14)),
          ]),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'SUPER_ADMIN': return '超级管理员';
      case 'ADMIN': return '管理员';
      case 'EMPLOYEE': return '员工';
      default: return role;
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Sidebar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final items = _buildItems(auth);

    return Container(
      width: 220,
      color: const Color(0xFF001529),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text('权限中台',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(color: Color(0xFF0D2137), height: 1),
          const SizedBox(height: 12),
          ...items.map((item) => _buildMenuItem(context, item)),
          const Spacer(),
          const Divider(color: Color(0xFF0D2137), height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white54),
            title: const Text('退出登录', style: TextStyle(color: Colors.white54, fontSize: 14)),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const _Dummy()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<_MenuItem> _buildItems(AuthProvider auth) {
    final items = <_MenuItem>[];
    items.add(_MenuItem(icon: Icons.dashboard, label: '首页', index: 0));

    if (auth.isSuperAdmin || auth.isAdmin) {
      items.add(_MenuItem(icon: Icons.people, label: '用户管理', index: 1));
    }
    items.add(_MenuItem(icon: Icons.folder, label: '项目管理', index: 2));

    return items;
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    final isSelected = selectedIndex == item.index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? const Color(0xFF1890FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onTap(item.index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(item.icon, size: 20,
                    color: isSelected ? Colors.white : Colors.white54),
                const SizedBox(width: 12),
                Text(item.label,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final int index;
  _MenuItem({required this.icon, required this.label, required this.index});
}

class _Dummy extends StatelessWidget {
  const _Dummy();
  @override
  Widget build(BuildContext context) => const Scaffold();
}
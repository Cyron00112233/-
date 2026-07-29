import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/user_dialog.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<UserProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('用户管理', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (auth.isSuperAdmin)
                ElevatedButton.icon(
                  onPressed: () => _showUserDialog(context, null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新增用户'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1890FF),
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTable(context, provider),
          ),
          if (provider.totalPages > 1) _buildPagination(provider),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, UserProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('用户名')),
            DataColumn(label: Text('姓名')),
            DataColumn(label: Text('角色')),
            DataColumn(label: Text('创建时间')),
            DataColumn(label: Text('操作')),
          ],
          rows: provider.users.map((user) {
            return DataRow(cells: [
              DataCell(Text('${user.id}')),
              DataCell(Text(user.username)),
              DataCell(Text(user.realName ?? '-')),
              DataCell(_roleTag(user.role)),
              DataCell(Text(user.createTime ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (context.read<AuthProvider>().isSuperAdmin) ...[
                    TextButton(
                      onPressed: () => _showUserDialog(context, user),
                      child: const Text('编辑', style: TextStyle(fontSize: 13)),
                    ),
                    TextButton(
                      onPressed: () => _confirmDelete(context, user),
                      child: const Text('删除', style: TextStyle(fontSize: 13, color: Colors.red)),
                    ),
                  ],
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _roleTag(String role) {
    Color color;
    switch (role) {
      case 'SUPER_ADMIN': color = const Color(0xFFF5222D); break;
      case 'ADMIN': color = const Color(0xFF1890FF); break;
      default: color = const Color(0xFF52C41A);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(User(role: role, username: '').roleLabel,
          style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildPagination(UserProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: provider.currentPage > 1
                ? () => provider.loadUsers(page: provider.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('${provider.currentPage} / ${provider.totalPages}'),
          IconButton(
            onPressed: provider.currentPage < provider.totalPages
                ? () => provider.loadUsers(page: provider.currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _showUserDialog(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (_) => UserDialog(user: user),
    );
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除用户 "${user.username}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserProvider>().deleteUser(user.id!);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
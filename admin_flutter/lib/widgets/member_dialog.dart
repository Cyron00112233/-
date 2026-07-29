import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/project_provider.dart';
import '../services/user_service.dart';

class MemberDialog extends StatefulWidget {
  final int projectId;
  const MemberDialog({super.key, required this.projectId});

  @override
  State<MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends State<MemberDialog> {
  final _userService = UserService();
  List<User> _allUsers = [];
  final Set<int> _selectedIds = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await _userService.list(pageNum: 1, pageSize: 100);
      _allUsers = (data['records'] as List).map((e) => User.fromJson(e)).toList();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final ok = await context
        .read<ProjectProvider>()
        .assignMembers(widget.projectId, _selectedIds.toList());
    if (ok && mounted) {
      Navigator.pop(context);
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('分配人员'),
      content: SizedBox(
        width: 350,
        height: 350,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _allUsers.isEmpty
                ? const Center(child: Text('暂无用户数据'))
                : ListView.builder(
                    itemCount: _allUsers.length,
                    itemBuilder: (_, i) {
                      final user = _allUsers[i];
                      return CheckboxListTile(
                        title: Text(user.username),
                        subtitle: Text('${user.realName ?? '-'}  ·  ${user.roleLabel}'),
                        value: _selectedIds.contains(user.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedIds.add(user.id!);
                            } else {
                              _selectedIds.remove(user.id!);
                            }
                          });
                        },
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1890FF), foregroundColor: Colors.white),
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('确定'),
        ),
      ],
    );
  }
}
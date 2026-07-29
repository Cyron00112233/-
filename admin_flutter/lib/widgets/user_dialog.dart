import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class UserDialog extends StatefulWidget {
  final User? user;
  const UserDialog({super.key, this.user});

  @override
  State<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _realNameCtrl;
  late final TextEditingController _passwordCtrl;
  String _role = 'EMPLOYEE';
  bool _isLoading = false;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user?.username ?? '');
    _realNameCtrl = TextEditingController(text: widget.user?.realName ?? '');
    _passwordCtrl = TextEditingController();
    if (widget.user != null) {
      _role = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _realNameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = User(
      username: _usernameCtrl.text.trim(),
      realName: _realNameCtrl.text.trim().isEmpty ? null : _realNameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      role: _role,
    );

    bool ok;
    if (_isEdit) {
      ok = await context.read<UserProvider>().updateUser(widget.user!.id!, user);
    } else {
      ok = await context.read<UserProvider>().createUser(user);
    }

    if (ok && mounted) {
      Navigator.pop(context);
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? '编辑用户' : '新增用户'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: '用户名', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? '请输入用户名' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _realNameCtrl,
                decoration: const InputDecoration(labelText: '真实姓名', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _isEdit ? '新密码（不填则不修改）' : '密码',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => !_isEdit && (v == null || v.trim().isEmpty) ? '请输入密码' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: '角色', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('超级管理员')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('管理员')),
                  DropdownMenuItem(value: 'EMPLOYEE', child: Text('员工')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1890FF), foregroundColor: Colors.white),
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('保存'),
        ),
      ],
    );
  }
}
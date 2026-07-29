import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';

class ProjectDialog extends StatefulWidget {
  final Project? project;
  const ProjectDialog({super.key, this.project});

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  String _status = '进行中';
  bool _isLoading = false;

  bool get _isEdit => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.project?.name ?? '');
    _descCtrl = TextEditingController(text: widget.project?.description ?? '');
    if (widget.project?.status != null) {
      _status = widget.project!.status!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final project = Project(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      status: _status,
    );

    bool ok;
    if (_isEdit) {
      ok = await context.read<ProjectProvider>().updateProject(widget.project!.id!, project);
    } else {
      ok = await context.read<ProjectProvider>().createProject(project);
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
      title: Text(_isEdit ? '编辑项目' : '新增项目'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '项目名称', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? '请输入项目名称' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '项目描述', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: '状态', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: '进行中', child: Text('进行中')),
                  DropdownMenuItem(value: '已完成', child: Text('已完成')),
                  DropdownMenuItem(value: '已暂停', child: Text('已暂停')),
                ],
                onChanged: (v) => setState(() => _status = v!),
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/member_dialog.dart';

class ProjectMemberPage extends StatefulWidget {
  final Project project;
  const ProjectMemberPage({super.key, required this.project});

  @override
  State<ProjectMemberPage> createState() => _ProjectMemberPageState();
}

class _ProjectMemberPageState extends State<ProjectMemberPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<ProjectProvider>().loadMembers(widget.project.id!));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} - 项目人员'),
        backgroundColor: const Color(0xFF1890FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('成员列表', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (!auth.isEmployee)
                  ElevatedButton.icon(
                    onPressed: () => _showAssignDialog(context),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('分配人员'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1890FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: ListView.builder(
                  itemCount: provider.members.length,
                  itemBuilder: (_, i) {
                    final member = provider.members[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1890FF),
                        child: Text(member.username[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(member.username),
                      subtitle: Text('${member.realName ?? '-'}  ·  ${member.roleLabel}'),
                      trailing: !auth.isEmployee
                          ? IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _confirmRemove(member.id!),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => MemberDialog(projectId: widget.project.id!),
    );
  }

  void _confirmRemove(int userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认移除'),
        content: const Text('确定要移除该成员吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProjectProvider>().removeMember(widget.project.id!, userId);
            },
            child: const Text('移除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
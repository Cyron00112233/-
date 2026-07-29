import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/project_dialog.dart';
import 'project_member_page.dart';

class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({super.key});

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProjectProvider>().loadProjects());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ProjectProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('项目管理', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (!auth.isEmployee)
                ElevatedButton.icon(
                  onPressed: () => _showProjectDialog(context, null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新增项目'),
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
                : _buildTable(context, auth, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, AuthProvider auth, ProjectProvider provider) {
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
            DataColumn(label: Text('项目名称')),
            DataColumn(label: Text('描述')),
            DataColumn(label: Text('状态')),
            DataColumn(label: Text('创建时间')),
            DataColumn(label: Text('操作')),
          ],
          rows: provider.projects.map((project) {
            return DataRow(cells: [
              DataCell(Text('${project.id}')),
              DataCell(Text(project.name, style: const TextStyle(fontWeight: FontWeight.w500))),
              DataCell(Text(project.description ?? '-',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13))),
              DataCell(_statusTag(project.status ?? '进行中')),
              DataCell(Text(project.createTime ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProjectMemberPage(project: project))),
                    child: const Text('人员', style: TextStyle(fontSize: 13)),
                  ),
                  if (!auth.isEmployee) ...[
                    TextButton(
                      onPressed: () => _showProjectDialog(context, project),
                      child: const Text('编辑', style: TextStyle(fontSize: 13)),
                    ),
                    if (auth.isSuperAdmin)
                      TextButton(
                        onPressed: () => _confirmDelete(context, project),
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

  Widget _statusTag(String status) {
    Color color = status == '已完成' ? const Color(0xFF52C41A) : const Color(0xFF1890FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  void _showProjectDialog(BuildContext context, Project? project) {
    showDialog(
      context: context,
      builder: (_) => ProjectDialog(project: project),
    );
  }

  void _confirmDelete(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除项目 "${project.name}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProjectProvider>().deleteProject(project.id!);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
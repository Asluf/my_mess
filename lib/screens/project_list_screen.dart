import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../widgets/empty_state.dart';
import 'mess_project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProjectProvider>().loadProjects();
    });
  }

  void _showAddProjectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Room Expenses',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<ProjectProvider>().addProject(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int projectId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Delete "$name" and all its data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ProjectProvider>().deleteProject(projectId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _refreshProjects() {
    context.read<ProjectProvider>().loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? theme.colorScheme.secondary : theme.primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Mess',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.projects.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _refreshProjects(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: EmptyState(
                    icon: Icons.group_work_outlined,
                    title: 'No Projects Yet',
                    subtitle:
                        'Create a project to start tracking shared expenses',
                    buttonLabel: 'Create Project',
                    onButtonPressed: _showAddProjectDialog,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshProjects(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: provider.projects.length + 1,
              itemBuilder: (context, index) {
                // Show "Made by" footer at the end
                if (index == provider.projects.length) {
                  final theme = Theme.of(context);
                  final bodySmall = theme.textTheme.bodySmall;
                  final secondaryTextColor = bodySmall?.color?.withOpacity(0.7);
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.heart_fill,
                          size: 16,
                          color: Colors.red[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Made by',
                          style: bodySmall?.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Asluf',
                          style: bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFA726),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final project = provider.projects[index];
                final memberCount = provider.memberCountFor(project.id!);
                final total = provider.totalExpensesFor(project.id!);
                final dateStr =
                    DateFormat('MMM dd, yyyy').format(project.createdAt);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MessProjectDetailScreen(project: project),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: accent,
                                child: const Icon(Icons.group,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(dateStr,
                                        style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _confirmDelete(project.id!, project.name);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline,
                                            color: Colors.red, size: 20),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.people_outline,
                                  size: 16, color: theme.iconTheme.color),
                              const SizedBox(width: 4),
                              Text('$memberCount members',
                                  style: theme.textTheme.bodySmall),
                              const Spacer(),
                              Icon(Icons.receipt_long_outlined,
                                  size: 16, color: theme.iconTheme.color),
                              const SizedBox(width: 4),
                              Text(
                                '${total.toStringAsFixed(2)} AED',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

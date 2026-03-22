import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_mess/services/databaseHelper.dart';
import 'package:my_mess/models/project.dart';
import 'package:my_mess/screens/AddProjectScreen.dart';
import 'package:my_mess/screens/ProjectDetailScreen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshProjects();
  }

  void _refreshProjects() async {
    setState(() {
      _isLoading = true;
    });

    final projects = await DatabaseHelper.instance.getAllProjects();
    setState(() {
      _projects = projects;
      _isLoading = false;
    });
  }

  void _deleteProject(int id) async {
    await DatabaseHelper.instance.deleteProject(id);
    _refreshProjects();
  }

  void _createProject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProjectScreen()),
    );
    _refreshProjects();
  }

  void _navigateToProject(Project project) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );
    _refreshProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyBusinessTracker'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _projects.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Projects',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFA726),
                              ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _projects.length,
                          itemBuilder: (context, index) {
                            return _buildProjectCard(_projects[index]);
                          },
                        ),
                        const SizedBox(height: 32),
                        _buildFooter(),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProject,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.folder,
                  size: 80,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Projects Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first project to start tracking\nyour business finances',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _createProject,
                  icon: const Icon(CupertinoIcons.add),
                  label: const Text('Create Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildProjectCard(Project project) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper.instance.getProjectSummary(project.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Loading...'),
            ),
          );
        }

        final summary = snapshot.data!;
        final totalIncome = summary['totalIncome'] as double;
        final totalExpense = summary['totalExpense'] as double;
        final profit = summary['profit'] as double;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToProject(project),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (project.description != null &&
                                project.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  project.description!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.7),
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteDialog(project);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Project'),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(CupertinoIcons.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Income',
                          totalIncome,
                          CupertinoIcons.arrow_up_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryItem(
                          'Expense',
                          totalExpense,
                          CupertinoIcons.arrow_down_circle,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: profit >= 0 ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            profit >= 0 ? Colors.green[200]! : Colors.red[200]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          profit >= 0
                              ? CupertinoIcons.arrow_up
                              : CupertinoIcons.arrow_down,
                          color: profit >= 0 ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${profit >= 0 ? 'Profit' : 'Loss'}: ${NumberFormat.currency(symbol: 'Rs ').format(profit.abs())}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: profit >= 0
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
      String label, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            NumberFormat.currency(symbol: 'Rs ').format(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
            'Are you sure you want to delete "${project.name}"? This will also delete all associated expenses and incomes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProject(project.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 16),
          Row(
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                'Asluf',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFA726),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

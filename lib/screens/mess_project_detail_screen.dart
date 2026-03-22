import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mess_project.dart';
import '../models/member.dart';
import '../providers/project_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/member_avatar.dart';
import 'add_member_screen.dart';
import 'add_mess_expense_screen.dart';
import 'summary_screen.dart';

class MessProjectDetailScreen extends StatefulWidget {
  final MessProject project;

  const MessProjectDetailScreen({super.key, required this.project});

  @override
  State<MessProjectDetailScreen> createState() =>
      _MessProjectDetailScreenState();
}

class _MessProjectDetailScreenState extends State<MessProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    final projectId = widget.project.id!;
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProjectProvider>().loadMembers(projectId);
      context.read<ExpenseProvider>().loadExpenses(projectId);
    });
  }

  void _openAddMember() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemberScreen(projectId: widget.project.id!),
      ),
    );
  }

  void _openEditMember(Member member) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemberScreen(
          projectId: widget.project.id!,
          member: member,
        ),
      ),
    );
  }

  void _openAddExpense() async {
    final members = context.read<ProjectProvider>().members;
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one member first')),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMessExpenseScreen(
          projectId: widget.project.id!,
          members: members,
        ),
      ),
    );
  }

  void _openSummary() {
    final members = context.read<ProjectProvider>().members;
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add members and expenses first')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          project: widget.project,
          members: members,
        ),
      ),
    );
  }

  void _confirmDeleteMember(Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
            'Remove "${member.name}"? Their expenses will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context
                  .read<ProjectProvider>()
                  .deleteMember(widget.project.id!, member.id!);
              context
                  .read<ExpenseProvider>()
                  .loadExpenses(widget.project.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExpense(int expenseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context
                  .read<ExpenseProvider>()
                  .deleteExpense(expenseId, widget.project.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Summary',
            onPressed: _openSummary,
          ),
        ],
      ),
      body: Consumer2<ProjectProvider, ExpenseProvider>(
        builder: (context, projectProv, expenseProv, _) {
          final members = projectProv.members;
          final expenses = expenseProv.expenses;
          final total = expenseProv.totalSpent;
          final memberMap = {for (final m in members) m.id!: m};

          return CustomScrollView(
            slivers: [
              // ── Total Spent Banner ──
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withAlpha(200),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Spent',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${total.toStringAsFixed(2)} AED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${members.length} members  •  ${expenses.length} expenses',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Members Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Members',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _openAddMember,
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
              ),

              if (members.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No members yet. Add someone!'),
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return GestureDetector(
                          onTap: () => _openEditMember(member),
                          onLongPress: () => _confirmDeleteMember(member),
                          child: Container(
                            width: 72,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                MemberAvatar(member: member, radius: 24),
                                const SizedBox(height: 6),
                                Text(
                                  member.name,
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // ── Expenses Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Expenses',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _openAddExpense,
                        icon: const Icon(Icons.add_card_outlined, size: 18),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
              ),

              if (expenses.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Expenses Yet',
                    subtitle: 'Tap + to add the first expense',
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = expenses[index];
                      return ExpenseCard(
                        expense: expense,
                        paidByMember: memberMap[expense.paidBy],
                        onDelete: () => _confirmDeleteExpense(expense.id!),
                      );
                    },
                    childCount: expenses.length,
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpense,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

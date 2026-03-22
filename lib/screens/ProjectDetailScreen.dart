import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_mess/models/project.dart';
import 'package:my_mess/models/expense.dart';
import 'package:my_mess/models/income.dart';
import 'package:my_mess/services/databaseHelper.dart';
import 'package:my_mess/screens/AddExpenseScreen.dart';
import 'package:my_mess/screens/AddIncomeScreen.dart';
import 'package:intl/intl.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await DatabaseHelper.instance
          .getExpensesByProject(widget.project.id!);
      final incomes =
          await DatabaseHelper.instance.getIncomesByProject(widget.project.id!);
      final summary =
          await DatabaseHelper.instance.getProjectSummary(widget.project.id!);

      setState(() {
        _expenses = expenses;
        _incomes = incomes;
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(projectId: widget.project.id!),
      ),
    );
    _loadData();
  }

  void _addIncome() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIncomeScreen(projectId: widget.project.id!),
      ),
    );
    _loadData();
  }

  void _deleteExpense(Expense expense) async {
    await DatabaseHelper.instance.deleteExpense(expense.id!);
    _loadData();
  }

  void _deleteIncome(Income income) async {
    await DatabaseHelper.instance.deleteIncome(income.id!);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(CupertinoIcons.arrow_down_circle),
              text: 'Expenses',
            ),
            Tab(
              icon: Icon(CupertinoIcons.arrow_up_circle),
              text: 'Incomes',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryCard(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpensesTab(),
                  _buildIncomesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tabController.index == 0 ? _addExpense : _addIncome,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          _tabController.index == 0
              ? CupertinoIcons.minus_circle
              : CupertinoIcons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final totalIncome = _summary['totalIncome'] as double;
    final totalExpense = _summary['totalExpense'] as double;
    final profit = _summary['profit'] as double;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.chart_bar,
                  color: Color(0xFFFFA726),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Project Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFA726),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Income',
                    totalIncome,
                    CupertinoIcons.arrow_up_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Expense',
                    totalExpense,
                    CupertinoIcons.arrow_down_circle,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: profit >= 0 ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: profit >= 0 ? Colors.green[200]! : Colors.red[200]!,
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
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${profit >= 0 ? 'Profit' : 'Loss'}: ${NumberFormat.currency(symbol: 'Rs ').format(profit.abs())}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: profit >= 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildExpensesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_expenses.isEmpty) {
      return _buildEmptyState(
        CupertinoIcons.arrow_down_circle,
        'No Expenses Yet',
        'Add your first expense to start tracking project costs',
        _addExpense,
        'Add Expense',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            _expenses.map((expense) => _buildExpenseCard(expense)).toList(),
      ),
    );
  }

  Widget _buildIncomesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_incomes.isEmpty) {
      return _buildEmptyState(
        CupertinoIcons.arrow_up_circle,
        'No Incomes Yet',
        'Add your first income to start tracking project revenue',
        _addIncome,
        'Add Income',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _incomes.map((income) => _buildIncomeCard(income)).toList(),
      ),
    );
  }

  Widget _buildEmptyState(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onPressed,
    String buttonText,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
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
              subtitle,
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
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            CupertinoIcons.arrow_down_circle,
            color: Colors.red[600],
            size: 20,
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense.description != null && expense.description!.isNotEmpty)
              Text(expense.description!),
            Text(
              DateFormat('MMM dd, yyyy').format(DateTime.parse(expense.date)),
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormat.currency(symbol: 'Rs ').format(expense.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(
                    'Delete Expense',
                    'Are you sure you want to delete this expense?',
                    () => _deleteExpense(expense),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              child: const Icon(CupertinoIcons.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard(Income income) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            CupertinoIcons.arrow_up_circle,
            color: Colors.green[600],
            size: 20,
          ),
        ),
        title: Text(
          income.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (income.description != null && income.description!.isNotEmpty)
              Text(income.description!),
            Text(
              DateFormat('MMM dd, yyyy').format(DateTime.parse(income.date)),
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormat.currency(symbol: 'Rs ').format(income.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(
                    'Delete Income',
                    'Are you sure you want to delete this income?',
                    () => _deleteIncome(income),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              child: const Icon(CupertinoIcons.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

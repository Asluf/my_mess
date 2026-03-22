import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../models/mess_expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/member_avatar.dart';

class AddMessExpenseScreen extends StatefulWidget {
  final int projectId;
  final List<Member> members;

  const AddMessExpenseScreen({
    super.key,
    required this.projectId,
    required this.members,
  });

  @override
  State<AddMessExpenseScreen> createState() => _AddMessExpenseScreenState();
}

class _AddMessExpenseScreenState extends State<AddMessExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  late int _selectedMemberId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedMemberId = widget.members.first.id!;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = MessExpense(
      projectId: widget.projectId,
      paidBy: _selectedMemberId,
      amount: double.parse(_amountController.text.trim()),
      description: _descController.text.trim(),
      date: _selectedDate,
    );

    await context.read<ExpenseProvider>().addExpense(expense);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? theme.colorScheme.secondary : theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Paid By selector
              Text('Paid By',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.members.length,
                  itemBuilder: (context, index) {
                    final member = widget.members[index];
                    final isSelected = member.id == _selectedMemberId;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedMemberId = member.id!),
                      child: Container(
                        width: 72,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: accent, width: 2)
                              : Border.all(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.transparent,
                                ),
                          color: isSelected
                              ? accent.withAlpha(isDark ? 50 : 26)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MemberAvatar(member: member, radius: 20),
                            const SizedBox(height: 4),
                            Text(
                              member.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
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

              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (AED)',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter an amount';
                  final amount = double.tryParse(v.trim());
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Groceries',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a description'
                    : null,
              ),

              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Split info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withAlpha(isDark ? 40 : 30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accent.withAlpha(isDark ? 80 : 60),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Split equally among ${widget.members.length} members',
                        style: TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Expense',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

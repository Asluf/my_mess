import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mess_expense.dart';
import '../models/member.dart';

class ExpenseCard extends StatelessWidget {
  final MessExpense expense;
  final Member? paidByMember;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.paidByMember,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM dd, yyyy').format(expense.date);
    final paidByName = paidByMember?.name ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor:
              paidByMember?.avatarColor ?? theme.colorScheme.primary,
          child: Text(
            paidByMember?.initial ?? '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$paidByName  •  $dateStr',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${expense.amount.toStringAsFixed(2)} AED',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: theme.colorScheme.primary,
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                color: Colors.red.shade300,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

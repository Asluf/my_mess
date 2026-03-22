import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/member_balance.dart';

class BalanceCard extends StatelessWidget {
  final MemberBalance balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = balance.balance >= 0;
    final balanceColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;
    final balanceIcon = isPositive ? Icons.arrow_downward : Icons.arrow_upward;
    final balanceLabel =
        isPositive ? 'should receive' : 'should pay';
    final avatarColor =
        Member.avatarColors[balance.colorIndex % Member.avatarColors.length];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColor,
                  child: Text(
                    balance.memberName.isNotEmpty
                        ? balance.memberName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    balance.memberName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(balanceIcon, color: balanceColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${balance.balance.abs().toStringAsFixed(2)} AED',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: balanceColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _stat(theme, 'Paid', balance.paid),
                const SizedBox(width: 24),
                _stat(theme, 'Share', balance.share),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: balanceColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    balanceLabel,
                    style: TextStyle(
                      color: balanceColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(ThemeData theme, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        Text(
          '${value.toStringAsFixed(2)} AED',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}

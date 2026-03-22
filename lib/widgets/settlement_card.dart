import 'package:flutter/material.dart';
import '../models/member_balance.dart';

class SettlementCard extends StatelessWidget {
  final Settlement settlement;

  const SettlementCard({super.key, required this.settlement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.red.shade100,
              child: Text(
                settlement.fromName[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settlement.fromName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Text('pays ', style: theme.textTheme.bodySmall),
                      Text(
                        settlement.toName,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green.shade100,
              child: Text(
                settlement.toName[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${settlement.amount.toStringAsFixed(2)} AED',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

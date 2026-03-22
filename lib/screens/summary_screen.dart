import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mess_project.dart';
import '../models/member.dart';
import '../providers/expense_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/settlement_card.dart';

class SummaryScreen extends StatelessWidget {
  final MessProject project;
  final List<Member> members;

  const SummaryScreen({
    super.key,
    required this.project,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Summary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProv, _) {
          final balances = expenseProv.getBalances(members);
          final settlements = expenseProv.getSettlements(members);
          final total = expenseProv.totalSpent;

          return CustomScrollView(
            slivers: [
              // ── Total Banner ──
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
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
                      Text(
                        project.name,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Total Spent',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${total.toStringAsFixed(2)} AED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Each share: ${members.isNotEmpty ? (total / members.length).toStringAsFixed(2) : "0.00"} AED',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Balances Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Member Balances',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // ── Balance Cards ──
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => BalanceCard(balance: balances[index]),
                  childCount: balances.length,
                ),
              ),

              // ── Settlements Header ──
              if (settlements.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Who Pays Whom',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // ── Settlement Cards ──
              if (settlements.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        SettlementCard(settlement: settlements[index]),
                    childCount: settlements.length,
                  ),
                ),

              if (settlements.isEmpty && balances.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 48,
                              color: Colors.green.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'All settled up!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
    );
  }
}

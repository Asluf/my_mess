import 'dart:math';
import '../models/member.dart';
import '../models/mess_expense.dart';
import '../models/member_balance.dart';

class CalculationService {
  static double calculateTotalExpenses(List<MessExpense> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  static double calculateMemberPaid(
      List<MessExpense> expenses, int memberId) {
    return expenses
        .where((e) => e.paidBy == memberId)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  static double calculateMemberShare(
      double totalExpenses, int memberCount) {
    if (memberCount == 0) return 0;
    return totalExpenses / memberCount;
  }

  static List<MemberBalance> calculateBalances(
      List<Member> members, List<MessExpense> expenses) {
    if (members.isEmpty) return [];

    final total = calculateTotalExpenses(expenses);
    final share = calculateMemberShare(total, members.length);

    return members.map((m) {
      final paid = calculateMemberPaid(expenses, m.id!);
      return MemberBalance(
        memberId: m.id!,
        memberName: m.name,
        colorIndex: m.colorIndex,
        paid: paid,
        share: share,
        balance: paid - share,
      );
    }).toList();
  }

  /// Greedy algorithm to minimize the number of transactions.
  static List<Settlement> calculateSettlements(List<MemberBalance> balances) {
    final debtors = <_Entry>[];
    final creditors = <_Entry>[];

    for (final b in balances) {
      if (b.balance < -0.01) {
        debtors.add(_Entry(b.memberId, b.memberName, -b.balance));
      } else if (b.balance > 0.01) {
        creditors.add(_Entry(b.memberId, b.memberName, b.balance));
      }
    }

    debtors.sort((a, b) => b.amount.compareTo(a.amount));
    creditors.sort((a, b) => b.amount.compareTo(a.amount));

    final settlements = <Settlement>[];
    int i = 0, j = 0;

    while (i < debtors.length && j < creditors.length) {
      final amount = min(debtors[i].amount, creditors[j].amount);
      settlements.add(Settlement(
        fromId: debtors[i].id,
        fromName: debtors[i].name,
        toId: creditors[j].id,
        toName: creditors[j].name,
        amount: double.parse(amount.toStringAsFixed(2)),
      ));
      debtors[i].amount -= amount;
      creditors[j].amount -= amount;
      if (debtors[i].amount < 0.01) i++;
      if (creditors[j].amount < 0.01) j++;
    }

    return settlements;
  }
}

class _Entry {
  final int id;
  final String name;
  double amount;
  _Entry(this.id, this.name, this.amount);
}

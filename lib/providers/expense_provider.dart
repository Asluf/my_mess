import 'package:flutter/material.dart';
import '../models/mess_expense.dart';
import '../models/member.dart';
import '../models/member_balance.dart';
import '../services/mess_database_service.dart';
import '../services/calculation_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final _db = MessDatabaseService.instance;

  List<MessExpense> _expenses = [];
  List<MessExpense> get expenses => _expenses;

  double _totalSpent = 0;
  double get totalSpent => _totalSpent;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loadExpenses(int projectId) async {
    _loading = true;
    notifyListeners();

    _expenses = await _db.getExpenses(projectId);
    _totalSpent = CalculationService.calculateTotalExpenses(_expenses);

    _loading = false;
    notifyListeners();
  }

  Future<void> addExpense(MessExpense expense) async {
    await _db.insertExpense(expense);
    await loadExpenses(expense.projectId);
  }

  Future<void> deleteExpense(int id, int projectId) async {
    await _db.deleteExpense(id);
    await loadExpenses(projectId);
  }

  List<MemberBalance> getBalances(List<Member> members) {
    return CalculationService.calculateBalances(members, _expenses);
  }

  List<Settlement> getSettlements(List<Member> members) {
    final balances = getBalances(members);
    return CalculationService.calculateSettlements(balances);
  }
}

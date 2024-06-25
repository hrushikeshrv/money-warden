import 'package:money_warden/models/transaction.dart';

class BudgetMonth {
  final String name;
  List<Transaction> expenses = [];
  List<Transaction> income = [];

  BudgetMonth({ required this.name });

  /// Returns the amount of expenses this month
  double getMonthExpenseAmount() {
    double expenses = 0;
    for (var txn in this.expenses) {
      expenses += txn.amount;
    }
    return expenses;
  }

  // Returns the amount of income for this month
  double getMonthIncomeAmount() {
    double income = 0;
    for (var txn in this.income) {
      income += txn.amount;
    }
    return income;
  }

  /// Returns the difference between this month's income
  /// and expenses
  double getMonthDifference() {
    return getMonthExpenseAmount() - getMonthIncomeAmount();
  }
}
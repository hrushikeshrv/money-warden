import 'package:money_warden/models/transaction.dart';

/// Global state for a single month's sheet in the chosen budget
/// spreadsheet.
class BudgetMonth {
  final String name;
  List<Transaction> expenses = [];
  List<Transaction> income = [];

  BudgetMonth({ required this.name });

  /// Returns the amount of expenses this month
  double get monthExpenseAmount {
    double expenses = 0;
    for (var txn in this.expenses) {
      expenses += txn.amount;
    }
    return expenses;
  }

  // Returns the amount of income for this month
  double get monthIncomeAmount {
    double income = 0;
    for (var txn in this.income) {
      income += txn.amount;
    }
    return income;
  }

  /// Returns the difference between this month's income
  /// and expenses
  double get monthDifferenceAmount {
    return monthIncomeAmount - monthExpenseAmount;
  }

  /// Returns the percentage of this month's income
  /// spent
  double get percentIncomeSpent {
    if (monthIncomeAmount == 0) return 0;
    return double.parse(((monthExpenseAmount * 100) / monthIncomeAmount).toStringAsFixed(1));
  }

  /// Returns up to the 7 most recent transactions in descending order
  /// of their date. Includes both expenses and incomes.
  List<Transaction> get recentTransactions {
    int nRecentTransactions = 7;
    int expenseIdx = 0;
    int incomeIdx = 0;
    List<Transaction> transactions = [];

    for (int i = 0; i < nRecentTransactions; i++) {
      if (expenseIdx < expenses.length && incomeIdx < income.length) {
        if (expenses[expenseIdx].time.isAfter(income[incomeIdx].time)) {
          transactions.add(expenses[expenseIdx]);
          expenseIdx++;
        }
        else {
          transactions.add(income[incomeIdx]);
          incomeIdx++;
        }
      }
      else if (expenseIdx < expenses.length) {
        transactions.add(expenses[expenseIdx]);
        expenseIdx++;
      }
      else if (incomeIdx < income.length) {
        transactions.add(income[incomeIdx]);
        incomeIdx++;
      }
    }
    return transactions;
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:money_warden/utils.dart';
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
    return getOrderedTransactions(7);
  }

  List<Transaction> get orderedTransactions {
    return getOrderedTransactions(null);
  }

  /// Returns up to maxTransactions transactions in descending order
  /// of their date. Includes both expenses and incomes
  List<Transaction> getOrderedTransactions(int? maxTransactions) {
    // TODO: add tests
    List<Transaction> transactions = [];
    int expenseIdx = 0;
    int incomeIdx = 0;
    while (true) {
      if (maxTransactions != null && expenseIdx + incomeIdx >= maxTransactions) {
        break;
      }
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
      else {
        break;
      }
    }
    return transactions;
  }

  /// Returns a map mapping a category name to information
  /// about expenses in that category in this month.
  ///
  /// Example format -
  /// ```
  /// {
  ///   'Category 1': {
  ///     'name': 'Category 1',
  ///     'amount': 200.0,
  ///     'backgroundColor': Color(0xFFABCDEF)
  ///   },
  ///   ...
  /// }
  /// ```
  Map<String, Map<String, dynamic>> getExpensesByCategory() {
    // TODO: add tests
    Map<String, Map<String, dynamic>> data = {};
    for (var expense in expenses) {
      String categoryName = expense.category?.name ?? 'Uncategorized';
      if (!data.containsKey(categoryName)) {
        data[categoryName] = {
          'name': categoryName,
          'amount': 0.0,
          'backgroundColor': expense.category?.backgroundColor ?? getRandomGraphColor()
        };
      }
      data[categoryName]!['amount'] = data[categoryName]!['amount'] + expense.amount;
    }
    // If no transactions yet, add an "Uncategorized"
    // category as a placeholder
    if (data.keys.isEmpty) {
      data['Uncategorized'] = {
        'name': 'Uncategorized',
        'amount': 1.0,
        'backgroundColor': getRandomGraphColor()
      };
    }
    return data;
  }

  /// Returns a list of FL Chart's `PieChartSectionData` instances
  /// containing different categories of spending and their corresponding
  /// amounts
  List<PieChartSectionData> getExpensesByCategorySectionData() {
    List<PieChartSectionData> data = [];
    var categories = getExpensesByCategory();
    for (var cat in categories.keys) {
      data.add(PieChartSectionData(
        title: categories[cat]!['name'],
        value: categories[cat]!['amount'],
        color: categories[cat]!['backgroundColor'],
        radius: 150,
        borderSide: const BorderSide(
          width: 3,
          color: Colors.black,
        ),
        showTitle: false
      ));
    }
    data.sort((a, b) {
      if (a.value > b.value) {
        return 1;
      }
      return -1;
    });
    return data;
  }
}
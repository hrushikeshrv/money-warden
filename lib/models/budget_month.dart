import 'package:flutter/material.dart' as material;
import 'package:community_charts_common/community_charts_common.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/utils.dart';

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

  /// Returns a list containing information about
  /// expenses for each category in this month. The
  /// returned list is sorted in decreasing order of the
  /// amount spent.
  List<CategorySpend> getExpensesByCategory() {
    // TODO: add tests
    List<CategorySpend> data = [];
    Map<String, int> indexMap = {};
    int idx = 0;
    for (var expense in expenses) {
      String categoryName = expense.category?.name ?? 'Uncategorized';
      material.Color backgroundColor = expense.category?.backgroundColor ?? getRandomGraphColor();
      if (!indexMap.containsKey(categoryName)) {
        indexMap[categoryName] = idx;
        data.add(CategorySpend(name: categoryName, backgroundColor: backgroundColor));
        idx++;
      }
      data[indexMap[categoryName]!].amount = data[indexMap[categoryName]!].amount + expense.amount;
    }

    // If no transactions yet, add an "Uncategorized"
    // category as a placeholder
    if (data.isEmpty) {
      data[0] = CategorySpend(name: 'Uncategorized', backgroundColor: getRandomGraphColor());
    }

    data.sort((a, b) {
      if (a.amount < b.amount) {
        return 1;
      }
      return -1;
    });
    return data;
  }

  /// Returns a list of flutter_charts Series instances
  /// containing different categories of spending and their corresponding
  /// amounts.
  List<charts.Series<CategorySpend, double>> getExpensesByCategorySeriesList() {
    List<CategorySpend> spends = getExpensesByCategory();
    return [
      charts.Series<CategorySpend, double>(
        id: 'Expenses',
        data: spends,
        domainFn: (CategorySpend spend, _) => spend.amount,
        measureFn: (CategorySpend spend, _) => spend.amount,
        labelAccessorFn: (CategorySpend spend, _) => '${spend.name}\n\$${spend.amount}',
        colorFn: (CategorySpend spend, __) {
          material.Color color = spend.backgroundColor ?? getRandomGraphColor();
          return Color(
            r: color.red,
            g: color.green,
            b: color.blue
          );
        },
        // seriesColor: charts.MaterialPalette.green.shadeDefault
      )
    ];
  }
}

/// A class describing a category and the amount spent/earned
/// under that category. Contains two fields -
/// 1. `String name`: The category name
/// 2. `double amount`: The amount spent/earned
class CategorySpend {
  final String name;
  double amount = 0.0;
  final material.Color? backgroundColor;

  CategorySpend({ required this.name , this.backgroundColor});
}
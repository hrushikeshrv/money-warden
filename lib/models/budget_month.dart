import 'package:flutter/material.dart' as material;
import 'package:community_charts_common/community_charts_common.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/utils/utils.dart';

/// Global state for a single month's sheet in the chosen budget
/// spreadsheet.
class BudgetMonth {
  final String name;
  List<Transaction> expenses = [];
  List<Transaction> income = [];
  List<Transaction> filteredTransactions = [];

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
    if (monthIncomeAmount == 0) return 100.0;
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

  /// Filter `filteredTransactions` to only contain
  /// transactions matching the given query. Searches for the
  /// given query to be in the transaction category,
  /// transaction description, or payment method name. If the
  /// query is empty, sets `filteredTransactions` to be the same as
  /// `orderedTransactions`
  void filterTransactions(String query) {
    query = query.toLowerCase();
    List<Transaction> allTransactions = getOrderedTransactions(null);
    filteredTransactions = [];
    for (int i = 0; i < allTransactions.length; i++) {
      if (
        query.isEmpty
        || (allTransactions[i].category?.name.toLowerCase().contains(query) ?? false)
        || (allTransactions[i].description?.toLowerCase().contains(query) ?? false)
        || (allTransactions[i].paymentMethod?.name.toLowerCase().contains(query) ?? false)
      ) {
        filteredTransactions.add(allTransactions[i]);
      }
    }
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
        labelAccessorFn: (CategorySpend spend, _) => '${spend.name}\n${spend.amount.toStringAsFixed(2)}',
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

  /// Looks at the row index of each expense row
  /// in the current month for the chosen budget sheet
  /// and returns the index of a row that does not have a transaction
  int get freeExpenseRowIndex {
    if (expenses.isEmpty) {
      return 4;
    }
    var expensesSorted = [...expenses];
    expensesSorted.sort((a, b) {
      if (a.rowIndex > b.rowIndex) {
        return 1;
      }
      return -1;
    });
    return expensesSorted[expensesSorted.length-1].rowIndex + 1;
  }

  /// Looks at the row index of each expense row
  /// in the current month for the chosen budget sheet
  /// and returns the index of a row that does not have a transaction
  int get freeIncomeRowIndex {
    if (income.isEmpty) {
      return 4;
    }
    var incomeSorted = [...income];
    incomeSorted.sort((a, b) {
      if (a.rowIndex > b.rowIndex) {
        return 1;
      }
      return -1;
    });
    return incomeSorted[incomeSorted.length-1].rowIndex + 1;
  }

  /// Sorts expenses in descending order by date of expense
  void sortExpenses() {
    expenses.sort((Transaction a, Transaction b) => b.time.compareTo(a.time));
  }

  /// Sorts income in descending order by date of income
  void sortIncome() {
    income.sort((Transaction a, Transaction b) => b.time.compareTo(a.time));
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
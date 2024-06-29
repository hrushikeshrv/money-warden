import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_warden/utils.dart';
import 'package:money_warden/services/sheets.dart';
import 'package:money_warden/models/budget_month.dart';

/// Global state for the chosen budget spreadsheet
class BudgetSheet extends ChangeNotifier {
  String? spreadsheetId;
  String? spreadsheetName;
  SharedPreferences? sharedPreferences;
  bool budgetInitialized = false;

  List<String> budgetMonthNames = ['Loading...'];
  String _currentBudgetMonthName = 'Loading...';

  Map<String, BudgetMonth?> budgetData = {};

  BudgetMonth? get currentBudgetMonthData {
    if (budgetData.containsKey(currentBudgetMonthName)) {
      return budgetData[currentBudgetMonthName];
    }
    return null;
  }

  BudgetSheet({ required this.spreadsheetId, required this.spreadsheetName, required this.sharedPreferences });

  /// Fetch and parse all budget data from the budget spreadsheet.
  void initBudgetData({ bool forceUpdate = false }) async {
    if (!budgetInitialized || forceUpdate) {
      await getBudgetMonthNames();
      currentBudgetMonthName = getCurrentOrClosestMonth(budgetMonthNames);
      await getBudgetMonthData(month: currentBudgetMonthName);
      budgetInitialized = true;
      notifyListeners();
    }
  }

  void setSpreadsheetId(String spreadsheetId) {
    this.spreadsheetId = spreadsheetId;
    sharedPreferences?.setString('spreadsheetId', spreadsheetId);
    notifyListeners();
  }

  void setSpreadsheetName(String spreadsheetName) {
    this.spreadsheetName = spreadsheetName;
    sharedPreferences?.setString('spreadsheetName', spreadsheetName);
    notifyListeners();
  }

  void setSharedPreferences(SharedPreferences prefs) {
    sharedPreferences = prefs;
    notifyListeners();
  }

  /// Fetch all sheets in the user's selected budget sheet
  /// and populate this.budgetMonths
  Future<void> getBudgetMonthNames({ bool forceUpdate = false }) async {
    budgetMonthNames = await SheetsService.getBudgetMonthNames(null);
  }

  String get currentBudgetMonthName => _currentBudgetMonthName;
  set currentBudgetMonthName(month) => _currentBudgetMonthName = month;

  void setCurrentBudgetMonth(month) {
    _currentBudgetMonthName = month;
    if (!budgetData.containsKey(month)) {
      budgetData[month] = null;
      getBudgetMonthData(month: month);
    }
    notifyListeners();
  }

  Future<BudgetMonth> getBudgetMonthData({ required String month, bool forceUpdate = false }) async {
    print('Getting budget data for $month');
    if (!forceUpdate && budgetData.containsKey(month) && budgetData[month] != null) {
      return Future<BudgetMonth>.value(budgetData[month]);
    }
    var budgetMonth = await SheetsService.getBudgetMonthData(spreadsheetId!, month, null);
    budgetData[month] = budgetMonth;
    notifyListeners();
    return budgetMonth;
  }
}
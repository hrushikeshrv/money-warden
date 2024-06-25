import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_warden/services/sheets.dart';
import 'package:money_warden/models/budget_month.dart';

/// Global state for the chosen budget spreadsheet
class BudgetSheet extends ChangeNotifier {
  String? spreadsheetId;
  String? spreadsheetName;
  SharedPreferences? sharedPreferences;
  bool budgetInitialized = false;
  List<String> budgetMonthNames = ['Loading...'];
  String _currentBudgetMonth = '';

  List<BudgetMonth> budgetMonths = [];

  BudgetSheet({ required this.spreadsheetId, required this.spreadsheetName, required this.sharedPreferences });

  /// Fetch and parse all budget data from the budget spreadsheet.
  void initBudgetData({ bool forceUpdate = false }) async {
    if (!budgetInitialized || forceUpdate) {
      await getBudgetMonthNames();
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

  String get currentBudgetMonth => _currentBudgetMonth;
  set currentBudgetMonth(month) => _currentBudgetMonth = month;

  void setCurrentBudgetMonth(month) {
    _currentBudgetMonth = month;
    notifyListeners();
  }

}
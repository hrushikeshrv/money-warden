import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_warden/services/sheets.dart';

/// Global state for the chosen budget spreadsheet
class BudgetSheet extends ChangeNotifier {
  String? spreadsheetId;
  String? spreadsheetName;
  SharedPreferences? sharedPreferences;
  bool budgetMonthsInitialized = false;
  List<String> budgetMonths = ['Loading...'];
  String _currentBudgetMonth = '';

  BudgetSheet({ required this.spreadsheetId, required this.spreadsheetName, required this.sharedPreferences });

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
  void getBudgetMonths({ bool forceUpdate = false }) async {
    if (!budgetMonthsInitialized || forceUpdate) {
      budgetMonths = await SheetsService.getBudgetMonths(null);
      budgetMonthsInitialized = true;
      notifyListeners();
    }
  }

  String get currentBudgetMonth => _currentBudgetMonth;
  set currentBudgetMonth(month) => _currentBudgetMonth = month;

  void setCurrentBudgetMonth(month) {
    _currentBudgetMonth = month;
    notifyListeners();
  }
}
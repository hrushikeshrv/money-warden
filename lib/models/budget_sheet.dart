import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global state for the chosen budget spreadsheet
class BudgetSheet extends ChangeNotifier {
  String? spreadsheetId;
  String? spreadsheetName;
  SharedPreferences? sharedPreferences;
  List<String>? budgetMonths;

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

  /// Returns a list of sheet names for all the
  /// months in the chosen budget spreadsheet.
  List<String> getBudgetMonths() {

  }
}
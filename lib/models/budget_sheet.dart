import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetSheet extends ChangeNotifier {
  String? spreadsheetId;
  String? spreadsheetName;
  final SharedPreferences sharedPreferences;

  BudgetSheet({ required this.spreadsheetId, required this.spreadsheetName, required this.sharedPreferences });

  void setSpreadsheetId(String spreadsheetId) {
    this.spreadsheetId = spreadsheetId;
    this.sharedPreferences.setString('spreadsheetId', spreadsheetId);
    notifyListeners();
  }

  void setSpreadsheetName(String spreadsheetName) {
    this.spreadsheetName = spreadsheetName;
    this.sharedPreferences.setString('spreadsheetName', spreadsheetName);
    notifyListeners();
  }
}
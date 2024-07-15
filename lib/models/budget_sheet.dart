import 'package:flutter/foundation.dart';
import 'package:money_warden/exceptions/null_spreadsheet_value_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_warden/utils/utils.dart';
import 'package:money_warden/services/sheets.dart';
import 'package:money_warden/models/category.dart' as category;
import 'package:money_warden/models/budget_month.dart';
import 'package:money_warden/models/transaction.dart';

/// Global state for the chosen budget spreadsheet
class BudgetSheet extends ChangeNotifier {
  String? spreadsheetId;
  String? spreadsheetName;
  SharedPreferences? sharedPreferences;
  bool budgetInitialized = false;
  List<String> budgetMonthNames = ['Loading...'];
  String _currentBudgetMonthName = 'Loading...';
  List<category.Category> expenseCategories = [];
  List<category.Category> incomeCategories = [];
  Map<String, BudgetMonth?> budgetData = {};
  String _defaultCurrencySymbol = '\$';
  String _defaultCurrencyCode = 'USD';

  BudgetSheet({ required this.spreadsheetId, required this.spreadsheetName, required this.sharedPreferences });

  /// Returns the `BudgetMonth` instance for the current month
  BudgetMonth? get currentBudgetMonthData {
    if (budgetData.containsKey(currentBudgetMonthName)) {
      return budgetData[currentBudgetMonthName];
    }
    return null;
  }

  /// Fetch and parse all budget data from the budget spreadsheet
  /// and initialize all other data needed by other screens
  void initBudgetData({ bool forceUpdate = false }) async {
    if (!budgetInitialized || forceUpdate) {
      // Populate this.budgetMonthNames
      await getBudgetMonthNames();
      currentBudgetMonthName = getCurrentOrClosestMonth(budgetMonthNames);
      // Populate this.budgetData with the budget data for the current
      // budget month
      await getBudgetMonthData(month: currentBudgetMonthName);
      // Populate this.expenseCategories and this.incomeCategories
      await getCategoryNames();
      // Initialize the default currency from shared preferences
      // (without notifying listeners)
      _defaultCurrencySymbol = defaultCurrencySymbol;
      _defaultCurrencyCode = defaultCurrencyCode;
      budgetInitialized = true;
      notifyListeners();
    }
  }

  /// Set the spreadsheet Id, persist in shared preferences,
  /// and notify listeners.
  void setSpreadsheetId(String spreadsheetId) {
    this.spreadsheetId = spreadsheetId;
    sharedPreferences?.setString('spreadsheetId', spreadsheetId);
    notifyListeners();
  }

  /// Set the spreadsheet name, persist in shared preferences,
  /// and notify listeners.
  void setSpreadsheetName(String spreadsheetName) {
    this.spreadsheetName = spreadsheetName;
    sharedPreferences?.setString('spreadsheetName', spreadsheetName);
    notifyListeners();
  }

  /// Set the shared preferences instance for this BudgetSheet instance.
  void setSharedPreferences(SharedPreferences prefs) {
    sharedPreferences = prefs;
    notifyListeners();
  }

  /// Fetch all sheets in the user's selected budget sheet
  /// and populate this.budgetMonths
  Future<void> getBudgetMonthNames({ bool forceUpdate = false }) async {
    budgetMonthNames = await SheetsService.getBudgetMonthNames(null);
  }

  /// Return the current budget month's name
  String get currentBudgetMonthName => _currentBudgetMonthName;
  /// Set the current budget month without notifying listeners
  set currentBudgetMonthName(month) => _currentBudgetMonthName = month;

  /// Set the current budget month and notify listeners
  void setCurrentBudgetMonth(month) {
    _currentBudgetMonthName = month;
    if (!budgetData.containsKey(month)) {
      budgetData[month] = null;
      getBudgetMonthData(month: month);
    }
    notifyListeners();
  }

  /// Get the default currency symbol
  String get defaultCurrencySymbol {
    // We are currently only storing the currency symbol,
    // but we may want to create a separate Currency model
    // in the future.
    if (sharedPreferences == null) {
      return '\$';
    }
    return sharedPreferences!.getString('defaultCurrencySymbol') ?? '\$';
  }
  /// Get the default currency symbol
  String get defaultCurrencyCode {
    if (sharedPreferences == null) {
      return 'USD';
    }
    return sharedPreferences!.getString('defaultCurrencyCode') ?? 'USD';
  }

  /// Set the default currency symbol and notify listeners
  void setDefaultCurrency(String code, String symbol) {
    if (sharedPreferences == null) {
      throw Exception("Shared preferences has not been initialized yet.");
    }
    sharedPreferences!.setString('defaultCurrencyCode', code);
    sharedPreferences!.setString('defaultCurrencySymbol', symbol);
    print('Set default currency to $defaultCurrencyCode: $defaultCurrencySymbol');
    notifyListeners();
  }

  /// Fetch all category names in the user's selected budget sheet
  /// and populate this.expenseCategories and this.incomeCategories
  Future<void> getCategoryNames({ bool forceUpdate = false }) async {
    var categoryData = await SheetsService.getTransactionCategories(null);
    expenseCategories = categoryData['expense']!;
    incomeCategories = categoryData['income']!;
  }

  /// Fetches the budget data of a particular month and returns
  /// a BudgetMonth instance
  Future<BudgetMonth> getBudgetMonthData({ required String month, bool forceUpdate = false }) async {
    if (!forceUpdate && budgetData.containsKey(month) && budgetData[month] != null) {
      return Future<BudgetMonth>.value(budgetData[month]);
    }
    var budgetMonth = await SheetsService.getBudgetMonthData(spreadsheetId!, month, null);
    budgetData[month] = budgetMonth;
    notifyListeners();
    return budgetMonth;
  }

  /// Creates a transaction, writes it to the chosen
  /// budget spreadsheet and adds it to the right budget month.
  /// If the passed date doesn't have a corresponding sheet in the
  /// budget spreadsheet, throws a `SpreadsheetValueException`.
  Future<bool> createTransaction({
    required double amount,
    required DateTime date,
    required TransactionType transactionType,
    category.Category? category,
    String? description
  }) async {
    BudgetMonth? budgetMonthData;
    String shortMonthName = getMonthNameFromDate(date, true);
    String longMonthName = getMonthNameFromDate(date, false);

    // If the budget data for the passed transaction date has not
    // been fetched, first try to fetch data for that month.
    // If that month's sheet has not been created, throw an exception.
    if (
      !budgetData.containsKey(shortMonthName)
      && !budgetData.containsKey(longMonthName)
    ) {
      if (budgetMonthNames.contains(shortMonthName)) {
        budgetMonthData = await getBudgetMonthData(month: shortMonthName);
      }
      else if (budgetMonthNames.contains(longMonthName)) {
        budgetMonthData = await getBudgetMonthData(month: longMonthName);
      }
      else {
        throw NullSpreadsheetValueException('Sheet for month $longMonthName has not been created.');
      }
    }
    else if (budgetData.containsKey(shortMonthName)) {
      budgetMonthData = budgetData[shortMonthName];
    }
    else {
      budgetMonthData = budgetData[longMonthName];
    }

    int freeRowIndex = transactionType == TransactionType.expense
        ? budgetMonthData!.freeExpenseRowIndex
        : budgetMonthData!.freeIncomeRowIndex;
    String freeRowRange = transactionType == TransactionType.expense
        ? 'A$freeRowIndex:D$freeRowIndex'
        : 'E$freeRowIndex:H$freeRowIndex';
    return await SheetsService.createTransaction(
      amount: amount,
      date: date,
      category: category,
      description: description,
      freeRowRange: freeRowRange
    );
  }
}
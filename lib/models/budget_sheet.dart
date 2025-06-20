import 'dart:math';
import 'package:googleapis/sheets/v4.dart' show DetailedApiRequestError, Spreadsheet;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/material.dart';
import 'package:money_warden/exceptions/null_spreadsheet_value_exception.dart';
import 'package:money_warden/exceptions/spreadsheet_value_exception.dart';
import 'package:money_warden/exceptions/service_unavailable_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_warden/utils/utils.dart';
import 'package:money_warden/services/sheets.dart';
import 'package:money_warden/models/category.dart' as category;
import 'package:money_warden/models/budget_month.dart';
import 'package:money_warden/models/payment_method.dart';
import 'package:money_warden/models/transaction.dart';

/// Global state for the chosen budget spreadsheet
class BudgetSheet extends ChangeNotifier {
  String? spreadsheetId;
  String? spreadsheetName;
  SharedPreferences? sharedPreferences;
  bool budgetInitialized = false;
  bool budgetInitializationFailed = false;
  List<String> budgetMonthNames = ['Loading...'];
  String _currentBudgetMonthName = 'Loading...';
  List<category.Category> expenseCategories = [];
  List<category.Category> incomeCategories = [];
  List<PaymentMethod> paymentMethods = [];
  Map<String, BudgetMonth?> budgetData = {};
  String _defaultCurrencySymbol = '\$';
  String _defaultCurrencyCode = 'USD';

  /// List of spreadsheets the user has in their Google Account
  List<drive.File>? userSpreadsheets = [];

  BudgetSheet({ required this.spreadsheetId, required this.spreadsheetName, required this.sharedPreferences });

  /// Returns the `BudgetMonth` instance for the current month
  BudgetMonth? get currentBudgetMonthData {
    if (budgetData.containsKey(currentBudgetMonthName)) {
      return budgetData[currentBudgetMonthName];
    }
    return null;
  }

  /// Resets the value of all relevant properties where state is maintained
  /// to prepare for fetching data again.
  void softResetState() {
    budgetMonthNames = ['Loading...'];
    _currentBudgetMonthName = 'Loading...';
    expenseCategories = [];
    incomeCategories = [];
    paymentMethods = [];
    budgetData = {};
  }

  /// Fetch and parse all budget data from the budget spreadsheet
  /// and initialize all other data needed by other screens
  Future<bool> initBudgetData({ bool forceUpdate = false }) async {
    bool rateLimited = false;
    int backoffCount = 0;
    var rng = Random();
    do {
      if (!budgetInitialized || forceUpdate) {
        if (forceUpdate) {
          softResetState();
        }
        try {
          // Populate this.budgetMonthNames
          await getBudgetMonthNames();
          currentBudgetMonthName = getCurrentOrClosestMonth(budgetMonthNames);
          // Populate this.expenseCategories and this.incomeCategories
          await getCategoryNames();
          // Populate this.paymentMethods
          await getPaymentMethods();
          // Populate this.budgetData with the budget data for the current
          // budget month only, not any other month
          await getBudgetMonthData(month: currentBudgetMonthName);
          // Initialize the default currency from shared preferences
          // (without notifying listeners)
          _defaultCurrencySymbol = defaultCurrencySymbol;
          _defaultCurrencyCode = defaultCurrencyCode;
          budgetInitialized = true;
          budgetInitializationFailed = false;
          notifyListeners();
          return budgetInitialized;
        }
        on DetailedApiRequestError catch (e) {
          backoffCount++;
          if (backoffCount >= 5) {
            throw ServiceUnavailableException('A Google Service rate-limited Money Warden.');
          }
          if (e.status == 429) {
            rateLimited = true;
          }
          // Exponential backoff
          await Future.delayed(Duration(seconds: pow(2, backoffCount) as int, milliseconds: rng.nextInt(1000)));
        }
        catch (e) {
          budgetInitializationFailed = true;
          rateLimited = false;
          notifyListeners();
          return budgetInitialized;
        }
      }
    } while (rateLimited && !budgetInitializationFailed);
    return false;
  }

  /// Returns true if the last (at most) six months
  /// of data is already loaded.
  bool lastSixMonthDataLoaded() {
    List<String> lastSixMonths = getLastSixMonths(getCurrentMonthName());
    for (String month in lastSixMonths) {
      if (
        budgetMonthNames.contains(month)
        && !budgetData.containsKey(month)
      ) return false;
    }
    return true;
  }

  /// Fetches budget data for the last 6 months
  /// (or as many are available) and returns the number
  /// of months of data fetched
  Future<int> getLastSixMonthData() async {
    List<String> lastSixMonths = getLastSixMonths(getCurrentMonthName());
    int n = 0;
    for (String month in lastSixMonths) {
      if (budgetMonthNames.contains(month)) {
        await getBudgetMonthData(month: month);
        n++;
      }
    }
    notifyListeners();
    return n;
  }

  /// Set the spreadsheet Id, persist in shared preferences,
  /// and notify listeners.
  Future<bool> setSpreadsheetId(String newSpreadsheetId) async {
    spreadsheetId = newSpreadsheetId;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('spreadsheetId', newSpreadsheetId);
    notifyListeners();
    return true;
  }

  /// Set the spreadsheet name, persist in shared preferences,
  /// and notify listeners.
  Future<bool> setSpreadsheetName(String newSpreadsheetName) async {
    spreadsheetName = newSpreadsheetName;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('spreadsheetName', newSpreadsheetName);
    notifyListeners();
    return true;
  }

  /// Set the shared preferences instance for this BudgetSheet instance.
  void setSharedPreferences(SharedPreferences prefs) {
    sharedPreferences = prefs;
    notifyListeners();
  }

  /// Fetch all sheets in the user's selected budget sheet
  /// and populate this.budgetMonths
  Future<void> getBudgetMonthNames({ bool forceUpdate = false }) async {
    var names = await SheetsService.getBudgetMonthNames(null);
    if (names.isEmpty) {
      await createSheet(getCurrentMonthName());
      budgetMonthNames = [getCurrentMonthName()];
    }
    else {
      budgetMonthNames = names;
    }
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
    notifyListeners();
  }

  /// Fetch all category names in the user's selected budget sheet
  /// and populate this.expenseCategories and this.incomeCategories
  Future<void> getCategoryNames({ bool forceUpdate = false }) async {
    var categoryData = await SheetsService.getTransactionCategories(null);
    expenseCategories = categoryData['expense']!;
    incomeCategories = categoryData['income']!;
  }

  /// Fetch all payment method names from the user's selected budget sheet
  /// and populate this.paymentMethods
  Future<void> getPaymentMethods({ bool forceUpdate = false }) async {
    paymentMethods = await SheetsService.getPaymentMethods(null);
  }

  /// Returns the default payment method object
  PaymentMethod? getDefaultPaymentMethod() {
    for (var method in paymentMethods) {
      if (method.isDefault) return method;
    }
    return null;
  }

  /// Update the icon associated with a payment method.
  /// Purely a local action, SheetsService is not needed.
  Future<void> setPaymentMethodIcon({ required PaymentMethod paymentMethod, required Icon icon }) async {
    paymentMethod.icon = icon;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('payment_method_${paymentMethod.name}_icon', getIconNameFromIcon(icon));
    notifyListeners();
  }

  Future<void> createPaymentMethod({ required PaymentMethod paymentMethod }) async {
    int maxRow = 0;
    for (var method in paymentMethods) {
      int cell = 0;
      if (method.cellId == null) {
        cell = 0;
      }
      else {
        cell = int.parse(method.cellId!.substring(1));
      }
      if (cell > maxRow) maxRow = cell;
    }
    String cellId = 'A${maxRow+1}';
    paymentMethod.cellId = cellId;
    await SheetsService.setPaymentMethodName(cellId: cellId, name: paymentMethod.name);
    paymentMethods.add(paymentMethod);
    setPaymentMethodIcon(paymentMethod: paymentMethod, icon: paymentMethod.icon ?? const Icon(Icons.payments_outlined));
    notifyListeners();
  }

  Future<void> setPaymentMethodName({ required PaymentMethod paymentMethod, required String name }) async {
    await SheetsService.setPaymentMethodName(cellId: paymentMethod.cellId!, name: name);
    for (var method in paymentMethods) {
      if (method.name == paymentMethod.name) {
        method.name = name;
        break;
      }
    }
    notifyListeners();
  }

  Future<void> setPaymentMethodAsDefault({ required PaymentMethod paymentMethod }) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('default_payment_method', paymentMethod.name);
    for (var method in paymentMethods) {
      method.isDefault = false;
    }
    paymentMethod.isDefault = true;
    notifyListeners();
  }

  /// Create a category in the metadata sheet in the selected
  /// budget spreadsheet.
  Future<void> createCategory({ required category.Category category, required TransactionType transactionType }) async {
    var arr = transactionType == TransactionType.expense ? expenseCategories : incomeCategories;
    int maxRow = 0;
    for (var cat in arr) {
      int cell = 0;
      if (cat.cellId == null) {
        cell = 0;
      } else {
        cell = int.parse(cat.cellId!.substring(1));
      }
      if (cell > maxRow) maxRow = cell;
    }
    String cellId = transactionType == TransactionType.expense ? 'B${maxRow+1}' : 'C${maxRow+1}';
    category.cellId = cellId;
    await SheetsService.setTransactionCategoryName(cellId: cellId, name: category.name);
    arr.add(category);
    setCategoryBackgroundColor(
      category: category,
      transactionType: transactionType,
      color: category.backgroundColor ?? getRandomGraphColor()
    );
    notifyListeners();
  }

  /// Set the background color for a transaction category both in the
  /// global provider state and in shared preferences and notify listeners.
  void setCategoryBackgroundColor({
    required category.Category category,
    required TransactionType transactionType,
    required Color color
  }) {
    if (sharedPreferences == null) {
      throw Exception("Shared preferences has not been initialized yet.");
    }
    if (transactionType == TransactionType.expense) {
      for (var cat in expenseCategories) {
        if (cat.name == category.name) {
          cat.backgroundColor = color;
        }
      }
    }
    else {
      for (var cat in incomeCategories) {
        if (cat.name == category.name) {
          cat.backgroundColor = color;
        }
      }
    }
    String key = transactionType == TransactionType.expense
        ? 'expense_${category.name}_color'
        : 'income_${category.name}_color';
    sharedPreferences!.setString(key, color.toString());
    notifyListeners();
  }

  /// Updates the category name for a given category in the chosen
  /// budget sheet
  Future<void> setTransactionCategoryName({
    required category.Category category,
    required TransactionType transactionType,
    required String name
  }) async {
    await SheetsService.setTransactionCategoryName(cellId: category.cellId!, name: name);
    var array = transactionType == TransactionType.expense ? expenseCategories : incomeCategories;
    for (var cat in array) {
      if (cat.name == category.name) {
        cat.name = name;
        break;
      }
    }
    notifyListeners();
  }

  /// Fetches the budget data of a particular month and returns
  /// a BudgetMonth instance
  Future<BudgetMonth> getBudgetMonthData({ required String month, bool forceUpdate = false }) async {
    if (!forceUpdate && budgetData.containsKey(month) && budgetData[month] != null) {
      return Future<BudgetMonth>.value(budgetData[month]);
    }
    var budgetMonth = await SheetsService.getBudgetMonthData(spreadsheetId!, month, null);
    // The Sheets Service can't associate category names with category cell IDs,
    // and cannot associate payment method instances with their stored icon,
    // so we do that here, since we have access to cell IDs and the fetched
    // payment methods here.
    for (int i = 0; i < budgetMonth.expenses.length; i++) {
      if (budgetMonth.expenses[i].category != null) {
        // Find this category name in the expenseCategories list and associate.
        for (int j = 0; j < expenseCategories.length; j++) {
          if (budgetMonth.expenses[i].category!.name == expenseCategories[j].name) {
            budgetMonth.expenses[i].category = expenseCategories[j];
          }
        }
        for (int j = 0; j < paymentMethods.length; j++) {
          if (budgetMonth.expenses[i].paymentMethod?.name == paymentMethods[j].name) {
            budgetMonth.expenses[i].paymentMethod = paymentMethods[j];
          }
        }
      }
    }
    for (int i = 0; i < budgetMonth.income.length; i++) {
      if (budgetMonth.income[i].category != null) {
        // Find this category name in the expenseCategories list and associate.
        for (int j = 0; j < incomeCategories.length; j++) {
          if (budgetMonth.income[i].category!.name == incomeCategories[j].name) {
            budgetMonth.income[i].category = incomeCategories[j];
          }
        }
        for (int j = 0; j < paymentMethods.length; j++) {
          if (budgetMonth.income[i].paymentMethod!.name == paymentMethods[j].name) {
            budgetMonth.income[i].paymentMethod = paymentMethods[j];
          }
        }
      }
    }

    budgetData[month] = budgetMonth;
    notifyListeners();
    return budgetMonth;
  }

  /// Creates a transaction, writes it to the chosen
  /// budget spreadsheet and adds it to the right budget month.
  /// If the passed date doesn't have a corresponding sheet in the
  /// budget spreadsheet, throws a `SpreadsheetValueException`.
  Future<Transaction?> createTransaction({
    required double amount,
    required DateTime date,
    required TransactionType transactionType,
    category.Category? category,
    PaymentMethod? paymentMethod,
    String? description,
    bool updateTransaction = false,
    int? freeRowIndex
  }) async {
    BudgetMonth? budgetMonthData;
    String shortMonthName = getMonthNameFromDate(date, true);
    String longMonthName = getMonthNameFromDate(date, false);
    String budgetMonthName = shortMonthName;

    // If the budget data for the passed transaction date has not
    // been fetched, first try to fetch data for that month.
    // If that month's sheet has not been created, throw an exception.
    if (
      !budgetData.containsKey(shortMonthName)
      && !budgetData.containsKey(longMonthName)
    ) {
      if (budgetMonthNames.contains(shortMonthName)) {
        budgetMonthData = await getBudgetMonthData(month: shortMonthName);
        budgetMonthName = shortMonthName;
      }
      else if (budgetMonthNames.contains(longMonthName)) {
        budgetMonthData = await getBudgetMonthData(month: longMonthName);
        budgetMonthName = longMonthName;
      }
      else {
        await createSheet(longMonthName);
      }
    }
    else if (budgetData.containsKey(shortMonthName)) {
      budgetMonthData = budgetData[shortMonthName];
      budgetMonthName = shortMonthName;
    }
    else {
      budgetMonthData = budgetData[longMonthName];
      budgetMonthName = longMonthName;
    }

    freeRowIndex ??= transactionType == TransactionType.expense
        ? budgetMonthData!.freeExpenseRowIndex
        : budgetMonthData!.freeIncomeRowIndex;
    String freeRowRange = transactionType == TransactionType.expense
        ? '$budgetMonthName!A$freeRowIndex:E$freeRowIndex'
        : '$budgetMonthName!K$freeRowIndex:O$freeRowIndex';

    paymentMethod ??= getDefaultPaymentMethod();
    bool success = await SheetsService.createTransaction(
      amount: amount,
      date: date,
      category: category,
      paymentMethod: paymentMethod,
      description: description,
      freeRowRange: freeRowRange
    );

    // If creating a new transaction, create a
    // Transaction object and add it to the current budget
    if (!updateTransaction) {
      var transaction = Transaction(
        amount: amount,
        time: date,
        description: description,
        category: category,
        paymentMethod: paymentMethod,
        transactionType: transactionType,
        rowIndex: freeRowIndex
      );
      if (transactionType == TransactionType.expense) {
        budgetMonthData!.expenses.add(transaction);
        budgetMonthData.sortExpenses();
      }
      else if (transactionType == TransactionType.income) {
        budgetMonthData!.income.add(transaction);
        budgetMonthData.sortIncome();
      }
    }
    // If updating a transaction, find the Transaction object
    // in the budget month and update its properties
    else {
      // We use the free row index to find the transaction object
      // and update its properties. The updated transaction will
      // always be in the current month, so we don't have to worry
      // about a transaction date being changed and going into another
      // month.
      if (transactionType == TransactionType.expense) {
        for (int i = 0; i < budgetMonthData!.expenses.length; i++) {
          if (budgetMonthData.expenses[i].rowIndex == freeRowIndex) {
            budgetMonthData.expenses[i].category = category;
            budgetMonthData.expenses[i].paymentMethod = paymentMethod;
            budgetMonthData.expenses[i].amount = amount;
            budgetMonthData.expenses[i].time = date;
            budgetMonthData.expenses[i].description = description;
          }
        }
      }
      else if (transactionType == TransactionType.income) {
        for (int i = 0; i < budgetMonthData!.income.length; i++) {
          if (budgetMonthData.income[i].rowIndex == freeRowIndex) {
            budgetMonthData.income[i].category = category;
            budgetMonthData.income[i].paymentMethod = paymentMethod;
            budgetMonthData.income[i].amount = amount;
            budgetMonthData.income[i].time = date;
            budgetMonthData.income[i].description = description;
          }
        }
      }
    }
    notifyListeners();
    return null;
  }


  /// Deletes a given transaction
  Future<bool> deleteTransaction(Transaction transaction) async {
    String shortMonthName = getMonthNameFromDate(transaction.time, true);
    String longMonthName = getMonthNameFromDate(transaction.time, false);
    String monthName = '';
    if (budgetMonthNames.contains(shortMonthName)) {
      monthName = shortMonthName;
    }
    else if (budgetMonthNames.contains(longMonthName)) {
      monthName = longMonthName;
    }
    else {
      throw SpreadsheetValueException('Sheet for $shortMonthName or $longMonthName does not exist in linked budget Spreadsheet.');
    }
    var response = await SheetsService.deleteTransaction(
        monthName: monthName,
        rowIndex: transaction.rowIndex,
        transactionType: transaction.transactionType
    );

    var budgetMonth = budgetData[monthName];
    if (transaction.transactionType == TransactionType.expense) {
      budgetMonth!.expenses.remove(transaction);
    }
    else if (transaction.transactionType == TransactionType.income) {
      budgetMonth!.income.remove(transaction);
    }
    notifyListeners();
    return true;
  }

  /// Creates a new sheet in the selected budget spreadsheet and
  /// updates the local state to include the new sheet.
  Future<bool> createSheet(String monthName) async {
    if (!isMonthName(monthName)) {
      throw SpreadsheetValueException('$monthName is not a valid month name');
    }
    if (budgetMonthNames.contains(monthName)) {
      throw SpreadsheetValueException('$monthName is already in the budget spreadsheet');
    }
    bool response = false;
    try {
      response = await SheetsService.createSheet(monthName: monthName);
    }
    catch (e) {
       rethrow;
    }
    if (!response) {
      throw SpreadsheetValueException('An error occurred while trying to create a new sheet. Please try again later.');
    }
    else {
      BudgetMonth newMonth = BudgetMonth(name: monthName);
      budgetMonthNames.add(monthName);
      budgetData[monthName] = newMonth;
    }
    notifyListeners();
    return true;
  }

  /// Creates a new spreadsheet in the user's Google account and
  /// updates the local state to use the newly created spreadsheet
  /// instead
  Future<void> createSpreadsheet(String spreadsheetName) async {
    softResetState();
    Spreadsheet newSheet = await SheetsService.createNewBudgetSheet(sheetName: spreadsheetName);
    await setSpreadsheetName(spreadsheetName);
    await setSpreadsheetId(newSheet.spreadsheetId!);
    await createSheet(getCurrentMonthName());
    notifyListeners();
  }
}
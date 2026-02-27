import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart' hide Request;
import 'package:googleapis/sheets/v4.dart' as sheets show Request;
import 'package:money_warden/exceptions/authorization_exception.dart';
import 'package:money_warden/models/category.dart';
import 'package:money_warden/models/payment_method.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_warden/exceptions/null_spreadsheet_metadata_exception.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:money_warden/models/budget_month.dart';
import 'package:money_warden/services/auth.dart';


class SheetsService {
  /// The parent budget template spreadsheet (owned by @hrushikeshrv) that every sheet created
  /// by Money Warden inherits from
  static const String templateSpreadsheetID = '1HY1205As44sXW4j_QgH5Mp1jWVAfWK1a8xTedWwgyA0';

  static Future<SheetsApi> getSheetsApiClient() async {
    var client = await AuthService.getAuthenticatedClient();
    if (client == null) {
      throw AuthorizationException('Money Warden was not authorized to access Google Sheets');
    }
    return SheetsApi(client);
  }

  static Future<DriveApi> getDriveApiClient() async {
    var client = await AuthService.getAuthenticatedClient();
    if (client == null) {
      throw AuthorizationException('Money Warden was not authorized to access Google Drive');
    }
    final api = DriveApi(client);
    return api;
  }

  static Future<Map<String, dynamic>> initializeSpreadsheetPrefs() async {
    Map<String, dynamic> data = {};
    var prefs = await SharedPreferences.getInstance();
    data["spreadsheetId"] = prefs.getString("spreadsheetId");
    data["spreadsheetName"] = prefs.getString("spreadsheetName");
    return data;
  }

  /// Returns a Future<FileList>? with
  /// a FileList instance containing all Google Sheets a user has
  /// access to (not just the sheets they own).
  static Future<FileList>? getUserSpreadsheets(DriveApi? api) async {
    api ??= await getDriveApiClient();
    return await api.files.list(q: "mimeType='application/vnd.google-apps.spreadsheet'");
  }

  /// Creates a new spreadsheet in the current user's Google account
  /// in the correct format required by Money Warden
  static Future<Spreadsheet> createNewBudgetSheet({ SheetsApi? api, required String sheetName }) async {
    api ??= await getSheetsApiClient();
    Spreadsheet newSheet = Spreadsheet(
      properties: SpreadsheetProperties(
        title: sheetName
      ),
      sheets: [],
    );
    newSheet = await api.spreadsheets.create(newSheet);
    Spreadsheet templateSpreadsheet = await api.spreadsheets.get(templateSpreadsheetID);

    int? metadataTemplateId;
    int? budgetTemplateId;
    for (var sheet in templateSpreadsheet.sheets!) {
      if (sheet.properties != null && sheet.properties!.title!.trim().toLowerCase() == 'monthly template') {
        budgetTemplateId = sheet.properties!.sheetId;
      }
      if (sheet.properties != null && sheet.properties!.title!.trim().toLowerCase() == 'metadata') {
        metadataTemplateId = sheet.properties!.sheetId;
      }
    }

    var metadataProperties = await api.spreadsheets.sheets.copyTo(
      CopySheetToAnotherSpreadsheetRequest(destinationSpreadsheetId: newSheet.spreadsheetId),
      templateSpreadsheetID,
      metadataTemplateId!
    );
    metadataProperties.title = 'Metadata';
    var monthlyTemplateProperties = await api.spreadsheets.sheets.copyTo(
        CopySheetToAnotherSpreadsheetRequest(destinationSpreadsheetId: newSheet.spreadsheetId),
        templateSpreadsheetID,
        budgetTemplateId!
    );
    monthlyTemplateProperties.title = 'Monthly Template';

    await api.spreadsheets.batchUpdate(
      BatchUpdateSpreadsheetRequest(
        includeSpreadsheetInResponse: false,
        requests: [
          sheets.Request(
            updateSheetProperties: UpdateSheetPropertiesRequest(
              fields: 'title',
              properties: monthlyTemplateProperties
            )
          ),
          sheets.Request(
              updateSheetProperties: UpdateSheetPropertiesRequest(
                  fields: 'title',
                  properties: metadataProperties
              )
          ),
        ]
      ),
      newSheet.spreadsheetId!
    );
    return newSheet;
  }

  /// Creates a new sheet in the selected budget spreadsheet by copying
  /// the "Monthly Template" sheet that is supposed to be present in a budget
  /// spreadsheet. Assumes the given month is a valid month.
  static Future<bool> createSheet({ SheetsApi? api, required String monthName }) async {
    api ??= await getSheetsApiClient();
    var prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString('spreadsheetId');
    if (spreadsheetId == null) {
      throw NullSpreadsheetMetadataException('No spreadsheet has been selected, spreadsheetId was null');
    }
    var spreadsheet = await api.spreadsheets.get(spreadsheetId);
    int? templateSheetId;
    // Find the sheetId for the monthly template sheet
    for (var sheet in spreadsheet.sheets!) {
      if (sheet.properties != null && sheet.properties!.title!.trim().toLowerCase() == 'monthly template') {
        templateSheetId = sheet.properties!.sheetId;
      }
    }
    if (templateSheetId == null) {
      throw NullSpreadsheetMetadataException('The selected budget spreadsheet does not have the monthly template sheet');
    }

    // Copy the monthly template sheet to a new sheet
    var newSheetProperties = await api.spreadsheets.sheets.copyTo(
      CopySheetToAnotherSpreadsheetRequest(destinationSpreadsheetId: spreadsheetId),
      spreadsheetId,
      templateSheetId
    );
    newSheetProperties.title = monthName;
    api.spreadsheets.batchUpdate(
      BatchUpdateSpreadsheetRequest(
        includeSpreadsheetInResponse: false,
        requests: [
          sheets.Request(
            updateSheetProperties: UpdateSheetPropertiesRequest(
              fields: 'title',
              properties: newSheetProperties
            )
          ),
        ]
      ),
      spreadsheetId
    );

    return true;
  }

  /// Returns a list of sheet names for all the
  /// months in the chosen budget spreadsheet sorted by latest first.
  /// Does not return other sheets like the Metadata sheet
  /// or the Finances Summary sheet.
  static Future<List<String>> getBudgetMonthNames(SheetsApi? api) async {
    api ??= await getSheetsApiClient();
    var prefs = await SharedPreferences.getInstance();

    String? spreadsheetId = prefs.getString('spreadsheetId');
    if (spreadsheetId == null) {
      throw NullSpreadsheetMetadataException('No spreadsheet has been selected, spreadsheetId was null.');
    }

    List<String> sheetNames = [];
    var spreadsheet = await api.spreadsheets.get(spreadsheetId);
    var sheets = spreadsheet.sheets;
    if (sheets == null ) {
      throw NullSpreadsheetMetadataException('No sheets found in the fetched spreadsheet "${spreadsheet.properties!.title}"');
    }

    for (var sheet in sheets) {
      if (isMonthName(sheet.properties!.title ?? '')) {
        sheetNames.add(sheet.properties!.title ?? '');
      }
    }
    sheetNames.sort((a, b) {
      DateTime aDate = getDateFromMonthName(a);
      DateTime bDate = getDateFromMonthName(b);
      return bDate.compareTo(aDate);
    });
    return sheetNames;
  }

  /// Returns a BudgetMonth instance populated with data from the
  /// corresponding sheet in the spreadsheet with the passed spreadsheetId.
  ///
  /// Assumes the passed month exists in the budget spreadsheet,
  /// and throws an exception if it doesn't.
  static Future<BudgetMonth> getBudgetMonthData(String spreadsheetId, String month, SheetsApi? api) async {
    api ??= await getSheetsApiClient();
    BudgetMonth budgetMonth = BudgetMonth(name: month);
    var valuesResponse = await api.spreadsheets.values.batchGet(
      spreadsheetId,
      ranges: ["'$month'!A4:E", "'$month'!K4:O"],
      majorDimension: "ROWS"
    );
    var valueRanges = valuesResponse.valueRanges;
    var expenses = valueRanges?[0].values;
    var incomes = valueRanges?[1].values;
    expenses ??= [];
    incomes ??= [];

    for (int i = 0; i < expenses.length; i++) {
      var expense = expenses[i];
      if (
        expense[0] != null && expense[0] != ''
        && expense[1] != null && expense[1] != ''
      ) {
        var txnDate = parseDate(expense[0] as String);
        if (txnDate.year == 1970) {
          txnDate = getFirstDateOfMonth(txnDate);
        }
        var txn = Transaction(
          time: txnDate,
          amount: parseAmount(expense[1].toString()),
          transactionType: TransactionType.expense,
          rowIndex: i+4
        );
        if (expense[2] != null && expense[2] != '') {
          txn.description = expense[2].toString();
        }
        if (expense.length >= 4 && expense[3] != null && expense[3] != '') {
          txn.category = Category(name: expense[3].toString());
        }
        if (expense.length >= 5 && expense[4] != null && expense[4] != '') {
          txn.paymentMethod = PaymentMethod(name: expense[4].toString());
        }
        budgetMonth.expenses.add(txn);
      }
      else {
        break;
      }
    }
    budgetMonth.sortExpenses();
    for (int i = 0; i < incomes.length; i++) {
      var income = incomes[i];
      if (income.isEmpty) continue;
      if (
        income[0] != null && income[0] != ''
        && income[1] != null && income[1] != ''
      ) {
        var txnDate = parseDate(income[0] as String);
        if (txnDate.year == 1970) {
          txnDate = getFirstDateOfMonth(txnDate);
        }
        var txn = Transaction(
          time: txnDate,
          amount: parseAmount(income[1].toString()),
          transactionType: TransactionType.income,
          rowIndex: i+4
        );
        if (income[2] != null && income[2] != '') {
          txn.description = income[2].toString();
        }
        if (income.length >= 4 && income[3] != null && income[3] != '') {
          txn.category = Category(name: income[3].toString());
        }
        if (income.length >= 5 && income[4] != null && income[4] != '') {
          txn.paymentMethod = PaymentMethod(name: income[4].toString());
        }
        budgetMonth.income.add(txn);
      }
      else {
        break;
      }
    }
    budgetMonth.sortIncome();
    return budgetMonth;
  }

  /// Gets expense categories and income categories from the
  /// budget spreadsheet and returns a map with 2 keys - 'expense' and 'income'
  /// with a List\<Category> as the values.
  /// ```
  /// {
  ///   'expense': List<Category>,
  ///   'income': List<Category>
  /// }
  /// ```
  static Future<Map<String, List<Category>>> getTransactionCategories(SheetsApi? api) async {
    api ??= await getSheetsApiClient();

    var prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString('spreadsheetId');
    if (spreadsheetId == null) {
      throw NullSpreadsheetMetadataException('No spreadsheet has been selected, spreadsheetId was null.');
    }

    var valuesResponse = await api.spreadsheets.values.batchGet(
        spreadsheetId,
        ranges: ["'Metadata'!B2:C",],
        majorDimension: "COLUMNS"
    );

    Map<String, List<Category>> data = {
      'expense': [],
      'income': [],
    };

    var values = valuesResponse.valueRanges?[0].values;
    if (values == null) {
      return data;
    }
    for (int i = 0; i < values[0].length; i++) {
      var exp = values[0][i];
      if (exp == null) {
        break;
      }
      var color = prefs.getString('expense_${exp as String}_color');
      data['expense']!.add(
        Category(
          name: exp,
          cellId: 'B${i+2}',
          backgroundColor: color != null ? parseStoredColorString(color): null,
        )
      );
    }
    for (int i = 0; i < values[1].length; i++) {
      var income = values[1][i];
      if (income == null) {
        break;
      }

      var color = prefs.getString('income_${income as String}_color');
      data['income']!.add(
        Category(
          name: income,
          cellId: 'C${i+2}',
          backgroundColor: color != null ? parseStoredColorString(color) : null
        )
      );
    }
    return data;
  }

  static Future<List<PaymentMethod>> getPaymentMethods(SheetsApi? api) async {
    api ??= await getSheetsApiClient();

    var prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString('spreadsheetId');
    if (spreadsheetId == null) {
      throw NullSpreadsheetMetadataException('No spreadsheet has been selected, spreadsheetId was null.');
    }

    var valuesResponse = await api.spreadsheets.values.batchGet(
        spreadsheetId,
        ranges: ["'Metadata'!A2:A",],
        majorDimension: "COLUMNS"
    );

    List<PaymentMethod> paymentMethods = [];
    String defaultPaymentMethodName = prefs.getString('default_payment_method') ?? 'Unspecified';

    var values = valuesResponse.valueRanges?[0].values;
    if (values == null) {
      return paymentMethods;
    }
    for (int i = 0; i < values[0].length; i++) {
      var method = values[0][i];
      if (method == null) {
        break;
      }
      var icon = getIconFromStoredString(iconName: prefs.getString('payment_method_${method as String}_icon') ?? 'payment');
      paymentMethods.add(
        PaymentMethod(
          name: method,
          cellId: 'A${i+2}',
          icon: icon,
          isDefault: defaultPaymentMethodName == method
        )
      );
    }
    return paymentMethods;
  }

  /// Sets the name of a payment method in the
  /// chosen budget spreadsheet
  static Future<void> setPaymentMethodName({
    SheetsApi? api,
    required String cellId,
    required String name,
  }) async {
    api ??= await getSheetsApiClient();
    var prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString('spreadsheetId');
    if (spreadsheetId == null) {
      throw NullSpreadsheetMetadataException('No spreadsheet has been selected, spreadsheetId was null.');
    }

    var valueRange = ValueRange(
      majorDimension: 'ROWS',
      range: 'Metadata!$cellId',
      values: [[name]]
    );
    await api.spreadsheets.values.update(
      valueRange,
      spreadsheetId,
      'Metadata!$cellId',
      valueInputOption: 'USER_ENTERED'
    );
  }

  /// Creates an expense or income in the selected budget spreadsheet
  /// with the passed data.
  static Future<bool> createTransaction({
    SheetsApi? api,
    required double amount,
    required DateTime date,
    Category? category,
    PaymentMethod? paymentMethod,
    String? description,
    required String freeRowRange
  }) async {
    api ??= await getSheetsApiClient();

    var prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString('spreadsheetId');
    if (spreadsheetId == null) {
      throw NullSpreadsheetMetadataException('No spreadsheet has been selected, spreadsheetId was null.');
    }
    String categoryCellId = category?.cellId ?? 'B2';
    String paymentMethodCellId = paymentMethod?.cellId ?? 'A2';
    var valueRange = ValueRange(
      majorDimension: 'ROWS',
      range: freeRowRange,
      values: [['${date.day} ${getMonthNameFromDate(date, false)}', amount, description ?? '', '=Metadata!$categoryCellId', '=Metadata!$paymentMethodCellId']]
    );
    var updateValuesResponse = await api.spreadsheets.values.update(
      valueRange,
      spreadsheetId,
      freeRowRange,
      valueInputOption: 'USER_ENTERED'
    );
    return true;
  }

  static Future<bool> deleteTransaction({
    SheetsApi? api,
    required String monthName,
    required int rowIndex,
    required TransactionType transactionType
  }) async {
    api ??= await getSheetsApiClient();

    var prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString('spreadsheetId');
    if (spreadsheetId == null) {
      throw NullSpreadsheetMetadataException('No spreadsheet has been selected, spreadsheetId was null.');
    }
    String freeRowRange = '';
    if (transactionType == TransactionType.expense) {
      freeRowRange = '$monthName!A$rowIndex:E$rowIndex';
    }
    else {
      freeRowRange = '$monthName!K$rowIndex:O$rowIndex';
    }

    var valueRange = ValueRange(
        majorDimension: 'ROWS',
        range: freeRowRange,
        values: [['', '', '', '', '']]
    );
    var updateValuesResponse = await api.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        freeRowRange,
        valueInputOption: 'USER_ENTERED'
    );
    return true;
  }

  /// Sets the name of a transaction category in the
  /// chosen budget spreadsheet
  static Future<void> setTransactionCategoryName({
    SheetsApi? api,
    required String cellId,
    required String name
  }) async {
    api ??= await getSheetsApiClient();
    var prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString('spreadsheetId');
    if (spreadsheetId == null) {
      throw NullSpreadsheetMetadataException('No spreadsheet has been selected, spreadsheetId was null.');
    }

    var valueRange = ValueRange(
      majorDimension: 'ROWS',
      range: 'Metadata!$cellId',
      values: [[name]]
    );
    await api.spreadsheets.values.update(
      valueRange,
      spreadsheetId,
      'Metadata!$cellId',
      valueInputOption: 'USER_ENTERED'
    );
  }
}
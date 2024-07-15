import 'package:flutter/material.dart' as material;
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:http/http.dart';
import 'package:money_warden/models/category.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_warden/exceptions/null_spreadsheet_metadata_exception.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:money_warden/models/budget_month.dart';
import 'package:money_warden/services/auth.dart';


class SheetsService {
  static Future<SheetsApi> getSheetsApiClient() async {
    var client = (await AuthService.getAuthenticatedClient())!;
    return SheetsApi(client as Client);
  }

  static Future<DriveApi> getDriveApiClient() async {
    var client = (await AuthService.getAuthenticatedClient())!;
    return DriveApi(client as Client);
  }

  /// Returns a Future<FileList>? with
  /// a FileList instance containing all Google Sheets a user has
  /// access to (not just the sheets they own).
  static Future<FileList>? getUserSpreadsheets(DriveApi? api) async {
    api ??= await getDriveApiClient();
    return await api.files.list(q: "mimeType='application/vnd.google-apps.spreadsheet'");
  }

  /// Returns a list of sheet names for all the
  /// months in the chosen budget spreadsheet.
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
    return sheetNames;
  }

  /// Returns a BudgetMonth instance populated with data from the
  /// corresponding sheet in the spreadsheet with the passed spreadsheetId.
  ///
  /// IMPORTANT: Assumes the passed month exists in the budget spreadsheet,
  /// and throws an exception if it doesn't.
  static Future<BudgetMonth> getBudgetMonthData(String spreadsheetId, String month, SheetsApi? api) async {
    api ??= await getSheetsApiClient();
    BudgetMonth budgetMonth = BudgetMonth(name: month);
    var valuesResponse = await api.spreadsheets.values.batchGet(
      spreadsheetId,
      ranges: ["'$month'!A4:D", "'$month'!E4:H"],
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
        var txn = Transaction(
          time: parseDate(expense[0] as String),
          amount: parseAmount(expense[1].toString()),
          transactionType: TransactionType.expense,
          rowIndex: i+4
        );
        if (expense[2] != null && expense[2] != '') {
          txn.description = expense[2].toString();
        }
        if (expense[3] != null && expense[3] != '') {
          txn.category = Category(name: expense[3].toString());
        }
        budgetMonth.expenses.add(txn);
      }
      else {
        break;
      }
    }
    budgetMonth.expenses.sort((Transaction a, Transaction b) => b.time.compareTo(a.time));
    for (int i = 0; i < incomes.length; i++) {
      var income = incomes[i];
      if (
      income[0] != null && income[0] != ''
          && income[1] != null && income[1] != ''
      ) {
        var txn = Transaction(
          time: parseDate(income[0] as String),
          amount: parseAmount(income[1].toString()),
          transactionType: TransactionType.income,
          rowIndex: i+4
        );
        if (income[2] != null && income[2] != '') {
          txn.description = income[2].toString();
        }
        if (income[3] != null && income[3] != '') {
          txn.category = Category(name: income[3].toString());
        }
        budgetMonth.income.add(txn);
      }
      else {
        break;
      }
    }
    budgetMonth.income.sort((Transaction a, Transaction b) => b.time.compareTo(a.time));
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
          backgroundColor: color != null ? material.Color(int.parse(color, radix: 16)) : null,
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
          backgroundColor: color != null ? material.Color(int.parse(color, radix: 16)) : null
        )
      );
    }
    return data;
  }

  static Future<bool> createTransaction({
    SheetsApi? api,
    required double amount,
    required DateTime date,
    Category? category,
    String? description,
    required String freeRowRange
  }) async {
    api ??= await getSheetsApiClient();

    var prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString('spreadsheetId');
    if (spreadsheetId == null) {
      throw NullSpreadsheetMetadataException('No spreadsheet has been selected, spreadsheetId was null.');
    }
    var updateValuesResponse = await api.spreadsheets.values.update(
      ValueRange(
        majorDimension: 'ROWS',
        range: freeRowRange,
        values: [['${date.day} ${date.month} ${date.year}', amount, category ?? 'Uncategorized', description ?? '']]
      ),
      spreadsheetId,
      freeRowRange,
      valueInputOption: 'USER_ENTERED'
    );
    return true;
  }
}
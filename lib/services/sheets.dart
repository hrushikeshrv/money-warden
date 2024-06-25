import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:http/http.dart';
import 'package:money_warden/exceptions/null_spreadsheet_value_exception.dart';
import 'package:money_warden/models/category.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money_warden/exceptions/null_spreadsheet_metadata_exception.dart';
import 'package:money_warden/utils.dart';
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

  /// Return a BudgetMonth instance populated with data from the
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
    if (expenses == null) {
      throw NullSpreadsheetValueException("Couldn't fetch expenses from spreadsheet ID: $spreadsheetId");
    }
    if (incomes == null) {
      throw NullSpreadsheetValueException("Couldn't fetch incomes from spreadsheet ID: $spreadsheetId");
    }

    for (var expense in expenses) {
      if (
        expense[0] != null && expense[0] != ''
        && expense[1] != null && expense[1] != ''
      ) {
        var txn = Transaction(
          time: parseDate(expense[0] as String),
          amount: double.parse(expense[1].toString()),
          transactionType: TransactionType.expense
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
    for (var income in incomes) {
      if (
      income[0] != null && income[0] != ''
          && income[1] != null && income[1] != ''
      ) {
        var txn = Transaction(
            time: parseDate(income[0] as String),
            amount: double.parse(income[1].toString()),
            transactionType: TransactionType.income
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
    return budgetMonth;
  }
}
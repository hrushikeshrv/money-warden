import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:http/http.dart';
import 'package:money_warden/exceptions/null_spreadsheet_exception.dart';
import 'package:money_warden/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static Future<List<String>> getBudgetMonths(SheetsApi? api) async {
    api ??= await getSheetsApiClient();
    var prefs = await SharedPreferences.getInstance();
    print('Getting sheets');

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
        print('Found month ${sheet.properties!.title}');
      }
    }
    return sheetNames;
  }
}
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart';
import 'package:googleapis/sheets/v4.dart';

import 'package:money_warden/services/auth.dart';


class SheetsService {
  static getSheetsApiClient() async {
    var client = (await AuthService.getAuthenticatedClient())!;
    return SheetsApi(client as Client);
  }

  static getDriveApiClient() async {
    var client = (await AuthService.getAuthenticatedClient())!;
    return DriveApi(client as Client);
  }

  /// Returns an instance of List\<File\> containing
  /// all Google Sheets a user has.
  static getUserSpreadsheets(DriveApi api) async {
    var sheets = await api.files.list(q: "mimeType='application/vnd.google-apps.spreadsheet'");
    return sheets.files;
  }
}
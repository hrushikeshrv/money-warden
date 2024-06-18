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

  /// Returns a Future<FileList>? with
  /// a FileList instance containing all Google Sheets a user has
  /// access to (not just the sheets they own).
  static Future<FileList>? getUserSpreadsheets(DriveApi? api) async {
    api ??= await SheetsService.getDriveApiClient();
    return await api!.files.list(q: "mimeType='application/vnd.google-apps.spreadsheet'");
  }
}
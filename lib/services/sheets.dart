import 'package:http/http.dart';
import 'package:googleapis/sheets/v4.dart';

import 'package:money_warden/services/auth.dart';


class SheetsService {
  static getApiClient() async {
    var client = (await AuthService.getAuthenticatedClient())!;
    return SheetsApi(client as Client);
  }

  static getUserSpreadsheets(SheetsApi api) {
    return api.spreadsheets.sheets;
  }
}
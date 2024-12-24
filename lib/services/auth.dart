import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  static final googleSignIn = GoogleSignIn(
    scopes: <String>[
      sheets.SheetsApi.spreadsheetsScope,
      drive.DriveApi.driveReadonlyScope,
    ]
  );

  static Future<bool> isSignedIn() {
    return googleSignIn.isSignedIn();
  }

  static String getUserEmail() {
      GoogleSignInAccount? account = googleSignIn.currentUser;
      if (account != null) {
        return account.email;
      }
      return '';
  }

  static String? getUserPhotoUrl() {
    GoogleSignInAccount? account = googleSignIn.currentUser;
    if (account != null) {
      return account.photoUrl;
    }
    return '';
  }

  /// Sign a user in using their Google account
  static Future<GoogleSignInAccount?> signIn() {
    return googleSignIn.signIn();
  }

  static Future<GoogleSignInAccount?> signOut() {
    return googleSignIn.signOut();
  }

  static Future<auth.AuthClient?> getAuthenticatedClient() async {
    return googleSignIn.authenticatedClient();
  }

  static Future<Map<String, dynamic>> initializeAuth() async {
    Map<String, dynamic> data = {};
    GoogleSignInAccount? previousUser = await googleSignIn.signInSilently();
    final prefs = await SharedPreferences.getInstance();

    String? spreadsheetId = prefs.getString('spreadsheetId');
    String? spreadsheetName = prefs.getString('spreadsheetName');
    data['user'] = previousUser;
    data['spreadsheetId'] = spreadsheetId ?? '';
    data['spreadsheetName'] = spreadsheetName ?? '';
    data['sharedPreferences'] = prefs;
    return data;
  }
}
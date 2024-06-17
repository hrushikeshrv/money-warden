import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

class AuthService {
  static final googleSignIn = GoogleSignIn(
    scopes: <String>[
      sheets.SheetsApi.spreadsheetsScope,
      // drive.DriveApi.driveFileScope,
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
}
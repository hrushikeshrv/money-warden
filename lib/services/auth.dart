import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;

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
  static signIn() {
    return googleSignIn.signIn();
  }

  static signOut() {
    return googleSignIn.signOut();
  }
}
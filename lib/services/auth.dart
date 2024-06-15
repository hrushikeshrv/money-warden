import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;

class AuthService {
  static final googleSignIn = GoogleSignIn(
    scopes: <String>[
      // sheets.SheetsApi.spreadsheetsScope,
      drive.DriveApi.driveFileScope,
    ]
  );
  /// Sign a user in using their Google account
  signIn() {
    return googleSignIn.signIn();
  }
}
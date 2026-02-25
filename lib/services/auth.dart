import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:money_warden/services/sheets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _initialized = false;

  /// Must be called before any other auth operation
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await _googleSignIn.initialize(
      scopes: <String>[
        sheets.SheetsApi.spreadsheetsScope,
        drive.DriveApi.driveReadonlyScope,
      ],
    );

    _initialized = true;
  }

  static Future<bool> isSignedIn() async {
    await _ensureInitialized();
    return _googleSignIn.isSignedIn;
  }

  static String getUserEmail() {
    final account = _googleSignIn.currentUser;
    return account?.email ?? '';
  }

  static String? getUserPhotoUrl() {
    return _googleSignIn.currentUser?.photoUrl;
  }

  /// Sign in with Google
  static Future<GoogleSignInAccount?> signIn() async {
    await _ensureInitialized();
    return await _googleSignIn.authenticate();
  }

  static Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }

  static Future<auth.AuthClient?> getAuthenticatedClient() async {
    await _ensureInitialized();
    return await _googleSignIn.authenticatedClient();
  }

  static Future<Map<String, dynamic>> initializeAuth() async {
    await _ensureInitialized();

    Map<String, dynamic> data = {};

    // Silent sign-in replacement
    GoogleSignInAccount? previousUser =
        await _googleSignIn.attemptLightweightAuthentication();

    final prefs = await SharedPreferences.getInstance();

    List<drive.File>? spreadsheets;

    if (previousUser != null) {
      final result = await SheetsService.getUserSpreadsheets(null);
      spreadsheets = result?.files;
    }

    data['user'] = previousUser;
    data['sharedPreferences'] = prefs;
    data['spreadsheets'] = spreadsheets;

    return data;
  }
}

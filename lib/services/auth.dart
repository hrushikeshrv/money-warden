import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:money_warden/services/sheets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared preferences key to store whether the user manually signed out.
/// If they did, don't attempt lightweight authentication on app startup.
String kManuallySignedOut = 'manually_signed_out';

class AuthService {
  static List<String> scopes = [
    sheets.SheetsApi.spreadsheetsScope,
    drive.DriveApi.driveMetadataReadonlyScope,
    // drive.DriveApi.driveFileScope
  ];
  static GoogleSignIn googleSignIn = GoogleSignIn.instance;
  /// The currently authenticated user object (if any)
  static GoogleSignInAccount? currentUser;
  /// Designates if the user has granted permissions
  static bool isAuthorized = false;
  /// Previous authentication error message received
  static String authErrorMessage = '';

  /// Listens to events from the authentication event stream and requests authorization
  /// when the user logs in
  static Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch(event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null
    };

    final GoogleSignInClientAuthorization? authorization = await user?.authorizationClient.authorizationForScopes(scopes);
    isAuthorized = authorization != null;
    authErrorMessage = '';
    currentUser = user;
  }

  static Future<void> _handleAuthenticationError(Object e) async {
    currentUser = null;
    authErrorMessage = e is GoogleSignInException
        ? _getAuthenticationErrorMessage(e)
        : "Unknown error: $e";
  }

  static String _getAuthenticationErrorMessage(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => "Sign in canceled",
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }

  static String getUserEmail() {
    return currentUser?.email ?? 'Unknown user';
  }

  static String? getUserPhotoUrl() {
    return currentUser?.photoUrl ?? '';
  }

  /// Sign in with Google
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      currentUser = await googleSignIn.authenticate(scopeHint: scopes);
      if (currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(kManuallySignedOut, false);
      }
      return currentUser;
    }
    catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  /// Signs the user out, but does not revoke authorization from Money
  /// Warden. Sets a manually signed out boolean flag in shared preferences
  /// so we don't try to attempt lightweight authentication on next startup
  static Future<void> signOut() async {
    await googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(kManuallySignedOut, true);
  }

  /// Signs the user out and revokes authorization from Money
  /// Warden. Sets a manually signed out boolean flag in shared preferences
  //  so we don't try to attempt lightweight authentication on next startup
  static Future<void> disconnect() async {
    await googleSignIn.disconnect();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(kManuallySignedOut, true);
  }

  static Future<AuthClient?> getAuthenticatedClient() async {
    if (currentUser == null) return null;
    GoogleSignInClientAuthorization? authorization = await currentUser!.authorizationClient.authorizationForScopes(scopes);
    if (authorization == null) {
      try {
        authorization = await currentUser!.authorizationClient.authorizeScopes(scopes);
      }
      catch (e) {
        return null;
      }
    };
    return authorization.authClient(scopes: scopes);
  }

  /// Initialize authentication and authorization on app startup
  static Future<Map<String, dynamic>> initializeAuth() async {
    await googleSignIn.initialize();
    googleSignIn.authenticationEvents
        .listen(_handleAuthenticationEvent)
        .onError(_handleAuthenticationError);

    final prefs = await SharedPreferences.getInstance();
    bool manuallySignedOut = prefs.getBool(kManuallySignedOut) ?? false;
    // Only attempt lightweight authentication if the user did not manually
    // sign out last time. If they did, do nothing, and we should display the
    // log in screen.
    if (!manuallySignedOut) {
      currentUser = await googleSignIn.attemptLightweightAuthentication();
    }

    Map<String, dynamic> data = {};
    List<drive.File>? spreadsheets;
    // Designates whether the user has given authorization to access Sheets and Drive
    bool isAuthorized = false;

    if (currentUser != null) {
      final authorization = await currentUser!.authorizationClient.authorizationForScopes(scopes);
      if (authorization != null) {
        isAuthorized = true;
        final result = await SheetsService.getUserSpreadsheets(null);
        spreadsheets = result?.files;
      }
    }

    data['user'] = currentUser;
    data['isAuthorized'] = isAuthorized;
    data['sharedPreferences'] = prefs;
    data['spreadsheets'] = spreadsheets;
    return data;
  }
}

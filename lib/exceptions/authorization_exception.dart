/// An exception occurred because the user did not give authorization
/// to access their resources
class AuthorizationException implements Exception {
  String cause;
  AuthorizationException(this.cause);
}

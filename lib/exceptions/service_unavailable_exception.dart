/// A required service was not available (generally Google Sheets or Drive),
/// possibly due to rate-limits
class ServiceUnavailableException implements Exception {
  String cause;
  ServiceUnavailableException(this.cause);
}
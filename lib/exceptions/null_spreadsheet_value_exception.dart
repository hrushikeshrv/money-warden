/// An exception occurred because some spreadsheet value was null when
/// it should have been non-null.
class NullSpreadsheetValueException implements Exception {
  String cause;
  NullSpreadsheetValueException(this.cause);
}
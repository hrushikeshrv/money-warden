/// An exception occurred because some spreadsheet value was invalid.
class SpreadsheetValueException implements Exception {
  String cause;
  SpreadsheetValueException(this.cause);
}

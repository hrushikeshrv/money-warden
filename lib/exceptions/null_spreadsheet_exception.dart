/// An exception occurred because some spreadsheet metadata was null when
/// it should have been non-null.
class NullSpreadsheetMetadataException implements Exception {
  String cause;
  NullSpreadsheetMetadataException(this.cause);
}
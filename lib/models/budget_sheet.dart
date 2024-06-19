import 'package:flutter/foundation.dart';

class BudgetSheet extends ChangeNotifier {
  final String? spreadsheetId;
  final String? spreadsheetName;

  BudgetSheet({ required this.spreadsheetId, required this.spreadsheetName });
}
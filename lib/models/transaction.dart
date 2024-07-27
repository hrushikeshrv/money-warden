import 'package:money_warden/models/category.dart';

enum TransactionType {
  expense, income;
}

class Transaction {
  DateTime time;
  double amount;
  String? description;
  Category? category;
  final TransactionType transactionType;
  final int rowIndex;

  Transaction({
    required this.time,
    required this.amount,
    this.description,
    this.category,
    required this.transactionType,
    required this.rowIndex,
  });

  bool get hasDescription {
    return description != null && description!.trim().isNotEmpty;
  }

  String get shortDescription {
    if (description == null) {
      return '';
    }
    if (description!.length > 25) {
      return '${description!.substring(0, 23).replaceAll('\n', ' ')}...';
    }
    return description!;
  }
}
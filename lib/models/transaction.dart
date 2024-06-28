import 'package:money_warden/models/category.dart';

enum TransactionType {
  expense, income;
}

class Transaction {
  final DateTime time;
  final double amount;
  String? description;
  Category? category;
  final TransactionType transactionType;

  Transaction({
    required this.time,
    required this.amount,
    this.description,
    this.category,
    required this.transactionType,
  });

  bool get hasDescription {
    return description != null;
  }

  String get shortDescription {
    if (description == null) {
      return '';
    }
    if (description!.length > 25) {
      return '${description!.substring(0, 23)}...';
    }
    return description!;
  }
}
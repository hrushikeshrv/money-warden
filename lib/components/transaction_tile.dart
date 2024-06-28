import 'package:flutter/material.dart';

import 'package:money_warden/utils.dart';
import 'package:money_warden/models/transaction.dart';


class TransactionTile extends StatefulWidget {
  final Transaction? transaction;
  const TransactionTile({super.key, required this.transaction});

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  @override
  Widget build(BuildContext context) {
  if (widget.transaction == null) {
      return Container();
    }
    return ListTile(
      leading: widget.transaction!.transactionType == TransactionType.expense ?
          const Icon(Icons.payments_outlined)
          : Icon(Icons.savings_outlined, color: Colors.green.shade500),
      title: Text(
        '${widget.transaction!.transactionType == TransactionType.expense ? '' : '+'}\$${formatMoney(widget.transaction!.amount)}',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: widget.transaction!.transactionType == TransactionType.expense ?
            Theme.of(context).colorScheme.onSurface
            : Colors.green.shade500
        )
      ),
      subtitle: Text(formatDateTime(widget.transaction!.time)),
    );
  }
}

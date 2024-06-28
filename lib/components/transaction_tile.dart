import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_warden/components/pill_container.dart';

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
    Widget mainTitle = Container();
    Widget? subtitle;
    String descriptionText = widget.transaction!.shortDescription;
    String categoryText = widget.transaction!.category != null ? widget.transaction!.category!.name : 'Uncategorized';
    // If the transaction has a description, we set that as the title
    if (widget.transaction!.hasDescription) {
      mainTitle = Text(descriptionText);
      // If the transaction has a category as well, we set that as the subtitle
      if (widget.transaction!.category != null) {
        subtitle = Text(categoryText);
      }
    }
    // Otherwise, we set the category text as the title (even if it is "Uncategorized").
    // and we don't set a subtitle
    else {
      mainTitle = Text(categoryText);
    }
    return ListTile(
      leading: widget.transaction!.transactionType == TransactionType.expense ?
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: const Icon(Icons.payments_outlined),
          )
          : Container(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(Icons.savings_outlined, color: Colors.green.shade500),
          ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              mainTitle,
              Text(formatDateTime(widget.transaction!.time), style: TextStyle(fontSize: 13, color: Colors.grey.shade700),),
            ],
          ),
          Text(
            '${widget.transaction!.transactionType == TransactionType.expense ? '' : '+'}\$${formatMoney(widget.transaction!.amount)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.transaction!.transactionType == TransactionType.expense ?
                Theme.of(context).colorScheme.onSurface
                : Colors.green.shade500
            )
          ),
        ],
      ),
      subtitle: subtitle,
      shape: Border(
          bottom: BorderSide(
            color: Colors.grey.shade400,
            width: 1,
          )
      )
    );
  }
}

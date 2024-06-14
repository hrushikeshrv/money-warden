import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_app_bar.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MwAppBar(text: 'Transactions', assetImagePath: 'assets/images/logo.png'),
        Column(
          children: [
            Center(
              child: Text("Transactions Page")
            ),
          ],
        ),
      ],
    );
  }
}

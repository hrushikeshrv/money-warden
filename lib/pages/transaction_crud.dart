import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 20),
          child: Text('Transactions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
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

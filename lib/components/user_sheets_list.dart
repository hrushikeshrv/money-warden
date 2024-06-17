import 'package:flutter/material.dart';


class UserSheetsList extends StatelessWidget {
  const UserSheetsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Padding(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Center(child: Text('Spreadsheets')),
          ]
        ),
      ),
    );
  }
}

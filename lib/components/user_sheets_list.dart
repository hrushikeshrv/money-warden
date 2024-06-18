import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_warning.dart';


class UserSheetsList extends StatelessWidget {
  final List<File> sheets;

  const UserSheetsList({super.key, required this.sheets});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Container(
        padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Heading1(text: 'Your Spreadsheets'),
            SizedBox(height: 10),
            MwWarning(
              children: [
                Text('The sheet you select must be in the correct format for Money Warden to be able to work with it.')
              ]
            )
          ]
        ),
      ),
    );
  }
}

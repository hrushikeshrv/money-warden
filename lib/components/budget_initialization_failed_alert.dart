import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_action_button.dart';

class BudgetInitializationFailedAlert extends StatelessWidget {
  const BudgetInitializationFailedAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('An error occurred'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('An error occurred while fetching data from your connected budget spreadsheet. '),
          const SizedBox(height: 15,),
          const Text('Make sure your budget spreadsheet is in the correct format.'),
          const SizedBox(height: 15,),
          MwActionButton(
            leading: const Icon(Icons.request_page),
            text: "Choose budget spreadsheet",
            onTap: () {
              Navigator.of(context).pushNamed('user_sheets_list');
            }
          )
        ],
      ),
      shadowColor: Colors.grey,
    );
  }
}

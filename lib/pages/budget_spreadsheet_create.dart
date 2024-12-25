import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/services/auth.dart';

class CreateBudgetSpreadsheetPage extends StatefulWidget {
  const CreateBudgetSpreadsheetPage({super.key});

  @override
  State<CreateBudgetSpreadsheetPage> createState() => _CreateBudgetSpreadsheetPageState();
}

class _CreateBudgetSpreadsheetPageState extends State<CreateBudgetSpreadsheetPage> {
  final controller = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Heading1(text: 'Create a Budget Spreadsheet'),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      enabled: !_loading,
                      style: const TextStyle(
                        fontSize: 24
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Spreadsheet Name',
                        border: UnderlineInputBorder()
                      ),
                    ),
                    const SizedBox(height: 20),
                    MwActionButton(
                      leading: const Icon(Icons.add_to_drive_sharp),
                      text: 'Create New Budget Spreadsheet',
                      onTap: () async {
                        if (_loading) return;
                        if (controller.text.trim() == '') return;
                        setState(() {
                          _loading = true;
                        });
                        await budget.createSpreadsheet(controller.text);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      enabled: !_loading,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "A new spreadsheet will be created for the Google account ${AuthService.getUserEmail()}",
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.outline
                        ),
                      ),
                    ),

                    const SizedBox(height: 20,),
                    !_loading ? Container() :
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                            SizedBox(width: 10,),
                            Text("Creating a new spreadsheet")
                          ],
                        )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

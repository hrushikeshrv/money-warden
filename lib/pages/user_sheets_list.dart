import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:money_warden/services/auth.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/components/mw_warning.dart';
import 'package:money_warden/components/spreadsheet_tile.dart';
import 'package:money_warden/pages/budget_spreadsheet_create.dart';
import 'package:money_warden/services/sheets.dart';


class UserSheetsList extends StatefulWidget {
  const UserSheetsList({super.key});

  @override
  State<UserSheetsList> createState() => _UserSheetsListState();
}

class _UserSheetsListState extends State<UserSheetsList> {
  Future<FileList>? sheets;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    sheets = SheetsService.getUserSpreadsheets(null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        List<File> spreadsheets = [];
        if (budget.userSpreadsheets != null) spreadsheets = budget.userSpreadsheets!;

        return Scaffold(
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Heading1(text: 'Your Spreadsheets'),
                  ),
                  const SizedBox(height: 10),
                  const MwWarning(
                    children: [
                      Text('The sheet you select must be in the correct format for Money Warden to be able to work with it.'),
                      SizedBox(height: 20,),
                      Text(
                        'If you haven\'t used Money Warden before, you can create a new budget spreadsheet below'
                      )
                    ]
                  ),
                  const SizedBox(height: 20),
                  MwActionButton(
                    leading: const Icon(Icons.add_to_drive_outlined),
                    text: 'Create a New Budget Spreadsheet',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return const FractionallySizedBox(
                              heightFactor: 0.85,
                              child: CreateBudgetSpreadsheetPage()
                          );
                        }
                      );
                    }
                  ),
                  const SizedBox(height: 20),

                  _loading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                          SizedBox(width: 10,),
                          Text("Connecting your spreadsheet")
                        ],
                      )
                    : Container(),

                  const SizedBox(height: 10),

                  FutureBuilder(
                    future: sheets,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        var sheets = snapshot.data;
                        if (sheets == null || sheets.files == null) {
                          return Text("No spreadsheets found in your account ${AuthService.getUserEmail()}");
                        }
                        budget.userSpreadsheets = sheets.files!;
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return SpreadsheetTile(
                                sheet: sheets.files![index],
                                isSelected: sheets.files![index].id == budget.spreadsheetId,
                                onTap: () async {
                                  setState(() {
                                    _loading = true;
                                  });
                                  await budget.setSpreadsheetName(sheets.files![index].name!);
                                  await budget.setSpreadsheetId(sheets.files![index].id!);
                                  budget.budgetInitializationFailed = false;
                                  await budget.initBudgetData(forceUpdate: true);
                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                            itemCount: spreadsheets.length,
                          ),
                        );
                      }
                      else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }
                  )
                ]
              ),
            ),
          ),
        );
      },
    );
  }
}

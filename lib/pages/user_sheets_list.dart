import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/mw_warning.dart';
import 'package:money_warden/components/spreadsheet_tile.dart';
import 'package:money_warden/services/sheets.dart';


class UserSheetsList extends StatefulWidget {
  const UserSheetsList({super.key});

  @override
  State<UserSheetsList> createState() => _UserSheetsListState();
}

class _UserSheetsListState extends State<UserSheetsList> {
  Future<FileList>? sheets;

  @override
  void initState() {
    super.initState();
    sheets = SheetsService.getUserSpreadsheets(null);
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('The sheet you select must be in the correct format for Money Warden to be able to work with it.')
                ]
              ),
              const SizedBox(height: 20),
              MwActionButton(
                leading: const Icon(Icons.add_to_drive_outlined),
                text: 'Create a New Budget Sheet',
                onTap: () {}
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder(
                  future: sheets,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var sheets = snapshot.data;
                      return Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (_, index) {
                            return SpreadsheetTile(
                              sheet: sheets.files![index],
                              onTap: () {
                                Provider.of<BudgetSheet>(context, listen: false).setSpreadsheetId(sheets.files![index].id!);
                                Provider.of<BudgetSheet>(context, listen: false).setSpreadsheetName(sheets.files![index].name!);
                                // TODO: Update the state of the app to reflect the new chosen sheet.
                                //    Currently requires an app restart to reflect the new chosen sheet.
                                Navigator.of(context).pop();
                              },
                            );
                          },
                          itemCount: sheets!.files!.length,
                        ),
                      );
                    }
                    else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }
                )
              )
            ]
          ),
        ),
      ),
    );
  }
}

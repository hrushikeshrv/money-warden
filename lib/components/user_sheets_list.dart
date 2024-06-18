import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
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
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: FutureBuilder(
        future: sheets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var sheets = snapshot.data;
            return Container(
              padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Heading1(text: 'Your Spreadsheets'),
                  const SizedBox(height: 10),
                  const MwWarning(
                    children: [
                      Text('The sheet you select must be in the correct format for Money Warden to be able to work with it.')
                    ]
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      return SpreadsheetTile(
                        sheet: sheets!.files![index],
                        onTap: () {},
                      );
                    },
                    itemCount: sheets!.files!.length,
                  )
                ]
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading1(text: 'Your Spreadsheets'),
                SizedBox(height: 10),
                Expanded(child: Center(child: CircularProgressIndicator()))
              ]
            ),
          );
        }
      ),
    );
  }
}

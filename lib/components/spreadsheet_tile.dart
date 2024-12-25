import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/pill_container.dart';


/// A tile representing a spreadsheet shown to the user
/// on the "Your Spreadsheets" modal bottom sheet.
/// Takes a File object representing a Google Drive file,
/// and renders it into a ListTile
class SpreadsheetTile extends StatelessWidget {
  final File sheet;
  final bool isSelected;
  final VoidCallback onTap;
  const SpreadsheetTile({
    super.key,
    required this.sheet,
    required this.isSelected,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.request_page),
      title: Text(sheet.name!),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}

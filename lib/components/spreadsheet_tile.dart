import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

import 'package:money_warden/components/pill_container.dart';


/// A tile representing a spreadsheet shown to the user
/// on the "Your Spreadsheets" modal bottom sheet.
/// Takes a File object representing a Google Drive file,
/// and renders it into a ListTile
class SpreadsheetTile extends StatefulWidget {
  final File sheet;
  final VoidCallback onTap;

  const SpreadsheetTile({
    super.key,
    required this.sheet,
    required this.onTap
  });

  @override
  State<SpreadsheetTile> createState() => _SpreadsheetTileState();
}

class _SpreadsheetTileState extends State<SpreadsheetTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.request_page),
      title: Text(widget.sheet.name!),
      trailing: Provider.of<BudgetSheet>(context).spreadsheetId == widget.sheet.id ? const Icon(Icons.check) : null,
      onTap: widget.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: Border(bottom: BorderSide(
          color: Theme.of(context).colorScheme.inverseSurface,
          width: 2
      ))
    );
  }
}

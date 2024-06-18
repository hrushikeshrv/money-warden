import 'package:flutter/material.dart';

import 'package:googleapis/drive/v3.dart';
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
    bool notOwner = widget.sheet.ownedByMe == false;
    bool? shared = widget.sheet.shared;
    bool? starred = widget.sheet.starred;

    List<Widget> subtitleChildren = [];
    if (starred != null && starred) {
      subtitleChildren.add(const Icon(Icons.star, color: Color(0xFFFFD630)));
      subtitleChildren.add(const SizedBox(width: 10));
    }
    if (notOwner) {
      subtitleChildren.add(
        const PillContainer(
          color: Color(0xFFC72F35),
          child: Text("Not owned by you", style: TextStyle(fontSize: 12)),
        )
      );
      subtitleChildren.add(const SizedBox(width: 10));
    }
    if (shared != null && shared) {
      subtitleChildren.add(
        const PillContainer(
          color: Color(0xFFAE429A),
          child: Text("Shared", style: TextStyle(fontSize: 12)),
        )
      );
    }
    else {
      subtitleChildren.add(
        const PillContainer(
          color: Color(0xFF5DAE42),
          child: Text("Private", style: TextStyle(fontSize: 12, color: Colors.white)),
        )
      );
    }

    return ListTile(
      leading: const Icon(Icons.request_page),
      title: Text(widget.sheet.name!),
      subtitle: subtitleChildren.isNotEmpty
          ? Row(children: subtitleChildren,)
          : null,
      onTap: widget.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: Border(bottom: BorderSide(
          color: Theme.of(context).colorScheme.inverseSurface,
          width: 2
      ))
    );
  }
}

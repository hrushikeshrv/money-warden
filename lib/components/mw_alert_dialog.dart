import 'package:flutter/material.dart';

class MwAlertDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  const MwAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.maxFinite,
          minWidth: double.maxFinite,
          maxHeight: MediaQuery.of(context).size.height * 0.6
        ),
        child: content,
      ),
      actions: actions
    );
  }
}

import 'package:flutter/material.dart';


class SettingsTile extends StatefulWidget {
  final Icon leading;
  final VoidCallback onTap;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.leading,
      title: Text(widget.title),
      subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
      trailing: widget.trailing,
      onTap: widget.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: Border(bottom: BorderSide(
        color: Theme.of(context).colorScheme.inverseSurface,
        width: 2
      ))
    );
  }
}

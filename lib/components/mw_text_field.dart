import 'package:flutter/material.dart';
import 'package:money_warden/theme/theme.dart';


class MwTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Icon? labelIcon;
  final String? labelText;
  bool? enabled;

  MwTextField({
    super.key,
    this.labelText,
    this.controller,
    this.labelIcon,
    this.onChanged,
    this.enabled
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MwColors>()!;
    Widget? label;
    if (labelText != null || labelIcon != null) {
      List<Widget> children = [];
      if (labelIcon != null) {
        children.add(labelIcon!);
        children.add(const SizedBox(width: 5));
      }
      if (labelText != null) {
        children.add(Text(labelText!, style: TextStyle(color: colors.mutedText)));
      }
      label = Row(
        children: children,
      );
    }

    return TextField(
      enabled: enabled,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide(color: colors.backgroundDark1, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          label: label,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: colors.backgroundDark1,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0)
      ),
    );
  }
}

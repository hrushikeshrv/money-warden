import 'package:flutter/material.dart';


class CurrencyTile extends StatelessWidget {
  final String currencyName;
  final String currencySymbol;
  final String currencyCode;
  final bool isSelected;
  final VoidCallback onTap;

  const CurrencyTile({
    super.key,
    required this.currencyName,
    required this.currencySymbol,
    required this.currencyCode,
    required this.isSelected,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(currencySymbol, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      title: Text(currencyName, style: const TextStyle(fontSize: 14)),
      subtitle: Text(currencyCode),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}

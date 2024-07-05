import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/currency_tile.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/utils/currencies.dart';


class ChooseDefaultCurrencyPage extends StatefulWidget {
  const ChooseDefaultCurrencyPage({super.key});

  @override
  State<ChooseDefaultCurrencyPage> createState() => _ChooseDefaultCurrencyPageState();
}

class _ChooseDefaultCurrencyPageState extends State<ChooseDefaultCurrencyPage> {
  final controller = TextEditingController();
  var _currencies = List.from(currencies);

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Heading1(text: 'Choose Default Currency'),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search for currencies',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 2)
                  )
                )
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _currencies.length,
                  itemBuilder: (context, index) {
                    return CurrencyTile(
                      currencyName: _currencies[index]['name'],
                      currencySymbol: _currencies[index]['symbol'],
                      currencyCode: _currencies[index]['code'],
                      isSelected: _currencies[index]['code'] == budget.defaultCurrencyCode,
                    );
                  }
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

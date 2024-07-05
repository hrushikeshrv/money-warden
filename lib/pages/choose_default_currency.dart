import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_form_label.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/models/budget_sheet.dart';


class ChooseDefaultCurrencyPage extends StatelessWidget {
  const ChooseDefaultCurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        return const Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Heading1(text: 'Choose Default Currency'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

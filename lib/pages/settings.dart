import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/services/auth.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/settings_tile.dart';
import 'package:money_warden/components/mw_app_bar.dart';
import 'package:money_warden/models/budget_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userPhotoUrl = AuthService.getUserPhotoUrl();

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSheet>(
      builder: (context, budget, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MwAppBar(
                assetImagePath: 'assets/images/logo.png',
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Text("Settings", style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
                )
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Heading1(text: 'Spreadsheet & Account'),
                    SettingsTile(
                      leading: const Icon(Icons.sync),
                      title: 'Refresh',
                      subtitle: 'Sync data with linked Google Sheet',
                      onTap: () {},
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.request_page),
                      title: 'Choose Google Sheet',
                      subtitle: 'Choose the sheet to write budget data to',
                      onTap: () {
                        Navigator.of(context).pushNamed('user_sheets_list');
                      },
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.logout),
                      title: 'Log Out',
                      subtitle: 'Log out of your Google account (${AuthService
                          .getUserEmail()})',
                      onTap: () async {
                        await AuthService.signOut();
                      },
                      trailing: userPhotoUrl != null ? CircleAvatar(
                          backgroundImage: NetworkImage(userPhotoUrl!),
                          radius: 25) : null,
                    ),

                    const SizedBox(height: 20),
                    const Heading1(text: 'Categories'),
                    SettingsTile(
                      leading: Icon(Icons.list, color: Theme
                          .of(context)
                          .colorScheme
                          .error),
                      title: 'Manage Expense Categories',
                      subtitle: 'Create or update expense categories',
                      onTap: () {
                        Navigator.of(context).pushNamed('expense_categories_list');
                      },
                    ),
                    SettingsTile(
                      leading: Icon(Icons.list, color: Theme
                          .of(context)
                          .colorScheme
                          .primary),
                      title: 'Manage Income Categories',
                      subtitle: 'Create or update income categories',
                      onTap: () {
                        Navigator.of(context).pushNamed('income_categories_list');
                      },
                    ),

                    const SizedBox(height: 20),
                    const Heading1(text: 'Preferences'),
                    SettingsTile(
                      leading: const Icon(Icons.attach_money),
                      title: 'Default Currency',
                      subtitle: 'Choose your default currency',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}

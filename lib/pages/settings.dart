import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/services/auth.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/settings_tile.dart';
import 'package:money_warden/components/mw_app_bar.dart';
import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/pages/choose_default_currency.dart';
import 'package:money_warden/pages/add_budget_month_to_spreadsheet.dart';

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
        print("\n---\nIn settings page. Spreadsheet name ${budget.spreadsheetName}");
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MwAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Heading1(text: 'Preferences'),
                    SettingsTile(
                      leading: const Icon(Icons.attach_money),
                      title: 'Default Currency',
                      subtitle: 'Choose your default currency',
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return const FractionallySizedBox(
                              heightFactor: 0.85,
                              child: ChooseDefaultCurrencyPage()
                            );
                          }
                        );
                      },
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.payment),
                      title: 'Manage Payment Methods',
                      subtitle: 'Add or remove payment methods',
                      onTap: () {
                        Navigator.of(context).pushNamed('payment_methods_list');
                      },
                    ),
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
                    const Heading1(text: 'Spreadsheet & Account'),
                    SettingsTile(
                      leading: const Icon(Icons.sync),
                      title: 'Refresh',
                      subtitle: 'Sync data with linked Google Sheet',
                      onTap: () {},
                    ),
                    SettingsTile(
                        leading: const Icon(Icons.edit_calendar_rounded),
                        title: 'Add Month To Budget',
                        subtitle: 'Add a new month to the current budget',
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return const FractionallySizedBox(
                                    heightFactor: 0.85,
                                    child: AddBudgetMonthToSpreadsheetPage()
                                );
                              }
                          );
                        }
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.request_page),
                      title: 'Choose Budget Spreadsheet',
                      subtitle: 'Choose the sheet to write budget data to${budget.spreadsheetName != null ? ". (Currently ${budget.spreadsheetName})" : ""}',
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
                    const Heading1(text: 'Help & Support'),
                    SettingsTile(
                      leading: const Icon(Icons.support),
                      title: 'Usage Guide',
                      subtitle: 'A short guide to help you get started',
                      onTap: () {}
                    ),
                    SettingsTile(
                      leading: Icon(Icons.bug_report, color: Theme.of(context).colorScheme.error),
                      title: 'Report an Issue',
                      subtitle: 'Let us know about any bugs!',
                      onTap: () {}
                    ),
                    SettingsTile(
                        leading: Icon(Icons.history_edu, color: Theme.of(context).colorScheme.primary),
                        title: 'Request a Feature',
                        subtitle: 'Request new features for Money Warden!',
                        onTap: () {}
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.lock),
                      title: 'Privacy Policy',
                      subtitle: 'Read Money Warden\'s Privacy Policy',
                      onTap: () {},
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.description),
                      title: 'Terms of Service',
                      subtitle: 'Read Money Warden\'s Terms of Service',
                      onTap: () {},
                    )
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

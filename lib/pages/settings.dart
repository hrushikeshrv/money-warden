import 'package:flutter/material.dart';

import 'package:money_warden/services/auth.dart';
import 'package:money_warden/components/heading1.dart';
import 'package:money_warden/components/settings_tile.dart';
import 'package:money_warden/components/mw_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userPhotoUrl = AuthService.getUserPhotoUrl();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MwAppBar(text: 'Settings', assetImagePath: 'assets/images/logo.png'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Heading1(text: 'Account'),
              SettingsTile(
                leading: const Icon(Icons.sync),
                title: 'Sync',
                subtitle: 'Sync data with linked Google Sheet',
                onTap: () {},
              ),
              SettingsTile(
                leading: const Icon(Icons.request_page),
                title: 'Choose Google Sheet',
                subtitle: 'Choose the sheet to write budget data to',
                onTap: () {},
              ),
              SettingsTile(
                leading: const Icon(Icons.logout),
                title: 'Log Out',
                subtitle: 'Log out of your Google account (${AuthService.getUserEmail()})',
                onTap: () {},
                trailing: userPhotoUrl != null ? CircleAvatar(backgroundImage: NetworkImage(userPhotoUrl!), radius: 25) : null,
              ),

              const Heading1(text: 'Categories'),
              SettingsTile(
                leading: Icon(Icons.list, color: Theme.of(context).colorScheme.error),
                title: 'Manage Transaction Categories',
                subtitle: 'Create or update transaction categories',
                onTap: () {},
              ),
              SettingsTile(
                leading: Icon(Icons.list, color: Theme.of(context).colorScheme.primary),
                title: 'Manage Income Categories',
                subtitle: 'Create or update income categories',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

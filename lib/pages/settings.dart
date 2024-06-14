import 'package:flutter/material.dart';
import 'package:money_warden/components/mw_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MwAppBar(text: 'Settings', assetImagePath: 'assets/images/logo.png'),
        Column(
          children: [
            Center(
                child: Text("Settings")
            ),
          ],
        ),
      ],
    );
  }
}

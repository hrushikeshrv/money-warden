import 'package:flutter/material.dart';

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
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 20),
          child: Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
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

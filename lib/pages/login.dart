import 'package:flutter/material.dart';

import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/services/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', height: 120),
                    const Text('Money Warden', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Center(child: Text("Welcome to Money Warden", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MwActionButton(
                      leading: Image.asset('assets/images/google-g.png', height: 30),
                      text: 'Log In Using Your Google Account',
                      onTap: () async {
                        await AuthService.signIn();
                      }
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:money_warden/services/auth.dart';
import 'package:money_warden/components/mw_action_button.dart';
import 'package:money_warden/pages/budget_spreadsheet_create.dart';


class InstructionsPage extends StatelessWidget {
  const InstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/logo.png', height: 120),
              const Text('Money Warden', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              const SizedBox(height: 5),
              Center(child: Text("Welcome to Money Warden", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              const Center(
                child: Text("To get started, choose a spreadsheet from your Google Drive", textAlign: TextAlign.center,)
              ),
              const SizedBox(height: 10),
              MwActionButton(
                leading: const Icon(Icons.add_to_drive_sharp),
                text: 'Choose Budget Spreadsheet',
                onTap: () {
                  Navigator.of(context).pushNamed('user_sheets_list');
                }
              ),
              const SizedBox(height: 20),
              const Center(
                  child: Text("Or create a new one below")
              ),
              const SizedBox(height: 10),
              MwActionButton(
                leading: const Icon(Icons.add_to_drive_sharp),
                text: 'Create New Budget Spreadsheet',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return const FractionallySizedBox(
                        heightFactor: 0.85,
                        child: CreateBudgetSpreadsheetPage()
                      );
                    }
                  );
                }
              ),

              const SizedBox(height: 40),
              Text('You are signed in as ${AuthService.getUserEmail()}', textAlign: TextAlign.center,),
              const SizedBox(height: 10),
              MwActionButton(
                leading: CircleAvatar(backgroundImage: NetworkImage(AuthService.getUserPhotoUrl()!), radius: 15,),
                role: 'warning',
                text: 'Sign Out',
                onTap: () async {
                  await AuthService.signOut();
                }
              )
            ],
          )
        ),
      )
    );
  }
}

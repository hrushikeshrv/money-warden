import 'package:flutter/material.dart';


class SplashScreen extends StatelessWidget {
  final String? message;
  const SplashScreen({ super.key, this.message });

  @override
  Widget build(BuildContext context) {
    String splashMessage = "Loading";
    if (message != null) {
      splashMessage = message!;
    }
    return Scaffold(
      backgroundColor: Theme
        .of(context)
        .colorScheme
        .surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/logo.png', height: 120),
              const Text('Money Warden', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              const SizedBox(height: 5),
              Center(child: Text(splashMessage, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            ],
          )
        ),
      )
    );
  }
}

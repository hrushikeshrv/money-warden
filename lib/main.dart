import 'package:flutter/material.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:money_warden/pages/splash_screen.dart';

import 'package:money_warden/services/auth.dart';
import 'package:money_warden/pages/login.dart';
import 'package:money_warden/theme/theme.dart';
import 'package:money_warden/pages/analytics.dart';
import 'package:money_warden/pages/homepage.dart';
import 'package:money_warden/pages/settings.dart';
import 'package:money_warden/pages/transaction_crud.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MoneyWarden());
}

class MoneyWarden extends StatefulWidget {
  const MoneyWarden({super.key});

  @override
  State<MoneyWarden> createState() => _MoneyWardenState();
}

class _MoneyWardenState extends State<MoneyWarden> {
  GoogleSignInAccount? _currentUser;
  Future<GoogleSignInAccount?>? _previousUser;

  final List pages = [
    const HomePage(),
    const TransactionsPage(),
    const AnalyticsPage(),
    const SettingsPage(),
  ];

  int currentPage = 0;

  void navigateBottomBar(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _previousUser = AuthService.googleSignIn.signInSilently();
    AuthService.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      setState(() {
        _currentUser = account;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: defaultColorScheme,
      ),
      routes: {
        'homepage': (context) => const HomePage(),
        'login': (context) => const LoginPage(),
        'transactions': (context) => const TransactionsPage(),
        'analytics': (context) => const AnalyticsPage(),
        'settings': (context) => const SettingsPage(),
      },
      home: FutureBuilder(
        future: _previousUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Builder(
              builder: (context) {
                final GoogleSignInAccount? user = _currentUser;
                if (user != null) {
                  return Scaffold(
                    backgroundColor: Theme
                        .of(context)
                        .colorScheme
                        .surface,
                    bottomNavigationBar: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: GNav(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .secondary,
                          activeColor: Theme
                              .of(context)
                              .colorScheme
                              .onPrimary,
                          tabBackgroundColor: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 17),
                          gap: 7,
                          onTabChange: (index) => navigateBottomBar(index),
                          tabs: const [
                            GButton(icon: Icons.home, text: "Home"),
                            GButton(icon: Icons.monetization_on,
                                text: "Transactions"),
                            GButton(
                                icon: Icons.auto_graph, text: "Summary"),
                            GButton(icon: Icons.settings, text: "Settings")
                          ]
                      ),
                    ),
                    body: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: pages[currentPage],
                      ),
                    ),
                  );
                }
                else {
                  return Scaffold(
                    backgroundColor: Theme
                        .of(context)
                        .colorScheme
                        .surface,
                    body: const SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: LoginPage(),
                        )
                    ),
                  );
                }

              }
            );
          }
          else {
            return const SplashScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

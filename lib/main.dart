import 'package:flutter/material.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/pages/login.dart';
import 'package:money_warden/pages/analytics.dart';
import 'package:money_warden/pages/homepage.dart';
import 'package:money_warden/pages/settings.dart';
import 'package:money_warden/pages/splash_screen.dart';
import 'package:money_warden/pages/transaction_crud.dart';
import 'package:money_warden/pages/user_sheets_list.dart';
import 'package:money_warden/services/auth.dart';
import 'package:money_warden/theme/theme.dart';

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
  Future<Map<String, dynamic>>? _previousAuth;

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
    _previousAuth = AuthService.initializeAuth();
    AuthService.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      setState(() {
        _currentUser = account;
      });
    });
  }

  /// First tries to sign the user in silently and shows a splash screen
  /// while doing that. If silent sign in is successful, we show the homepage,
  /// otherwise, we show the login page.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BudgetSheet>(
      create: (context) => BudgetSheet(
        spreadsheetId: null,
        spreadsheetName: null,
        sharedPreferences: null,
      ),
      child: Consumer<BudgetSheet>(
        builder: (context, budget, _) => MaterialApp(
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
            'user_sheets_list': (context) => const UserSheetsList(),
          },
          // Try to sign the user in silently and show the splash screen in the
          // mean time
          home: FutureBuilder(
            future: _previousAuth,
            builder: (context, snapshot) {
              // If silent sign in request was completed, show either the
              // homepage or the login page depending on whether the silent
              // sign in request was successful.
              if (snapshot.hasData) {
                return Builder(
                  builder: (context) {
                    final GoogleSignInAccount? user = _currentUser;
                    if (user != null) {
                      budget.spreadsheetId = snapshot.data!['spreadsheetId'];
                      budget.spreadsheetName = snapshot.data!['spreadsheetName'];
                      budget.sharedPreferences = snapshot.data!['sharedPreferences'];
                      budget.getBudgetMonths();

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
                              GButton(icon: Icons.monetization_on, text: "Transactions"),
                              GButton(icon: Icons.auto_graph, text: "Summary"),
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
        ),
      ),
    );
  }
}

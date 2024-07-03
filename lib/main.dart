import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:money_warden/pages/transaction_categories_list.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/pages/login.dart';
import 'package:money_warden/pages/analytics.dart';
import 'package:money_warden/pages/homepage.dart';
import 'package:money_warden/pages/settings.dart';
import 'package:money_warden/pages/splash_screen.dart';
import 'package:money_warden/pages/transactions.dart';
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
            'expense_categories_list': (context) => const TransactionCategoriesList(transactionType: TransactionType.expense),
            'income_categories_list': (context) => const TransactionCategoriesList(transactionType: TransactionType.income),
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

                      // TODO: Check if a spreadsheet has been selected and show users an instructions page if not.
                      if (
                        snapshot.data!['spreadsheetId'] != null
                        && snapshot.data!['spreadsheetId'] != ''
                      ) {
                        budget.initBudgetData();
                      }
                      else {
                        // Redirect users to instructions page.
                      }

                      return Scaffold(
                        backgroundColor: Theme
                            .of(context)
                            .colorScheme
                            .surface,
                        bottomNavigationBar: NavigationBar(
                          destinations: const [
                            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                            NavigationDestination(icon: Icon(Icons.monetization_on), label: 'Transactions'),
                            NavigationDestination(icon: Icon(Icons.auto_graph), label: 'Analytics'),
                            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings')
                          ],
                          selectedIndex: currentPage,
                          onDestinationSelected: navigateBottomBar,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                        floatingActionButton: FloatingActionButton(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          onPressed: () {},
                          child: Icon(Icons.payments_outlined, color: Theme.of(context).colorScheme.onSurface),
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

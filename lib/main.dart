import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:money_warden/pages/instructions.dart';
import 'package:money_warden/pages/payment_method_list.dart';
import 'package:money_warden/pages/terms_of_service.dart';
import 'package:money_warden/pages/transaction_add.dart';
import 'package:money_warden/pages/transaction_category_list.dart';
import 'package:money_warden/services/sheets.dart';
import 'package:money_warden/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:money_warden/models/budget_sheet.dart';
import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/pages/login.dart';
import 'package:money_warden/pages/analytics/analytics_homepage.dart';
import 'package:money_warden/pages/homepage.dart';
import 'package:money_warden/pages/settings.dart';
import 'package:money_warden/pages/splash_screen.dart';
import 'package:money_warden/pages/transaction_list.dart';
import 'package:money_warden/pages/user_sheets_list.dart';
import 'package:money_warden/pages/privacy_policy.dart';
import 'package:money_warden/services/auth.dart';
import 'package:money_warden/theme/theme.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "MoneyWarden",
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
  Future<Map<String, dynamic>>? _previousAuth;
  Future<Map<String, dynamic>>? _spreadsheetPrefs;

  final List pages = [
    const HomePage(),
    const TransactionAddPage(initialTransactionType: TransactionType.expense),
    const AnalyticsHomepage(),
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
    _spreadsheetPrefs = SheetsService.initializeSpreadsheetPrefs();
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
          theme: defaultTheme,
          routes: {
            'homepage': (context) => const HomePage(),
            'login': (context) => const LoginPage(),
            'transactions': (context) => const TransactionsPage(),
            'analytics': (context) => const AnalyticsHomepage(),
            'settings': (context) => const SettingsPage(),
            'user_sheets_list': (context) => const UserSheetsList(),
            'expense_categories_list': (context) => const TransactionCategoryListPage(transactionType: TransactionType.expense),
            'income_categories_list': (context) => const TransactionCategoryListPage(transactionType: TransactionType.income),
            'payment_methods_list': (context) => const PaymentMethodListPage(),
            'privacy_policy': (context) => const PrivacyPolicyPage(),
            'tos': (context) => const TermsOfServicePage(),
          },
          // Try to sign the user in silently and show the splash screen in the
          // mean time
          home: FutureBuilder(
            future: _previousAuth,
            builder: (context, authSnapshot) {
              // If silent sign in request was completed, show either the
              // homepage or the login page depending on whether the silent
              // sign in request was successful.
              if (authSnapshot.hasData && !budget.manuallyLoggedOut) {
                return FutureBuilder(
                  future: _spreadsheetPrefs,
                  builder: (context, spreadsheetSnapshot) {
                    if (spreadsheetSnapshot.hasData) {
                      if (AuthService.currentUser != null) {
                        var prefs = authSnapshot.data!['sharedPreferences'];
                        budget.spreadsheetId = prefs.getString('spreadsheetId');
                        budget.spreadsheetName = prefs.getString('spreadsheetName');
                        budget.sharedPreferences = authSnapshot.data!['sharedPreferences'];
                        budget.userSpreadsheets = authSnapshot.data!['spreadsheets'];

                        if (
                          budget.spreadsheetId != null
                          && budget.spreadsheetId != ''
                          && !budget.budgetInitializationFailed
                        ) {
                          budget.initBudgetData();
                        }
                        else if (!budget.budgetInitializationFailed) {
                          return const InstructionsPage();
                        }

                        return Scaffold(
                          backgroundColor: Theme
                              .of(context)
                              .colorScheme
                              .surface,
                          bottomNavigationBar: NavigationBar(
                            destinations: const [
                              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                              NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Add'),
                              NavigationDestination(icon: Icon(Icons.auto_graph), label: 'Analytics'),
                              NavigationDestination(icon: Icon(Icons.settings), label: 'Settings')
                            ],
                            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                            selectedIndex: currentPage,
                            onDestinationSelected: navigateBottomBar,
                            indicatorColor: Theme.of(context).colorScheme.primary,
                            height: 60,
                          ),
                          body: Material(
                            color: Theme.of(context).colorScheme.surface,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: pages[currentPage],
                              ),
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
                    else {
                      return const SplashScreen(message: "Fetching Budget Data");
                    }
                  }
                );
              }
              else if (budget.manuallyLoggedOut) {
                return LoginPage();
              }
              else {
                return const SplashScreen(message: "Signing In");
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

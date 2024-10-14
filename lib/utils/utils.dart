import 'dart:math';
import 'package:flutter/material.dart';

import 'package:money_warden/models/transaction.dart';
import 'package:money_warden/pages/transaction_add.dart';

List<Color> mwColors = const [
  Color(0xFFE53935),
  Color(0xFFD81B60),
  Color(0xFF8E24AA),
  Color(0xFF673AB7),
  Color(0xFF1E88E5),
  Color(0xFF039BE5),
  Color(0xFF00ACC1),
  Color(0xFF43A047),
  Color(0xFF7CB342),
  Color(0xFFFB8C00),
  Color(0xFFF4511E),
  Color(0xFF757575),
];

/// Parses a stored color string and returns a Color
/// object.
Color parseStoredColorString(String color) {
  int value = int.parse(color.split('0x')[1].split(')')[0], radix: 16);
  return Color(value);
}

/// Returns true if the title is a String of the format
/// \<MonthName\> \<YearName\>. The month name can be in
/// short form (Jan) or long form (January). The year must
/// be a number
bool isMonthName(String title) {
  // TODO: add tests
  List<String> monthNames = [
    'Jan', 'January',
    'Feb', 'February',
    'Mar', 'March',
    'Apr', 'April',
    'May',
    'Jun', 'June',
    'Jul', 'July',
    'Aug', 'August',
    'Sep', 'Sept', 'September',
    'Oct', 'October',
    'Nov', 'November',
    'Dec', 'December',
  ];
  List<String> _ = title.split(' ');
  if (_.length != 2) return false;
  var year = double.tryParse(_[1]);
  bool validYear = (year != null && year >= 1970 && year <= 2100);
  return (monthNames.contains(_[0]) && validYear);
}


/// Returns true if the passed value is a number
bool isNumber(String value) {
  RegExp numeric = RegExp(r'^[0-9]+\.?[0-9]*$');
  return numeric.hasMatch(value);
}


/// Takes a DateTime object and returns the name of the
/// month to use as an index into the global `BudgetSheet`'s
/// month names list. If `shortForm` is true, returns the
/// month name in short form ("Sept"). Otherwise returns the
/// month name in long form ("September").
String getMonthNameFromDate(DateTime date, bool shortForm) {
  List<String> shortMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'
  ];
  List<String> longMonthNames = [
    'January', 'February', 'March', 'April', 'May',
    'June', 'July', 'August', 'September', 'October',
    'November', 'December'
  ];
  return '${shortForm ? shortMonthNames[date.month-1] : longMonthNames[date.month-1]} ${date.year}';
}

/// Takes a month name and returns a DateTime object
/// for the first date in the month. For e.g, returns
/// `DateTime(2024, 10, 1)` for `"October 2024"` or `"Oct 2024"`.
DateTime getDateFromMonthName(String monthName) {
  List<String> shortMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'
  ];
  List<String> longMonthNames = [
    'January', 'February', 'March', 'April', 'May',
    'June', 'July', 'August', 'September', 'October',
    'November', 'December'
  ];
  String _month = monthName.split(' ')[0];
  int year = int.parse(monthName.split(' ')[1]);
  late int month;
  if (shortMonthNames.contains(_month)) {
    month = shortMonthNames.indexOf(_month) + 1;
  }
  else if (longMonthNames.contains(_month)) {
    month = longMonthNames.indexOf(_month) + 1;
  }
  else {
    throw Exception("Unknown month $monthName passed to getDateFromMonthName");
  }
  return DateTime(year, month, 1);
}


/// Takes a DateTime object and returns the date for the first
/// day of that month
DateTime getFirstDateOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

/// Takes a DateTime object and returns the date for the last
/// day of that month
DateTime getLastDateOfMonth(DateTime date) {
  if (date.month < 12) {
    return DateTime(date.year, date.month + 1, 0);
  }
  return DateTime(date.year + 1, 1, 0);
}


/// Takes a list of budget months and returns the
/// current month if it exists in the list of budget months.
/// Otherwise, returns the month closest to the current month.
String getCurrentOrClosestMonth(List<String> budgetMonths) {
  // TODO: add tests
  DateTime closest = getDateFromMonthName(budgetMonths[0]);
  DateTime now = DateTime.now();
  // now = DateTime(now.year, now.month+1, 1);
  String closestMonthName = budgetMonths[0];
  int closestDifference = (now.difference(closest).inHours / 24).round().abs();

  for (var month in budgetMonths) {
    var from = getDateFromMonthName(month);
    if (from.month == now.month && from.year == now.year) {
      return month;
    }
    if ((now.difference(from).inHours / 24).round().abs() < closestDifference) {
      closest = from;
      closestDifference = (now.difference(from).inHours / 24).round().abs();
      closestMonthName = month;
    }
  }
  return closestMonthName;
}


/// Parses a date in the format \<date> \<Month> \<Year> and
/// returns a DateTime object. Also tries to parse dates in
/// other formats but support for all formats is not guaranteed.
/// If an exception occurs while parsing the date, returns 1 January 1970.
///
/// An example of a valid date format is -
/// 23 May 2024
/// 23/05/2024
DateTime parseDate(String date) {
  // TODO: add tests
  var months = {
    'Jan': '01', 'January': '01',
    'Feb': '02', 'February': '02',
    'Mar': '03', 'March': '03',
    'Apr': '04', 'April': '04',
    'May': '05',
    'Jun': '06', 'June': '06',
    'Jul': '07', 'July': '07',
    'Aug': '08', 'August': '08',
    'Sept': '09', 'September': '09',
    'Oct': '10', 'October': '10',
    'Nov': '11', 'November': '11',
    'Dec': '12', 'December': '12'
  };
  String formattedDate = '';
  if (date.indexOf('/') > 0) {
    formattedDate = date.replaceAll('/', '-');
    formattedDate = formattedDate.split('').reversed.join('');
  }
  else {
    var splitDate = date.split(' ');
    formattedDate = '${splitDate[2]}-${months[splitDate[1]]}-';
    if (splitDate[0].length == 1) {
      formattedDate += '0${splitDate[0]}';
    }
    else {
      formattedDate += splitDate[0];
    }
  }
  try {
    return DateTime.parse(formattedDate);
  }
  catch(e) {
    return DateTime(1970, 1, 1);
  }
}


/// Parses an amount from the sheet which may have custom formatting
/// (such as a currency prefix or commas), and returns a double.
double parseAmount(String amount) {
  // TODO: add tests
  amount = amount.replaceAll(',', '');
  if (!['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(amount[0])) {
    amount = amount.substring(1);
  }
  try {
    return double.parse(amount);
  }
  catch(e) {
    return 0.0;
  }
}


/// Formats a double as an amount by inserting commas
/// in the right places
String formatMoney(double amount) {
  // TODO: add tests
  List<String> result = [];
  var characters = amount.toString().split('.')[0].split('').reversed.toList();
  for (int i = 0; i < characters.length; i++) {
    result.add(characters[i]);
    if (i > 0 && i < characters.length - 1 && (i + 1) % 3 == 0) {
      result.add(',');
    }
  }
  String stringResult = result.reversed.join('');
  if (amount.toString().split('.').length > 1) {
    var cents = amount.toString().split('.')[1];
    if (cents.length > 2) { cents = cents.substring(0, 2); }
    stringResult += '.$cents';
  }
  return stringResult;
}

/// Formats a DateTime object into a friendly string
String formatDateTime(DateTime dateTime) {
  // TODO: add tests
  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];
  List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  // If the passed date time was 1970-1-1, there was an error parsing the
  // date from the source.
  if (dateTime.year == 1970 && dateTime.month == 1 && dateTime.day == 1) {
    return 'Unrecognized Date';
  }
  return '${weekdays[dateTime.weekday-1]}, ${dateTime.day} ${months[dateTime.month-1]} ${dateTime.year}';
}


/// Returns a random material-like color
Color getRandomGraphColor() {
  return mwColors[Random().nextInt(mwColors.length)];
}


/// Shows a modal bottom sheet for adding or updating a transaction
void showAddTransactionBottomSheet({
  required BuildContext context,
  required TransactionType transactionType,
  bool updateTransaction = false,
  Transaction? initialTransaction
}) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: AddTransactionPage(
            initialTransactionType: transactionType,
            updateTransaction: updateTransaction,
            initialTransaction: initialTransaction,
          ),
        );
      }
  );
}
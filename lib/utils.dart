/// Returns true if the title is a String of the format
/// \<MonthName\> \<YearName\>. The month name can be in
/// short form (Jan) or long form (January). The year must
/// be a number
bool isMonthName(String title) {
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
  return (
    _.length == 2
    && monthNames.contains(_[0])
    && double.tryParse(_[1]) != null
  );
}


/// Takes a list of budget months and returns the
/// current month if it exists in the list of budget months.
/// Otherwise, returns the month closest to the current month.
String getCurrentOrClosestMonth(List<String> budgetMonths) {
  return budgetMonths[0];
}


/// Parses a date in the format \<date> \<Month> \<Year> and
/// returns a DateTime object. Also tries to parse dates in
/// other formats but support for all formats is not guaranteed.
/// Throws a FormatException if the date cannot be parsed.
///
/// An example of a valid date format is -
/// 23 May 2024
/// 23/05/2024
DateTime parseDate(String date) {
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
  return DateTime.parse(formattedDate);
}


/// Parses an amount from the sheet which may have custom formatting
/// (such as a currency prefix or commas), and returns a double.
double parseAmount(String amount) {
  amount = amount.replaceAll(',', '');
  if (!['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(amount[0])) {
    amount = amount.substring(1);
  }
  return double.parse(amount);
}
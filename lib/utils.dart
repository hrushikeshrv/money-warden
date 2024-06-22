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
  return '';
}
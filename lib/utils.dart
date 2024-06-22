/// Returns true if the title is a String of the format
/// \<MonthName\> \<YearName\>. The month name can be in
/// short form (Jan) or long form (January). The year must
/// be a number
bool isMonthName(String title) {
  List<String> monthNames = [
    'Jan', 'January',
    'Feb', 'February',

  ];
  List<String> _ = title.split(' ');
  return (
    _.length == 2
    && monthNames.contains(_[0])
    && double.tryParse(_[1]) != null
  );
}
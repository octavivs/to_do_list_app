// ---
// UTILITY: formatters.dart
// ---
// OOP CONCEPT: Utility Class
// A collection of static methods dedicated to transforming data into
// human-readable formats.

class Formatters {
  // Formats a DateTime object into a friendly string (e.g., "Mar 8, 2026")
  static String formatDate(DateTime date) {
    // We use a constant list to map the month integer (1-12) to its short name.
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    // Arrays in Dart are zero-indexed, so we subtract 1 from the month number.
    final String monthName = months[date.month - 1];
    final String day = date.day.toString();
    final String year = date.year.toString();

    // String interpolation allows us to inject variables directly into the text
    return '$monthName $day, $year';
  }
}

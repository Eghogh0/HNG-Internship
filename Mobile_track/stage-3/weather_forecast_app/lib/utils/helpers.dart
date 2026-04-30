import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime dt) {
    return DateFormat('EEE, MMM d').format(dt);
  }

  static String formatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  static String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
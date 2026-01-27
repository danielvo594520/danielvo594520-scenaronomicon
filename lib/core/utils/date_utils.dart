import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateTimeFormat = DateFormat('yyyy/MM/dd HH:mm');
  static final _dateFormat = DateFormat('yyyy/MM/dd');

  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);
  static String formatDate(DateTime dt) => _dateFormat.format(dt);
}

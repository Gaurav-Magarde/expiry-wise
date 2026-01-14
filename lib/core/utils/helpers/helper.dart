import 'package:intl/intl.dart';

class Helper{

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹ ',
        decimalDigits: 0
    );
    return formatter.format(amount);
  }

  static String titleCase(String title) {
   return title[0].toUpperCase()+title.substring(1).toLowerCase();
  }
}
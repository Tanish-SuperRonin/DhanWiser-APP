import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatterCompact = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _formatterDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format as integer if no decimal part, otherwise with 2 decimals
  static String format(num amount) {
    if (amount == amount.toInt()) {
      return _formatterCompact.format(amount);
    }
    return _formatterDecimal.format(amount);
  }

  /// Always format with 2 decimals
  static String formatDecimal(num amount) {
    return _formatterDecimal.format(amount);
  }

  /// Always format as integer
  static String formatCompact(num amount) {
    return _formatterCompact.format(amount);
  }
}

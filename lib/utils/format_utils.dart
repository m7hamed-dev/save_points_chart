/// Utility functions for formatting chart values.
class ChartFormatUtils {
  /// Formats a double value to a string.
  /// If the value is effectively an integer (e.g. 10.0), it returns "10".
  /// Otherwise, it returns the value as a string with up to [fractionDigits] decimal places.
  /// Trailing zeros are removed.
  static String formatValue(double value, {int fractionDigits = 2}) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    
    // Convert to string with fixed precision
    String str = value.toStringAsFixed(fractionDigits);
    
    // Remove trailing zeros and decimal point if needed
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0*$'), '');
      if (str.endsWith('.')) {
        str = str.substring(0, str.length - 1);
      }
    }
    return str;
  }
}

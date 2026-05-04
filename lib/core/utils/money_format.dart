import 'package:flutter/services.dart';

String formatMoneyWithCommas(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

int parseMoneyFromCommas(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 0;
  return int.parse(digits);
}

class MoneyInputFormatter extends TextInputFormatter {
  const MoneyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatMoneyWithCommas(newValue.text);
    if (formatted == newValue.text) return newValue;

    final selectionEnd = newValue.selection.end.clamp(0, newValue.text.length);
    int digitsBeforeCursor = 0;
    for (int i = 0; i < selectionEnd; i++) {
      final code = newValue.text.codeUnitAt(i);
      if (code >= 0x30 && code <= 0x39) digitsBeforeCursor++;
    }

    int newOffset = 0;
    int seen = 0;
    while (newOffset < formatted.length && seen < digitsBeforeCursor) {
      final code = formatted.codeUnitAt(newOffset);
      if (code >= 0x30 && code <= 0x39) seen++;
      newOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

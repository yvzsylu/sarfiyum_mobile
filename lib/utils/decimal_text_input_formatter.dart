import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Noktayı virgüle çevir
    String newText = newValue.text.replaceAll('.', ',');

    // 2. Sadece rakam ve virgüle izin ver
    if (newText.contains(RegExp(r'[^0-9,]'))) {
      return oldValue;
    }

    // 3. Birden fazla virgül kontrolü
    if (','
            .allMatches(newText)
            .length > 1) {
      return oldValue;
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
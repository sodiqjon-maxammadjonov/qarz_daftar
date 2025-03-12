import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;

  const NumberTextField({
    super.key,
    required this.controller,
    this.label = 'Miqdorni kiriting',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        AmountInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        hintText: '1 000 000',
      ),
      onChanged: onChanged,
    );
  }
}

class AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Faqat raqamlarni olamiz
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Raqamlarni o'ngdan chapga uchlab ajratamiz
    String result = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && (digitsOnly.length - i) % 3 == 0) {
        result += ' ';
      }
      result += digitsOnly[i];
    }

    // Kursorni to'g'ri pozitsiyaga qo'yamiz
    int cursorPosition = result.length;

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
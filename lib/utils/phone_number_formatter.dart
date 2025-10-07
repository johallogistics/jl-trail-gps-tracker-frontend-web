import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Custom formatter to validate and prefix the phone number
class IndianPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String newText = newValue.text;

    // Remove any non-digit characters to check length, except for existing +91
    String digits = newText.replaceAll(RegExp(r'\D'), '');

    // If the input starts with '91', remove it for internal 10-digit check
    if (digits.startsWith('91')) {
      digits = digits.substring(2);
    }

    // Check if the current input length (without +91) exceeds 10 digits
    if (digits.length > 10) {
      // Revert to the old value to prevent typing more than 10 digits
      return oldValue;
    }

    // Only apply +91 prefix if the input is non-empty
    if (newText.isEmpty) {
      return newValue;
    }

    // If the new value already starts with +91, just return it (it's being typed or pasted)
    if (newText.startsWith('+91')) {
      // Allow up to 14 characters total: +91 (3) + 10 digits (10) + 1 space (1) = 14
      if (newText.length > 14) {
        return oldValue;
      }
      return newValue;
    }

    // The core logic to prefix and store
    String formattedText = '+91$newText';

    // Check the final length including the prefix
    if (formattedText.length > 13) { // +91 (3) + 10 digits (10) = 13
      return oldValue;
    }


    // Build a new TextEditingValue with the prefixed text
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
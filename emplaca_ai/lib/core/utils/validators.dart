// lib/core/utils/validators.dart

import 'package:flutter/src/widgets/form.dart';

/// Utility class for common validation operations
class Validators {
  Validators._();

  static FormFieldValidator<String>? get validateUsername => null;

  static FormFieldValidator<String>? get validatePassword =>
      null; // Private constructor to prevent instantiation

  /// Validates Brazilian license plate format
  /// Supports both old (ABC1234) and new (ABC1D23) formats
  static bool isValidBrazilianLicensePlate(String licensePlate) {
    if (licensePlate.isEmpty) return false;

    // Clean the license plate (remove spaces, dashes, etc.)
    final cleanPlate =
        licensePlate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    // Brazilian license plate patterns:
    // Old format: ABC1234 (3 letters + 4 numbers)
    // New format: ABC1D23 (3 letters + 1 number + 1 letter + 2 numbers)
    final oldPattern = RegExp(r'^[A-Z]{3}[0-9]{4}$');
    final newPattern = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

    return oldPattern.hasMatch(cleanPlate) || newPattern.hasMatch(cleanPlate);
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates Brazilian CPF format
  static bool isValidCPF(String cpf) {
    if (cpf.isEmpty) return false;

    // Remove non-numeric characters
    final cleanCPF = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if has 11 digits
    if (cleanCPF.length != 11) return false;

    // Check if all digits are the same
    if (RegExp(r'^(\d)\1*$').hasMatch(cleanCPF)) return false;

    // Validate CPF algorithm
    return _validateCPFAlgorithm(cleanCPF);
  }

  /// Validates Brazilian CNPJ format
  static bool isValidCNPJ(String cnpj) {
    if (cnpj.isEmpty) return false;

    // Remove non-numeric characters
    final cleanCNPJ = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if has 14 digits
    if (cleanCNPJ.length != 14) return false;

    // Check if all digits are the same
    if (RegExp(r'^(\d)\1*$').hasMatch(cleanCNPJ)) return false;

    // Validate CNPJ algorithm
    return _validateCNPJAlgorithm(cleanCNPJ);
  }

  /// Validates Brazilian phone number format
  static bool isValidBrazilianPhone(String phone) {
    if (phone.isEmpty) return false;

    // Remove non-numeric characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Brazilian phone patterns:
    // Mobile: 11 digits (with area code and 9)
    // Landline: 10 digits (with area code)
    return cleanPhone.length == 10 || cleanPhone.length == 11;
  }

  /// Validates password strength
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < 8) return false;

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;

    return true;
  }

  /// Validates if string is not empty and not just whitespace
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validates string length within range
  static bool isValidLength(String value, {int min = 0, int? max}) {
    final length = value.length;
    if (length < min) return false;
    if (max != null && length > max) return false;
    return true;
  }

  /// Validates if value is a valid number
  static bool isValidNumber(String value) {
    if (value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// Validates if value is a valid integer
  static bool isValidInteger(String value) {
    if (value.isEmpty) return false;
    return int.tryParse(value) != null;
  }

  /// Validates Brazilian CEP (postal code) format
  static bool isValidCEP(String cep) {
    if (cep.isEmpty) return false;

    // Remove non-numeric characters
    final cleanCEP = cep.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if has 8 digits
    return cleanCEP.length == 8;
  }

  // Private helper methods

  static bool _validateCPFAlgorithm(String cpf) {
    // Calculate first verification digit
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;

    // Calculate second verification digit
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;

    // Check if calculated digits match the provided ones
    return int.parse(cpf[9]) == firstDigit && int.parse(cpf[10]) == secondDigit;
  }

  static bool _validateCNPJAlgorithm(String cnpj) {
    // CNPJ validation weights
    final weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    // Calculate first verification digit
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weights1[i];
    }
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;

    // Calculate second verification digit
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weights2[i];
    }
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;

    // Check if calculated digits match the provided ones
    return int.parse(cnpj[12]) == firstDigit &&
        int.parse(cnpj[13]) == secondDigit;
  }

  static getPasswordStrength(String text) {}

  static validateConfirmPassword(String? value, String text) {}
}

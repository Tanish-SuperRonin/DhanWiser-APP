class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? notEmpty(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount cannot be empty';
    }
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount greater than 0';
    }
    return null;
  }

  static String? maxAmount(String? value, double maxLimit) {
    final amountError = amount(value);
    if (amountError != null) return amountError;

    final parsedAmount = double.parse(value!.replaceAll(',', ''));
    if (parsedAmount > maxLimit) {
      return 'Amount cannot exceed owed balance';
    }
    return null;
  }
}

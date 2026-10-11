/// AppValidators contains validation functions for forms across PoultryCare.
class AppValidators {
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email or phone number';
    }
    final trimmed = value.trim();
    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed);
    final isPhone = RegExp(r'^\+?[0-9]{10,14}$').hasMatch(trimmed.replaceAll(' ', ''));
    if (!isEmail && !isPhone) {
      return 'Enter a valid email address or mobile number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final n = int.tryParse(value.trim());
    if (n == null || n < 1) {
      return 'Please enter a valid count';
    }
    return null;
  }
}

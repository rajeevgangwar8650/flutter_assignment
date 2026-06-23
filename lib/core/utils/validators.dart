class Validators {
  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredMessage = requiredField(value, fieldName: 'Email');
    if (requiredMessage != null) return requiredMessage;
    if (!isValidEmail(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredMessage = requiredField(value, fieldName: 'Password');
    if (requiredMessage != null) return requiredMessage;
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? name(String? value) {
    final requiredMessage = requiredField(value, fieldName: 'Name');
    if (requiredMessage != null) return requiredMessage;
    if (value!.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? bio(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 180) {
      return 'Bio must be 180 characters or fewer';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }
}

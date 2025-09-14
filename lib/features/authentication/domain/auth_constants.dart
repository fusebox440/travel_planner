/// Authentication-related constants
class AuthConstants {
  // Phone number patterns
  static const String phoneRegex = r'^\+[1-9]\d{1,14}$';

  // OTP code length
  static const int otpLength = 6;

  // Timeouts
  static const Duration phoneVerificationTimeout = Duration(seconds: 60);
  static const Duration otpResendTimeout = Duration(seconds: 30);

  // Test phone numbers (for development)
  static const Map<String, String> testPhoneNumbers = {
    '+1 234 567 8901': '123456',
    '+91 9876543210': '654321',
    '+44 7700 900123': '999999',
  };

  // Error messages
  static const String invalidPhoneFormat =
      'Please enter a valid phone number with country code';
  static const String invalidOtpFormat =
      'Please enter a 6-digit verification code';
  static const String networkError =
      'Network error. Please check your connection and try again.';
  static const String unexpectedError =
      'An unexpected error occurred. Please try again.';

  // Success messages
  static const String codeSentSuccess = 'Verification code sent successfully';
  static const String signInSuccess = 'Sign in successful';
  static const String profileUpdateSuccess = 'Profile updated successfully';

  // Navigation routes
  static const String authEntryRoute = '/auth';
  static const String phoneInputRoute = '/auth/phone';
  static const String otpInputRoute = '/auth/otp';
  static const String profileSetupRoute = '/auth/profile';
  static const String homeRoute = '/home';
}

/// Utility functions for authentication
class AuthUtils {
  /// Format phone number for display
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('+1') && cleaned.length == 12) {
      // US/Canada format: +1 (XXX) XXX-XXXX
      final digits = cleaned.substring(2);
      return '+1 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (cleaned.startsWith('+91') && cleaned.length == 13) {
      // India format: +91 XXXXX-XXXXX
      final digits = cleaned.substring(3);
      return '+91 ${digits.substring(0, 5)}-${digits.substring(5)}';
    } else if (cleaned.startsWith('+44') && cleaned.length >= 12) {
      // UK format: +44 XXXX XXX XXX
      final digits = cleaned.substring(3);
      if (digits.length >= 10) {
        return '+44 ${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
      }
    }

    // Default formatting for other countries
    if (cleaned.length > 4) {
      return '${cleaned.substring(0, cleaned.length - 4)} ${cleaned.substring(cleaned.length - 4)}';
    }

    return cleaned;
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return RegExp(AuthConstants.phoneRegex).hasMatch(cleaned);
  }

  /// Validate OTP format
  static bool isValidOtp(String otp) {
    return otp.length == AuthConstants.otpLength &&
        RegExp(r'^\d+$').hasMatch(otp);
  }

  /// Clean phone number for Firebase (remove formatting)
  static String cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Check if phone number is a test number
  static bool isTestPhoneNumber(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    return AuthConstants.testPhoneNumbers.keys
        .map((key) => cleanPhoneNumber(key))
        .contains(cleaned);
  }

  /// Get test OTP for test phone numbers
  static String? getTestOtp(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    final testKey = AuthConstants.testPhoneNumbers.keys.firstWhere(
      (key) => cleanPhoneNumber(key) == cleaned,
      orElse: () => '',
    );
    return testKey.isNotEmpty ? AuthConstants.testPhoneNumbers[testKey] : null;
  }

  /// Generate initials from display name
  static String generateInitials(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return 'U'; // Default for 'User'
    }

    final words = displayName.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return (words[0][0] + words.last[0]).toUpperCase();
    }
  }

  /// Mask phone number for display (e.g., +1 (***) ***-1234)
  static String maskPhoneNumber(String phoneNumber) {
    final formatted = formatPhoneNumber(phoneNumber);

    if (formatted.startsWith('+1') && formatted.contains('(')) {
      // US format: +1 (***) ***-1234
      final parts = formatted.split(') ');
      if (parts.length == 2) {
        final lastPart = parts[1];
        final lastFour = lastPart.substring(lastPart.length - 4);
        return '+1 (***) ***-$lastFour';
      }
    } else if (formatted.startsWith('+91')) {
      // India format: +91 *****-12345
      final parts = formatted.split('-');
      if (parts.length == 2) {
        final lastPart = parts[1];
        return '+91 *****-$lastPart';
      }
    }

    // Default masking: show country code and last 4 digits
    final cleaned = cleanPhoneNumber(phoneNumber);
    if (cleaned.length >= 6) {
      final countryCode =
          cleaned.substring(0, cleaned.indexOf(RegExp(r'\d')) + 2);
      final lastFour = cleaned.substring(cleaned.length - 4);
      final stars = '*' * (cleaned.length - countryCode.length - 4);
      return '$countryCode$stars$lastFour';
    }

    return phoneNumber;
  }

  /// Get country flag emoji from phone number
  static String getCountryFlag(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);

    if (cleaned.startsWith('+1')) {
      return '🇺🇸'; // US
    } else if (cleaned.startsWith('+91')) {
      return '🇮🇳'; // India
    } else if (cleaned.startsWith('+44')) {
      return '🇬🇧'; // UK
    } else if (cleaned.startsWith('+33')) {
      return '🇫🇷'; // France
    } else if (cleaned.startsWith('+49')) {
      return '🇩🇪'; // Germany
    } else if (cleaned.startsWith('+81')) {
      return '🇯🇵'; // Japan
    } else if (cleaned.startsWith('+86')) {
      return '🇨🇳'; // China
    } else if (cleaned.startsWith('+7')) {
      return '🇷🇺'; // Russia
    }

    return '🌍'; // Default world emoji
  }
}

/// Authentication validation errors
enum AuthValidationError {
  invalidPhoneNumber,
  invalidOtp,
  phoneRequired,
  otpRequired,
  networkError,
  unexpected,
}

extension AuthValidationErrorX on AuthValidationError {
  String get message {
    switch (this) {
      case AuthValidationError.invalidPhoneNumber:
        return AuthConstants.invalidPhoneFormat;
      case AuthValidationError.invalidOtp:
        return AuthConstants.invalidOtpFormat;
      case AuthValidationError.phoneRequired:
        return 'Phone number is required';
      case AuthValidationError.otpRequired:
        return 'Verification code is required';
      case AuthValidationError.networkError:
        return AuthConstants.networkError;
      case AuthValidationError.unexpected:
        return AuthConstants.unexpectedError;
    }
  }
}

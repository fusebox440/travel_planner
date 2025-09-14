# Firebase Phone Authentication - Travel Planner

This document provides a comprehensive guide to the Firebase Phone Authentication implementation in the Travel Planner app.

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Setup Instructions](#setup-instructions)
5. [Implementation Details](#implementation-details)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)
8. [Security Considerations](#security-considerations)

## Overview

The Travel Planner app uses Firebase Phone Authentication to provide secure, phone number-based user authentication. This system allows users to:

- Sign in using their phone number
- Receive OTP verification codes via SMS
- Create and manage user profiles
- Sync data across devices
- Access protected features

### Features Implemented
- ✅ Phone number verification with OTP
- ✅ User profile management with Firestore
- ✅ Profile photo upload with Firebase Storage  
- ✅ Authentication state management with Riverpod
- ✅ Route protection and redirection
- ✅ Test phone numbers for development
- ✅ Comprehensive error handling

## Prerequisites

### Firebase Project Setup
1. **Firebase Console Configuration**
   - Project ID: `travel-planner-720a0`
   - Project Name: `Travel planner`
   - Project Number: `736463136501`

2. **Enabled Services**
   - Authentication (Phone provider)
   - Cloud Firestore
   - Firebase Storage
   - Firebase Analytics (optional)

3. **Required Files**
   - `android/app/google-services.json` - Android configuration
   - `ios/Runner/GoogleService-Info.plist` - iOS configuration (if needed)

### Development Environment
- Flutter SDK >= 3.3.0
- Android Studio or VS Code
- Firebase CLI (optional, for advanced operations)

## Architecture

### File Structure
```
lib/features/authentication/
├── data/
│   ├── auth_service.dart           # Core authentication logic
│   └── user_profile_service.dart   # User profile management
├── domain/
│   └── auth_constants.dart         # Constants and utilities
├── presentation/
│   ├── pages/
│   │   ├── auth_entry_page.dart    # Authentication entry point
│   │   ├── phone_input_page.dart   # Phone number input
│   │   ├── otp_input_page.dart     # OTP verification
│   │   └── profile_setup_page.dart # Profile completion
│   ├── providers/
│   │   └── auth_provider.dart      # Riverpod state management
│   └── widgets/
│       └── auth_state_gate.dart    # Route protection widget
```

### Key Components

#### AuthService
Core authentication service handling:
- Phone number verification
- OTP validation
- User sign-in/sign-out
- Error handling with user-friendly messages

#### UserProfileService  
User profile management service handling:
- Firestore profile operations
- Firebase Storage photo uploads
- Profile completion flow
- Data synchronization

#### Authentication Providers
Riverpod providers for:
- Authentication state management
- Phone verification flow
- User profile operations
- Real-time auth state updates

## Setup Instructions

### 1. Firebase Console Setup

1. **Add SHA Fingerprints** (Critical for Android)
   ```bash
   # Debug fingerprint (generated automatically)
   SHA-1: CF:67:97:D1:BE:3D:C1:92:30:18:1C:C7:E5:7E:A7:13:AB:56:06:3C
   SHA-256: F0:EF:5D:5F:5B:0F:7B:B6:61:7A:F3:E6:74:DC:2F:2F:59:09:9B:0E:6B:89:AA:B6:8C:1D:20:B5:5C:2D:44:34
   ```

2. **Enable Phone Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Phone" provider
   - Add test phone numbers:
     - `+1 234 567 8901` → `123456`
     - `+91 9876543210` → `654321`
     - `+44 7700 900123` → `999999`

3. **Configure Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users can read/write their own profile
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Trip data access based on ownership/sharing
       match /trips/{tripId} {
         allow read, write: if request.auth != null && 
           (request.auth.uid == resource.data.ownerId || 
            request.auth.uid in resource.data.sharedWith);
       }
     }
   }
   ```

### 2. Android Configuration

1. **Update build.gradle.kts** (app-level)
   ```kotlin
   dependencies {
       // Firebase BoM
       implementation(platform("com.google.firebase:firebase-bom:34.2.0"))
       implementation("com.google.firebase:firebase-auth-ktx")
       implementation("com.google.firebase:firebase-firestore-ktx")
       implementation("com.google.firebase:firebase-storage-ktx")
   }
   ```

2. **Verify google-services.json**
   - Location: `android/app/google-services.json`
   - Package name: `com.lakshyakhetan.travelplanner.travel_planner`
   - API key: `AIzaSyAFwIiTf21cm_3sD4YL1v5g3BUByF5ogvE`

### 3. Flutter Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  pin_code_fields: ^8.0.1  # For OTP input
  image_picker: ^1.2.0     # For profile photos
  flutter_image_compress: ^2.4.0  # For image optimization
```

## Implementation Details

### Authentication Flow

#### 1. Phone Number Input
```dart
// Phone verification initiation
final result = await authService.sendPhoneVerification(
  phoneNumber: '+1234567890',
  codeSent: (verificationId, resendToken) {
    // Navigate to OTP page
  },
  verificationFailed: (error) {
    // Handle error
  },
);
```

#### 2. OTP Verification
```dart
// OTP verification
final result = await authService.signInWithSmsCode(
  verificationId: verificationId,
  smsCode: otpCode,
);

switch (result) {
  case SignInSuccess success:
    // User authenticated successfully
    if (success.isNewUser) {
      // Navigate to profile setup
    } else {
      // Navigate to home
    }
    break;
  case SignInError error:
    // Handle authentication error
    break;
}
```

#### 3. Profile Setup (New Users)
```dart
// Complete profile setup
final profile = await userProfileService.completeProfileSetup(
  userId: user.uid,
  displayName: displayName,
  email: email,
  profileImage: selectedImageFile,
);
```

### State Management with Riverpod

#### Authentication State Provider
```dart
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(currentUserProvider.stream).map((asyncUser) {
    return asyncUser.when(
      data: (user) => user != null 
        ? AuthState.authenticated(user) 
        : AuthState.unauthenticated(),
      loading: () => AuthState.loading(),
      error: (error, stack) => AuthState.error(error.toString()),
    );
  });
});
```

#### Phone Verification Provider
```dart
final phoneVerificationProvider = StateNotifierProvider<
  PhoneVerificationNotifier, 
  PhoneVerificationState
>((ref) {
  return PhoneVerificationNotifier(ref.read(authServiceProvider));
});
```

### Route Protection

#### Using AuthStateGate
```dart
// Protect routes that require authentication
GoRoute(
  path: '/trip/create',
  name: 'trip_create',
  builder: (context, state) => AuthStateGate(
    requireAuth: true,
    child: const TripCreateScreen(),
  ),
),

// Optional authentication for general routes  
GoRoute(
  path: '/',
  name: 'home',
  builder: (context, state) => AuthStateGate(
    child: const TripListScreen(),
  ),
),
```

### Error Handling

#### User-Friendly Error Messages
```dart
String _getErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-phone-number':
      return 'The phone number format is invalid. Please enter a valid phone number.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'invalid-verification-code':
      return 'The verification code is invalid. Please try again.';
    // ... more error cases
    default:
      return e.message ?? 'An authentication error occurred. Please try again.';
  }
}
```

## Testing

### Test Phone Numbers
Use these numbers for development and testing:

| Phone Number | Verification Code | Country |
|--------------|------------------|---------|
| +1 234 567 8901 | 123456 | US |
| +91 9876543210 | 654321 | India |
| +44 7700 900123 | 999999 | UK |

### Manual Testing Checklist

#### Phone Authentication Flow
- [ ] Enter valid phone number → receive OTP
- [ ] Enter invalid phone number → show error
- [ ] Enter correct OTP → sign in successful
- [ ] Enter incorrect OTP → show error
- [ ] Test OTP expiration → allow resend
- [ ] Test network failure scenarios

#### Profile Management
- [ ] New user → redirects to profile setup
- [ ] Complete profile → updates Firebase Auth & Firestore
- [ ] Upload profile photo → stores in Firebase Storage
- [ ] Skip profile setup → can complete later
- [ ] Update existing profile → saves changes

#### Route Protection
- [ ] Authenticated user → can access protected routes
- [ ] Unauthenticated user → redirects to auth flow
- [ ] Sign out → redirects to public routes
- [ ] Deep links → proper auth state handling

### Unit Testing Examples

```dart
group('AuthService Tests', () {
  test('should format phone number correctly', () {
    expect(AuthUtils.formatPhoneNumber('+1234567890'), 
           equals('+1 (234) 567-890'));
  });

  test('should validate phone number format', () {
    expect(AuthUtils.isValidPhoneNumber('+1234567890'), isTrue);
    expect(AuthUtils.isValidPhoneNumber('1234567890'), isFalse);
  });

  test('should validate OTP format', () {
    expect(AuthUtils.isValidOtp('123456'), isTrue);
    expect(AuthUtils.isValidOtp('12345'), isFalse);
  });
});
```

## Troubleshooting

### Common Issues and Solutions

#### 1. "SMS not received" 
**Causes:**
- Phone number format incorrect
- SMS quota exceeded
- Test number not configured
- Country not supported

**Solutions:**
- Verify phone number format: `+[country code][number]`
- Use test numbers for development
- Check Firebase Console quota limits
- Verify phone provider settings

#### 2. "Invalid verification code"
**Causes:**
- Code expired (usually 10-15 minutes)
- Incorrect code entry
- Network timing issues

**Solutions:**
- Implement resend functionality
- Clear error on code change
- Add loading states
- Validate code length

#### 3. "Authentication failed"
**Causes:**
- SHA fingerprint mismatch
- google-services.json outdated
- Firebase project configuration

**Solutions:**
```bash
# Regenerate and verify SHA fingerprints
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Update Firebase Console with correct SHA
# Download latest google-services.json
```

#### 4. "Profile photo upload failed"
**Causes:**
- Firebase Storage rules
- Image size too large
- Network connectivity
- Authentication token expired

**Solutions:**
- Implement image compression
- Add retry logic
- Validate file size/format
- Handle authentication state

### Debug Tools

#### Authentication Debug Widget
```dart
// Add to debug builds for auth state visibility
if (kDebugMode) 
  const AuthStatusDebugWidget(),
```

#### Firebase Console Monitoring
- Authentication → Users (monitor sign-ins)
- Firestore → Data (verify profile creation)
- Storage → Files (verify photo uploads)
- Analytics → Events (track auth flow)

## Security Considerations

### Best Practices Implemented

1. **Phone Number Validation**
   - Format validation before sending
   - Country code requirements
   - Test number identification

2. **OTP Security**  
   - Time-limited codes (10-15 minutes)
   - Resend rate limiting
   - Code length validation

3. **Profile Data Protection**
   - Firestore security rules
   - User-specific data access
   - Photo upload permissions

4. **Authentication State**
   - Secure token handling
   - Automatic token refresh
   - Sign-out on errors

### Production Recommendations

1. **Enable reCAPTCHA** for web protection
2. **Monitor authentication metrics** in Firebase Console
3. **Set up alerts** for unusual authentication patterns
4. **Regular security rule audits**
5. **Test with various phone carriers** and regions

### Privacy Compliance

- **Phone Number Storage**: Only encrypted in Firebase Auth
- **Profile Data**: User-controlled, deletable
- **Photo Uploads**: User-initiated, can be removed
- **Data Retention**: Follows Firebase Auth policies

## API Reference

### AuthService Methods

```dart
class AuthService {
  // Send phone verification
  Future<PhoneVerificationResult> sendPhoneVerification({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(String) verificationFailed,
  });

  // Verify OTP and sign in
  Future<SignInResult> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  });

  // Sign out current user
  Future<void> signOut();

  // Delete user account
  Future<AuthResult> deleteAccount();
}
```

### UserProfileService Methods

```dart
class UserProfileService {
  // Get user profile
  Future<UserProfile?> getUserProfile(String userId);

  // Update user profile
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? displayName,
    String? email,
    String? photoURL,
    bool? isProfileComplete,
  });

  // Upload profile photo
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  });

  // Complete profile setup
  Future<UserProfile> completeProfileSetup({
    required String userId,
    required String displayName,
    String? email,
    File? profileImage,
  });
}
```

## Changelog

### Version 1.0.0
- ✅ Initial Firebase Phone Authentication implementation
- ✅ Complete authentication flow (phone → OTP → profile)
- ✅ User profile management with Firestore
- ✅ Profile photo upload with Firebase Storage
- ✅ Route protection and state management
- ✅ Test phone numbers for development
- ✅ Comprehensive error handling
- ✅ Documentation and testing guidelines

### Future Enhancements
- [ ] Multi-factor authentication
- [ ] Social login integration
- [ ] Biometric authentication
- [ ] Phone number change flow
- [ ] Account recovery options

---

For technical questions or issues, refer to the [Firebase Documentation](https://firebase.google.com/docs/auth) or create an issue in the project repository.
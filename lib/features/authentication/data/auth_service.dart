import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling Firebase Phone Authentication
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Constructor with optional Firebase instances for testing
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Send phone verification code
  Future<PhoneVerificationResult> sendPhoneVerification({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String error) verificationFailed,
    Function(PhoneAuthCredential credential)? verificationCompleted,
    Function(String verificationId)? codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final Completer<PhoneVerificationResult> completer = Completer();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (verificationCompleted != null) {
            verificationCompleted(credential);
          } else {
            // Auto-sign in (mainly for Android)
            try {
              final userCredential =
                  await _auth.signInWithCredential(credential);
              if (!completer.isCompleted) {
                completer.complete(PhoneVerificationResult.success(
                  userCredential.user!,
                  isNewUser:
                      userCredential.additionalUserInfo?.isNewUser ?? false,
                ));
              }
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(PhoneVerificationResult.error(
                  'Auto-verification failed: ${e.toString()}',
                ));
              }
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          final errorMessage = _getErrorMessage(e);
          verificationFailed(errorMessage);
          if (!completer.isCompleted) {
            completer.complete(PhoneVerificationResult.error(errorMessage));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId, resendToken);
          if (!completer.isCompleted) {
            completer
                .complete(PhoneVerificationResult.codeSent(verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (codeAutoRetrievalTimeout != null) {
            codeAutoRetrievalTimeout(verificationId);
          }
          // Don't complete here, wait for manual code entry
        },
      );

      return completer.future;
    } catch (e) {
      return PhoneVerificationResult.error(e.toString());
    }
  }

  /// Verify OTP and sign in
  Future<SignInResult> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User user = userCredential.user!;
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      // Create or update user profile in Firestore
      await _createOrUpdateUserProfile(user, isNewUser);

      return SignInResult.success(user, isNewUser: isNewUser);
    } on FirebaseAuthException catch (e) {
      return SignInResult.error(_getErrorMessage(e));
    } catch (e) {
      return SignInResult.error('Sign-in failed: ${e.toString()}');
    }
  }

  /// Link phone number to existing user
  Future<LinkResult> linkPhoneToCurrentUser({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final User? user = currentUser;
      if (user == null) {
        return LinkResult.error('No user is currently signed in');
      }

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential =
          await user.linkWithCredential(credential);
      await _createOrUpdateUserProfile(userCredential.user!, false);

      return LinkResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return LinkResult.error(_getErrorMessage(e));
    } catch (e) {
      return LinkResult.error('Phone linking failed: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete current user account
  Future<AuthResult> deleteAccount() async {
    try {
      final User? user = currentUser;
      if (user == null) {
        return AuthResult.error('No user is currently signed in');
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete the user account
      await user.delete();

      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Account deletion failed: ${e.toString()}');
    }
  }

  /// Create or update user profile in Firestore
  Future<void> _createOrUpdateUserProfile(User user, bool isNewUser) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    final userData = {
      'uid': user.uid,
      'phoneNumber': user.phoneNumber,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'email': user.email,
      'lastSignIn': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isNewUser) {
      userData['createdAt'] = FieldValue.serverTimestamp();
      userData['isProfileComplete'] = false;
    }

    await userDoc.set(userData, SetOptions(merge: true));
  }

  /// Convert FirebaseAuthException to user-friendly message
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number format is invalid. Please enter a valid phone number.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'The verification code is invalid. Please try again.';
      case 'invalid-verification-id':
        return 'The verification session has expired. Please request a new code.';
      case 'credential-already-in-use':
        return 'This phone number is already associated with another account.';
      case 'provider-already-linked':
        return 'This phone number is already linked to your account.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled. Please contact support.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      default:
        return e.message ??
            'An authentication error occurred. Please try again.';
    }
  }

  /// Static method to validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    // Must start with + and have at least 10 digits
    final phoneRegex = RegExp(r'^\+[1-9]\d{9,14}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  /// Static method to validate OTP format
  static bool isValidOtp(String otp) {
    if (otp.isEmpty) return false;

    // Must be exactly 6 digits
    final otpRegex = RegExp(r'^\d{6}$');
    return otpRegex.hasMatch(otp);
  }

  /// Static method to get user-friendly error messages
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number format is invalid. Please enter a valid phone number.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'The verification code is invalid. Please try again.';
      case 'invalid-verification-id':
        return 'The verification session has expired. Please request a new code.';
      case 'credential-already-in-use':
        return 'This phone number is already associated with another account.';
      case 'provider-already-linked':
        return 'This phone number is already linked to your account.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled. Please contact support.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      default:
        return e.message ??
            'An authentication error occurred. Please try again.';
    }
  }
}

/// Result classes for type-safe returns
abstract class AuthResult {
  const AuthResult();

  factory AuthResult.success() = AuthSuccess;
  factory AuthResult.error(String message) = AuthError;
}

class AuthSuccess extends AuthResult {
  const AuthSuccess();
}

class AuthError extends AuthResult {
  final String message;
  const AuthError(this.message);
}

abstract class PhoneVerificationResult {
  const PhoneVerificationResult();

  factory PhoneVerificationResult.success(User user,
      {required bool isNewUser}) = PhoneVerificationSuccess;
  factory PhoneVerificationResult.codeSent(String verificationId) =
      PhoneVerificationCodeSent;
  factory PhoneVerificationResult.error(String message) =
      PhoneVerificationError;
}

class PhoneVerificationSuccess extends PhoneVerificationResult {
  final User user;
  final bool isNewUser;
  const PhoneVerificationSuccess(this.user, {required this.isNewUser});
}

class PhoneVerificationCodeSent extends PhoneVerificationResult {
  final String verificationId;
  const PhoneVerificationCodeSent(this.verificationId);
}

class PhoneVerificationError extends PhoneVerificationResult {
  final String message;
  const PhoneVerificationError(this.message);
}

abstract class SignInResult {
  const SignInResult();

  factory SignInResult.success(User user, {required bool isNewUser}) =
      SignInSuccess;
  factory SignInResult.error(String message) = SignInError;
}

class SignInSuccess extends SignInResult {
  final User user;
  final bool isNewUser;
  const SignInSuccess(this.user, {required this.isNewUser});
}

class SignInError extends SignInResult {
  final String message;
  const SignInError(this.message);
}

abstract class LinkResult {
  const LinkResult();

  factory LinkResult.success(User user) = LinkSuccess;
  factory LinkResult.error(String message) = LinkError;
}

class LinkSuccess extends LinkResult {
  final User user;
  const LinkSuccess(this.user);
}

class LinkError extends LinkResult {
  final String message;
  const LinkError(this.message);
}

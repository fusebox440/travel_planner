import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/auth_service.dart';
import '../../data/user_profile_service.dart';

/// Provider for AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for UserProfileService instance
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

/// Provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for authentication state (loading, authenticated, unauthenticated)
final authStateProvider = Provider<AsyncValue<AuthState>>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => AsyncValue.data(user != null
        ? AuthState.authenticated(user)
        : AuthState.unauthenticated()),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.data(AuthState.error(error.toString())),
  );
});

/// Provider for user profile data from Firestore
final userProfileProvider =
    StreamProvider.family<UserProfile?, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) {
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserProfile.fromJson(doc.data()!);
  });
});

/// Provider for checking if user profile is complete
final isProfileCompleteProvider =
    Provider.family<AsyncValue<bool>, String>((ref, userId) {
  final profileAsync = ref.watch(userProfileProvider(userId));
  return profileAsync.when(
    data: (profile) => AsyncValue.data(profile?.isProfileComplete ?? false),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for user profile operations
final userProfileOperationsProvider = StateNotifierProvider<
    UserProfileOperationsNotifier, UserProfileOperationsState>((ref) {
  return UserProfileOperationsNotifier(ref.read(userProfileServiceProvider));
});

/// Phone verification state provider
final phoneVerificationProvider =
    StateNotifierProvider<PhoneVerificationNotifier, PhoneVerificationState>(
        (ref) {
  return PhoneVerificationNotifier(ref.read(authServiceProvider));
});

/// Notifier for phone verification flow
class PhoneVerificationNotifier extends StateNotifier<PhoneVerificationState> {
  final AuthService _authService;

  PhoneVerificationNotifier(this._authService)
      : super(PhoneVerificationState.initial());

  /// Start phone verification
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    state = PhoneVerificationState.sendingCode();

    final result = await _authService.sendPhoneVerification(
      phoneNumber: phoneNumber,
      codeSent: (verificationId, resendToken) {
        state = PhoneVerificationState.codeSent(verificationId, phoneNumber);
      },
      verificationFailed: (error) {
        state = PhoneVerificationState.error(error);
      },
      verificationCompleted: (credential) {
        // Auto-verification completed (mainly on Android)
        state = PhoneVerificationState.autoVerified();
      },
    );

    // Handle the result if completed immediately
    switch (result) {
      case PhoneVerificationSuccess success:
        state =
            PhoneVerificationState.verified(success.user, success.isNewUser);
        break;
      case PhoneVerificationError error:
        state = PhoneVerificationState.error(error.message);
        break;
      case PhoneVerificationCodeSent _:
        // Already handled in codeSent callback
        break;
    }
  }

  /// Verify OTP code
  Future<void> verifyOtpCode(String verificationId, String otpCode) async {
    state = PhoneVerificationState.verifyingCode();

    final result = await _authService.signInWithSmsCode(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    switch (result) {
      case SignInSuccess success:
        state =
            PhoneVerificationState.verified(success.user, success.isNewUser);
        break;
      case SignInError error:
        state = PhoneVerificationState.error(error.message);
        break;
    }
  }

  /// Reset verification state
  void reset() {
    state = PhoneVerificationState.initial();
  }

  /// Resend verification code
  Future<void> resendCode(String phoneNumber) async {
    await verifyPhoneNumber(phoneNumber);
  }
}

/// Authentication state
sealed class AuthState {
  const AuthState();

  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final User user;
  const AuthStateAuthenticated(this.user);
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}

/// Phone verification state
sealed class PhoneVerificationState {
  const PhoneVerificationState();

  const factory PhoneVerificationState.initial() = PhoneVerificationInitial;
  const factory PhoneVerificationState.sendingCode() =
      PhoneVerificationSendingCode;
  const factory PhoneVerificationState.codeSent(
      String verificationId, String phoneNumber) = PhoneVerificationCodeSent;
  const factory PhoneVerificationState.verifyingCode() =
      PhoneVerificationVerifyingCode;
  const factory PhoneVerificationState.autoVerified() =
      PhoneVerificationAutoVerified;
  const factory PhoneVerificationState.verified(User user, bool isNewUser) =
      PhoneVerificationVerified;
  const factory PhoneVerificationState.error(String message) =
      PhoneVerificationError;
}

class PhoneVerificationInitial extends PhoneVerificationState {
  const PhoneVerificationInitial();
}

class PhoneVerificationSendingCode extends PhoneVerificationState {
  const PhoneVerificationSendingCode();
}

class PhoneVerificationCodeSent extends PhoneVerificationState {
  final String verificationId;
  final String phoneNumber;
  const PhoneVerificationCodeSent(this.verificationId, this.phoneNumber);
}

class PhoneVerificationVerifyingCode extends PhoneVerificationState {
  const PhoneVerificationVerifyingCode();
}

class PhoneVerificationAutoVerified extends PhoneVerificationState {
  const PhoneVerificationAutoVerified();
}

class PhoneVerificationVerified extends PhoneVerificationState {
  final User user;
  final bool isNewUser;
  const PhoneVerificationVerified(this.user, this.isNewUser);
}

class PhoneVerificationError extends PhoneVerificationState {
  final String message;
  const PhoneVerificationError(this.message);
}

/// User profile model
class UserProfile {
  final String uid;
  final String? phoneNumber;
  final String? displayName;
  final String? photoURL;
  final String? email;
  final bool isProfileComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSignIn;

  const UserProfile({
    required this.uid,
    this.phoneNumber,
    this.displayName,
    this.photoURL,
    this.email,
    this.isProfileComplete = false,
    this.createdAt,
    this.updatedAt,
    this.lastSignIn,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      email: json['email'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      lastSignIn: json['lastSignIn'] != null
          ? (json['lastSignIn'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoURL': photoURL,
      'email': email,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastSignIn': lastSignIn != null ? Timestamp.fromDate(lastSignIn!) : null,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? photoURL,
    String? email,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSignIn,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      email: email ?? this.email,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
    );
  }
}

/// Notifier for user profile operations
class UserProfileOperationsNotifier
    extends StateNotifier<UserProfileOperationsState> {
  final UserProfileService _userProfileService;

  UserProfileOperationsNotifier(this._userProfileService)
      : super(UserProfileOperationsState.initial());

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? email,
    String? photoURL,
    bool? isProfileComplete,
  }) async {
    state = UserProfileOperationsState.loading();

    try {
      final updatedProfile = await _userProfileService.updateUserProfile(
        userId: userId,
        displayName: displayName,
        email: email,
        photoURL: photoURL,
        isProfileComplete: isProfileComplete,
      );

      state = UserProfileOperationsState.success(updatedProfile);
    } catch (e) {
      state = UserProfileOperationsState.error(e.toString());
    }
  }

  /// Upload profile photo
  Future<void> uploadProfilePhoto({
    required String userId,
    required dynamic imageFile,
  }) async {
    state = UserProfileOperationsState.loading();

    try {
      final photoURL = await _userProfileService.uploadProfilePhoto(
        userId: userId,
        imageFile: imageFile,
      );

      // Update profile with new photo URL
      final updatedProfile = await _userProfileService.updateUserProfile(
        userId: userId,
        photoURL: photoURL,
      );

      state = UserProfileOperationsState.success(updatedProfile);
    } catch (e) {
      state = UserProfileOperationsState.error(e.toString());
    }
  }

  /// Delete profile photo
  Future<void> deleteProfilePhoto(String userId) async {
    state = UserProfileOperationsState.loading();

    try {
      await _userProfileService.deleteProfilePhoto(userId);

      // Get updated profile
      final updatedProfile = await _userProfileService.getUserProfile(userId);
      if (updatedProfile != null) {
        state = UserProfileOperationsState.success(updatedProfile);
      } else {
        state =
            UserProfileOperationsState.error('Failed to get updated profile');
      }
    } catch (e) {
      state = UserProfileOperationsState.error(e.toString());
    }
  }

  /// Complete profile setup
  Future<void> completeProfileSetup({
    required String userId,
    required String displayName,
    String? email,
    dynamic profileImage,
  }) async {
    state = UserProfileOperationsState.loading();

    try {
      final completedProfile = await _userProfileService.completeProfileSetup(
        userId: userId,
        displayName: displayName,
        email: email,
        profileImage: profileImage,
      );

      state = UserProfileOperationsState.success(completedProfile);
    } catch (e) {
      state = UserProfileOperationsState.error(e.toString());
    }
  }

  /// Reset state
  void reset() {
    state = UserProfileOperationsState.initial();
  }
}

/// State for user profile operations
sealed class UserProfileOperationsState {
  const UserProfileOperationsState();

  const factory UserProfileOperationsState.initial() =
      UserProfileOperationsInitial;
  const factory UserProfileOperationsState.loading() =
      UserProfileOperationsLoading;
  const factory UserProfileOperationsState.success(UserProfile profile) =
      UserProfileOperationsSuccess;
  const factory UserProfileOperationsState.error(String message) =
      UserProfileOperationsError;
}

class UserProfileOperationsInitial extends UserProfileOperationsState {
  const UserProfileOperationsInitial();
}

class UserProfileOperationsLoading extends UserProfileOperationsState {
  const UserProfileOperationsLoading();
}

class UserProfileOperationsSuccess extends UserProfileOperationsState {
  final UserProfile profile;
  const UserProfileOperationsSuccess(this.profile);
}

class UserProfileOperationsError extends UserProfileOperationsState {
  final String message;
  const UserProfileOperationsError(this.message);
}

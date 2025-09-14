import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:travel_planner/features/authentication/data/auth_service.dart';
import 'package:travel_planner/features/authentication/data/user_profile_service.dart';

import 'authentication_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  PhoneAuthCredential,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  FirebaseStorage,
  Reference,
  UploadTask,
  TaskSnapshot,
])
void main() {
  group('AuthService Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;
    late AuthService authService;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        firestore: mockFirestore,
      );
    });

    group('sendPhoneVerification', () {
      test('should call verifyPhoneNumber with correct parameters', () async {
        const phoneNumber = '+1234567890';
        String? capturedVerificationId;
        String? capturedError;

        // Setup mock
        when(mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: anyNamed('phoneNumber'),
          timeout: anyNamed('timeout'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeSent: anyNamed('codeSent'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
        )).thenAnswer((invocation) async {
          // Simulate code sent callback
          final codeSent = invocation.namedArguments[#codeSent] as Function;
          codeSent('verification_id_123', 12345);
        });

        // Execute
        final result = await authService.sendPhoneVerification(
          phoneNumber: phoneNumber,
          codeSent: (verificationId, resendToken) {
            capturedVerificationId = verificationId;
          },
          verificationFailed: (error) {
            capturedError = error;
          },
        );

        // Verify
        expect(result, isA<PhoneVerificationSuccess>());
        expect(capturedVerificationId, equals('verification_id_123'));
        expect(capturedError, isNull);

        verify(mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeSent: anyNamed('codeSent'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
        )).called(1);
      });

      test('should handle verification failed with user-friendly error',
          () async {
        const phoneNumber = '+1234567890';
        String? capturedError;

        // Setup mock to simulate verification failure
        when(mockFirebaseAuth.verifyPhoneNumber(
          phoneNumber: anyNamed('phoneNumber'),
          timeout: anyNamed('timeout'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeSent: anyNamed('codeSent'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
        )).thenAnswer((invocation) async {
          // Simulate verification failed callback
          final verificationFailed =
              invocation.namedArguments[#verificationFailed] as Function;
          verificationFailed(FirebaseAuthException(
            code: 'invalid-phone-number',
            message: 'The phone number format is invalid.',
          ));
        });

        // Execute
        final result = await authService.sendPhoneVerification(
          phoneNumber: phoneNumber,
          codeSent: (verificationId, resendToken) {},
          verificationFailed: (error) {
            capturedError = error;
          },
        );

        // Verify
        expect(result, isA<PhoneVerificationError>());
        expect(capturedError, contains('phone number format is invalid'));
      });

      test('should handle invalid phone number format', () async {
        const phoneNumber = '1234567890'; // Missing country code

        // Execute
        final result = await authService.sendPhoneVerification(
          phoneNumber: phoneNumber,
          codeSent: (verificationId, resendToken) {},
          verificationFailed: (error) {},
        );

        // Verify
        expect(result, isA<PhoneVerificationError>());
        final error = result as PhoneVerificationError;
        expect(error.message, contains('Please include the country code'));
      });
    });

    group('signInWithSmsCode', () {
      test('should successfully sign in with valid OTP', () async {
        const verificationId = 'verification_id_123';
        const smsCode = '123456';

        // Setup mocks
        final mockUser = MockUser();
        final mockUserCredential = MockUserCredential();
        final mockPhoneCredential = MockPhoneAuthCredential();

        when(mockUser.uid).thenReturn('user_123');
        when(mockUser.phoneNumber).thenReturn('+1234567890');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUserCredential.additionalUserInfo?.isNewUser).thenReturn(true);

        // Mock credential creation
        when(PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        )).thenReturn(mockPhoneCredential);

        when(mockFirebaseAuth.signInWithCredential(mockPhoneCredential))
            .thenAnswer((_) async => mockUserCredential);

        // Mock Firestore operations for new user profile creation
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc('user_123')).thenReturn(mockDoc);
        when(mockDoc.set(any)).thenAnswer((_) async => {});

        // Execute
        final result = await authService.signInWithSmsCode(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        // Verify
        expect(result, isA<SignInSuccess>());
        final success = result as SignInSuccess;
        expect(success.user.uid, equals('user_123'));
        expect(success.isNewUser, isTrue);

        verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
        verify(mockDoc.set(any)).called(1);
      });

      test('should handle invalid verification code', () async {
        const verificationId = 'verification_id_123';
        const smsCode = '000000';

        // Setup mock to throw invalid verification code error
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenThrow(FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'The verification code is invalid.',
        ));

        // Execute
        final result = await authService.signInWithSmsCode(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        // Verify
        expect(result, isA<SignInError>());
        final error = result as SignInError;
        expect(error.message, contains('verification code is invalid'));
      });

      test('should validate OTP format before attempting sign in', () async {
        const verificationId = 'verification_id_123';
        const smsCode = '12345'; // Invalid length

        // Execute
        final result = await authService.signInWithSmsCode(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        // Verify
        expect(result, isA<SignInError>());
        final error = result as SignInError;
        expect(error.message, contains('must be 6 digits'));

        // Should not call Firebase Auth
        verifyNever(mockFirebaseAuth.signInWithCredential(any));
      });
    });

    group('signOut', () {
      test('should successfully sign out user', () async {
        // Setup mock
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

        // Execute
        await authService.signOut();

        // Verify
        verify(mockFirebaseAuth.signOut()).called(1);
      });
    });

    group('deleteAccount', () {
      test('should successfully delete user account and profile', () async {
        // Setup mocks
        final mockUser = MockUser();
        when(mockUser.uid).thenReturn('user_123');
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.delete()).thenAnswer((_) async => {});

        // Mock Firestore deletion
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc('user_123')).thenReturn(mockDoc);
        when(mockDoc.delete()).thenAnswer((_) async => {});

        // Execute
        final result = await authService.deleteAccount();

        // Verify
        expect(result, isA<AuthSuccess>());
        verify(mockUser.delete()).called(1);
        verify(mockDoc.delete()).called(1);
      });

      test('should handle no current user', () async {
        // Setup mock
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Execute
        final result = await authService.deleteAccount();

        // Verify
        expect(result, isA<AuthError>());
        final error = result as AuthError;
        expect(error.message, contains('No user is currently signed in'));
      });
    });
  });

  group('UserProfileService Tests', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseStorage mockStorage;
    late UserProfileService profileService;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockStorage = MockFirebaseStorage();
      profileService = UserProfileService(
        firestore: mockFirestore,
        storage: mockStorage,
      );
    });

    group('getUserProfile', () {
      test('should return user profile when document exists', () async {
        const userId = 'user_123';

        // Setup mocks
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc(userId)).thenReturn(mockDoc);
        when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.data()).thenReturn({
          'uid': userId,
          'displayName': 'John Doe',
          'email': 'john@example.com',
          'phoneNumber': '+1234567890',
          'photoURL': 'https://example.com/photo.jpg',
          'isProfileComplete': true,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });

        // Execute
        final result = await profileService.getUserProfile(userId);

        // Verify
        expect(result, isNotNull);
        expect(result!.uid, equals(userId));
        expect(result.displayName, equals('John Doe'));
        expect(result.email, equals('john@example.com'));
        expect(result.isProfileComplete, isTrue);
      });

      test('should return null when document does not exist', () async {
        const userId = 'user_123';

        // Setup mocks
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc(userId)).thenReturn(mockDoc);
        when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(false);

        // Execute
        final result = await profileService.getUserProfile(userId);

        // Verify
        expect(result, isNull);
      });
    });

    group('uploadProfilePhoto', () {
      test('should successfully upload and compress image', () async {
        const userId = 'user_123';
        const downloadUrl = 'https://example.com/profile.jpg';

        // Create a mock file
        final mockFile = File('test_image.jpg');

        // Setup mocks
        final mockRef = MockReference();
        final mockUploadTask = MockUploadTask();
        final mockTaskSnapshot = MockTaskSnapshot();

        when(mockStorage.ref('profile_photos/$userId.jpg')).thenReturn(mockRef);
        when(mockRef.putFile(any)).thenReturn(mockUploadTask);
        when(mockUploadTask.then<String>(any))
            .thenAnswer((_) async => downloadUrl);
        when(mockTaskSnapshot.ref).thenReturn(mockRef);
        when(mockRef.getDownloadURL()).thenAnswer((_) async => downloadUrl);

        // Execute
        final result = await profileService.uploadProfilePhoto(
          userId: userId,
          imageFile: mockFile,
        );

        // Verify
        expect(result, equals(downloadUrl));
      });
    });

    group('completeProfileSetup', () {
      test('should successfully complete profile setup with photo', () async {
        const userId = 'user_123';
        const displayName = 'John Doe';
        const email = 'john@example.com';
        const photoUrl = 'https://example.com/photo.jpg';

        final mockFile = File('test_image.jpg');

        // Setup mocks for photo upload
        final mockStorageRef = MockReference();
        final mockUploadTask = MockUploadTask();

        when(mockStorage.ref('profile_photos/$userId.jpg'))
            .thenReturn(mockStorageRef);
        when(mockStorageRef.putFile(any)).thenReturn(mockUploadTask);
        when(mockUploadTask.then<String>(any))
            .thenAnswer((_) async => photoUrl);
        when(mockStorageRef.getDownloadURL()).thenAnswer((_) async => photoUrl);

        // Setup mocks for Firestore update
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc(userId)).thenReturn(mockDoc);
        when(mockDoc.set(any, any)).thenAnswer((_) async => {});
        when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.data()).thenReturn({
          'uid': userId,
          'displayName': displayName,
          'email': email,
          'photoURL': photoUrl,
          'isProfileComplete': true,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });

        // Execute
        final result = await profileService.completeProfileSetup(
          userId: userId,
          displayName: displayName,
          email: email,
          profileImage: mockFile,
        );

        // Verify
        expect(result.uid, equals(userId));
        expect(result.displayName, equals(displayName));
        expect(result.email, equals(email));
        expect(result.photoURL, equals(photoUrl));
        expect(result.isProfileComplete, isTrue);

        verify(mockDoc.set(any, any)).called(1);
      });

      test('should complete profile setup without photo', () async {
        const userId = 'user_123';
        const displayName = 'Jane Doe';

        // Setup mocks for Firestore update
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc(userId)).thenReturn(mockDoc);
        when(mockDoc.set(any, any)).thenAnswer((_) async => {});
        when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.data()).thenReturn({
          'uid': userId,
          'displayName': displayName,
          'isProfileComplete': true,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });

        // Execute
        final result = await profileService.completeProfileSetup(
          userId: userId,
          displayName: displayName,
        );

        // Verify
        expect(result.uid, equals(userId));
        expect(result.displayName, equals(displayName));
        expect(result.photoURL, isNull);
        expect(result.isProfileComplete, isTrue);
      });
    });

    group('deleteUserProfile', () {
      test('should successfully delete user profile and photos', () async {
        const userId = 'user_123';

        // Setup mocks for Firestore deletion
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc(userId)).thenReturn(mockDoc);
        when(mockDoc.delete()).thenAnswer((_) async => {});

        // Setup mocks for Storage deletion
        final mockRef = MockReference();
        when(mockStorage.ref('profile_photos/$userId.jpg')).thenReturn(mockRef);
        when(mockRef.delete()).thenAnswer((_) async => {});

        // Execute
        await profileService.deleteUserProfile(userId);

        // Verify
        verify(mockDoc.delete()).called(1);
        verify(mockRef.delete()).called(1);
      });
    });
  });

  group('Authentication Utils Tests', () {
    group('Phone Number Validation', () {
      test('should validate correct phone number formats', () {
        expect(AuthService.isValidPhoneNumber('+1234567890'), isTrue);
        expect(AuthService.isValidPhoneNumber('+919876543210'), isTrue);
        expect(AuthService.isValidPhoneNumber('+447700900123'), isTrue);
      });

      test('should reject invalid phone number formats', () {
        expect(AuthService.isValidPhoneNumber('1234567890'), isFalse);
        expect(AuthService.isValidPhoneNumber('+1'), isFalse);
        expect(AuthService.isValidPhoneNumber(''), isFalse);
        expect(AuthService.isValidPhoneNumber('+123456789012345'), isFalse);
      });
    });

    group('OTP Validation', () {
      test('should validate correct OTP formats', () {
        expect(AuthService.isValidOtp('123456'), isTrue);
        expect(AuthService.isValidOtp('000000'), isTrue);
        expect(AuthService.isValidOtp('999999'), isTrue);
      });

      test('should reject invalid OTP formats', () {
        expect(AuthService.isValidOtp('12345'), isFalse);
        expect(AuthService.isValidOtp('1234567'), isFalse);
        expect(AuthService.isValidOtp('12345a'), isFalse);
        expect(AuthService.isValidOtp(''), isFalse);
      });
    });

    group('Error Message Handling', () {
      test('should return user-friendly error messages', () {
        final authException = FirebaseAuthException(
          code: 'invalid-phone-number',
          message: 'The phone number format is invalid.',
        );

        final friendlyMessage = AuthService.getErrorMessage(authException);
        expect(friendlyMessage, contains('phone number format is invalid'));
        expect(friendlyMessage, contains('Please enter a valid phone number'));
      });

      test('should handle unknown error codes', () {
        final authException = FirebaseAuthException(
          code: 'unknown-error',
          message: 'Something went wrong.',
        );

        final friendlyMessage = AuthService.getErrorMessage(authException);
        expect(friendlyMessage, contains('authentication error occurred'));
      });
    });
  });
}

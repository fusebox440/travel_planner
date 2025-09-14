import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../presentation/providers/auth_provider.dart';

/// Service for managing user profiles in Firestore and Firebase Storage
class UserProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  /// Constructor with optional Firebase instances for testing
  UserProfileService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw UserProfileException('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Stream user profile by ID
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Create or update user profile
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? displayName,
    String? email,
    String? photoURL,
    bool? isProfileComplete,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        throw UserProfileException(
            'User not authorized to update this profile');
      }

      final updateData = <String, dynamic>{
        'uid': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add provided fields
      if (displayName != null) updateData['displayName'] = displayName;
      if (email != null) updateData['email'] = email;
      if (photoURL != null) updateData['photoURL'] = photoURL;
      if (isProfileComplete != null)
        updateData['isProfileComplete'] = isProfileComplete;
      if (additionalData != null) updateData.addAll(additionalData);

      // Update Firebase Auth profile
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoURL != null) await user.updatePhotoURL(photoURL);

      // Update Firestore profile
      await _firestore.collection('users').doc(userId).set(
            updateData,
            SetOptions(merge: true),
          );

      // Return updated profile
      final updatedProfile = await getUserProfile(userId);
      if (updatedProfile == null) {
        throw UserProfileException('Failed to retrieve updated profile');
      }

      return updatedProfile;
    } catch (e) {
      if (e is UserProfileException) rethrow;
      throw UserProfileException(
          'Failed to update user profile: ${e.toString()}');
    }
  }

  /// Upload profile photo and return URL
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.uid != userId) {
        throw UserProfileException('User not authorized to upload photo');
      }

      // Compress image before upload
      final compressedFile = await _compressImage(imageFile);

      // Upload to Firebase Storage
      final ref = _storage.ref().child('users/$userId/profile.jpg');
      final uploadTask = await ref.putFile(compressedFile);

      // Get download URL
      final downloadURL = await uploadTask.ref.getDownloadURL();

      // Clean up compressed file if it's different from original
      if (compressedFile.path != imageFile.path) {
        try {
          await compressedFile.delete();
        } catch (e) {
          // Ignore cleanup errors
        }
      }

      return downloadURL;
    } catch (e) {
      if (e is UserProfileException) rethrow;
      throw UserProfileException(
          'Failed to upload profile photo: ${e.toString()}');
    }
  }

  /// Pick image from gallery or camera and upload
  Future<String> pickAndUploadProfilePhoto({
    required String userId,
    required ImageSource source,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) {
        throw UserProfileException('No image selected');
      }

      final imageFile = File(image.path);
      return await uploadProfilePhoto(userId: userId, imageFile: imageFile);
    } catch (e) {
      if (e is UserProfileException) rethrow;
      throw UserProfileException(
          'Failed to pick and upload photo: ${e.toString()}');
    }
  }

  /// Delete profile photo
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final user = currentUser;
      if (user == null || user.uid != userId) {
        throw UserProfileException('User not authorized to delete photo');
      }

      // Delete from Firebase Storage
      final ref = _storage.ref().child('users/$userId/profile.jpg');
      try {
        await ref.delete();
      } catch (e) {
        // Photo might not exist, which is fine
      }

      // Update Firebase Auth profile
      await user.updatePhotoURL(null);

      // Update Firestore profile
      await _firestore.collection('users').doc(userId).update({
        'photoURL': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is UserProfileException) rethrow;
      throw UserProfileException(
          'Failed to delete profile photo: ${e.toString()}');
    }
  }

  /// Complete user profile setup
  Future<UserProfile> completeProfileSetup({
    required String userId,
    required String displayName,
    String? email,
    File? profileImage,
  }) async {
    try {
      String? photoURL;

      // Upload profile image if provided
      if (profileImage != null) {
        photoURL = await uploadProfilePhoto(
          userId: userId,
          imageFile: profileImage,
        );
      }

      // Update profile with complete data
      return await updateUserProfile(
        userId: userId,
        displayName: displayName,
        email: email?.isEmpty == true ? null : email,
        photoURL: photoURL,
        isProfileComplete: true,
      );
    } catch (e) {
      if (e is UserProfileException) rethrow;
      throw UserProfileException(
          'Failed to complete profile setup: ${e.toString()}');
    }
  }

  /// Delete user profile and all associated data
  Future<void> deleteUserProfile(String userId) async {
    try {
      final user = currentUser;
      if (user == null || user.uid != userId) {
        throw UserProfileException(
            'User not authorized to delete this profile');
      }

      // Delete profile photo from storage
      try {
        await deleteProfilePhoto(userId);
      } catch (e) {
        // Continue even if photo deletion fails
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete additional user data if exists
      final batch = _firestore.batch();

      // Delete user's trips (if they own any)
      final tripsQuery = await _firestore
          .collection('trips')
          .where('ownerId', isEqualTo: userId)
          .get();

      for (final doc in tripsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's shared trip references
      final sharedTripsQuery = await _firestore
          .collection('trips')
          .where('sharedWith', arrayContains: userId)
          .get();

      for (final doc in sharedTripsQuery.docs) {
        batch.update(doc.reference, {
          'sharedWith': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      if (e is UserProfileException) rethrow;
      throw UserProfileException(
          'Failed to delete user profile: ${e.toString()}');
    }
  }

  /// Compress image before upload
  Future<File> _compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 200,
        minHeight: 200,
        format: CompressFormat.jpeg,
      );

      return File(compressedFile?.path ?? imageFile.path);
    } catch (e) {
      // If compression fails, return original file
      return imageFile;
    }
  }

  /// Search users by display name or email
  Future<List<UserProfile>> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    try {
      if (query.trim().isEmpty) return [];

      // Search by display name
      final nameQuery = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(limit)
          .get();

      final results = <UserProfile>[];

      for (final doc in nameQuery.docs) {
        if (doc.data().isNotEmpty) {
          final profile = UserProfile.fromJson(doc.data());
          results.add(profile);
        }
      }

      // Remove duplicates and return
      final uniqueResults = <String, UserProfile>{};
      for (final profile in results) {
        uniqueResults[profile.uid] = profile;
      }

      return uniqueResults.values.toList();
    } catch (e) {
      throw UserProfileException('Failed to search users: ${e.toString()}');
    }
  }
}

/// Custom exception for user profile operations
class UserProfileException implements Exception {
  final String message;
  const UserProfileException(this.message);

  @override
  String toString() => message;
}

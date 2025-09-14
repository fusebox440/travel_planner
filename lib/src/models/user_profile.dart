import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, displayName: $displayName, email: $email, phoneNumber: $phoneNumber, isProfileComplete: $isProfileComplete)';
  }
}

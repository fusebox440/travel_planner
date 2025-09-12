import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'review.g.dart';

@HiveType(
    typeId:
        31) // Changed to avoid conflict with TransportationDetails (typeId: 30)
class Review extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? tripId;

  @HiveField(2)
  final String placeName;

  @HiveField(3)
  final int rating;

  @HiveField(4)
  final String text;

  @HiveField(5)
  final List<String> photoPaths;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime lastModified;

  @HiveField(8)
  final ReviewUser user;

  Review({
    required this.id,
    this.tripId,
    required this.placeName,
    required this.rating,
    required this.text,
    required this.photoPaths,
    required this.createdAt,
    required this.lastModified,
    required this.user,
  });

  factory Review.create({
    required String placeName,
    required int rating,
    required String text,
    required List<String> photoPaths,
    String? tripId,
    required ReviewUser user,
  }) {
    final now = DateTime.now();
    return Review(
      id: const Uuid().v4(),
      tripId: tripId,
      placeName: placeName,
      rating: rating.clamp(1, 5),
      text: text,
      photoPaths: photoPaths,
      createdAt: now,
      lastModified: now,
      user: user,
    );
  }

  Review copyWith({
    String? placeName,
    int? rating,
    String? text,
    List<String>? photoPaths,
    String? Function()? tripId,
    ReviewUser? user,
  }) {
    return Review(
      id: id,
      tripId: tripId != null ? tripId() : this.tripId,
      placeName: placeName ?? this.placeName,
      rating: (rating ?? this.rating).clamp(1, 5),
      text: text ?? this.text,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt,
      lastModified: DateTime.now(),
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'placeName': placeName,
      'rating': rating,
      'text': text,
      'photoPaths': photoPaths,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'user': user.toJson(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      tripId: json['tripId'] as String?,
      placeName: json['placeName'] as String,
      rating: json['rating'] as int,
      text: json['text'] as String,
      photoPaths: (json['photoPaths'] as List).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      user: ReviewUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tripId == other.tripId &&
          placeName == other.placeName &&
          rating == other.rating &&
          text == other.text &&
          listEquals(photoPaths, other.photoPaths) &&
          user == other.user;

  @override
  int get hashCode =>
      id.hashCode ^
      tripId.hashCode ^
      placeName.hashCode ^
      rating.hashCode ^
      text.hashCode ^
      photoPaths.hashCode ^
      user.hashCode;
}

@HiveType(typeId: 32) // Changed to avoid conflicts
class ReviewUser {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? avatarUrl;

  const ReviewUser({
    required this.name,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewUser &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => name.hashCode ^ avatarUrl.hashCode;
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:travel_planner/features/reviews/domain/models/review.dart';
import 'package:uuid/uuid.dart';

class ReviewException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ReviewException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'ReviewException: $message ${code != null ? '(Code: $code)' : ''}';
}

class ReviewService {
  ReviewService._privateConstructor();
  static final ReviewService _instance = ReviewService._privateConstructor();
  factory ReviewService() => _instance;

  static const _reviewsBoxName = 'reviews';
  late final Box<Review> _reviewsBox;

  /// Initialize Hive box for reviews
  Future<void> init() async {
    _reviewsBox = await Hive.openBox<Review>(_reviewsBoxName);
  }

  /// Get all reviews
  List<Review> getAllReviews() {
    return _reviewsBox.values.toList();
  }

  /// Get reviews for a specific place
  List<Review> getReviewsByPlace(String placeName) {
    return _reviewsBox.values
        .where((review) => review.placeName == placeName)
        .toList();
  }

  /// Get reviews for a specific trip
  List<Review> getReviewsByTrip(String tripId) {
    return _reviewsBox.values
        .where((review) => review.tripId == tripId)
        .toList();
  }

  /// Add a new review
  Future<Review> addReview({
    required String placeName,
    required int rating,
    required String text,
    required List<String> photoPaths,
    String? tripId,
    required ReviewUser user,
  }) async {
    try {
      final review = Review.create(
        placeName: placeName,
        rating: rating,
        text: text,
        photoPaths: photoPaths,
        tripId: tripId,
        user: user,
      );

      await _reviewsBox.put(review.id, review);
      return review;
    } catch (e) {
      throw ReviewException(
        'Failed to add review',
        code: 'ADD_REVIEW_ERROR',
        originalError: e,
      );
    }
  }

  /// Update an existing review
  Future<Review> updateReview({
    required String reviewId,
    String? placeName,
    int? rating,
    String? text,
    List<String>? photoPaths,
    String? Function()? tripId,
    ReviewUser? user,
  }) async {
    try {
      final existingReview = _reviewsBox.get(reviewId);
      if (existingReview == null) {
        throw ReviewException(
          'Review not found',
          code: 'REVIEW_NOT_FOUND',
        );
      }

      final updatedReview = existingReview.copyWith(
        placeName: placeName,
        rating: rating,
        text: text,
        photoPaths: photoPaths,
        tripId: tripId,
        user: user,
      );

      await _reviewsBox.put(reviewId, updatedReview);
      return updatedReview;
    } catch (e) {
      if (e is ReviewException) rethrow;
      throw ReviewException(
        'Failed to update review',
        code: 'UPDATE_REVIEW_ERROR',
        originalError: e,
      );
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      final review = _reviewsBox.get(reviewId);
      if (review == null) {
        throw ReviewException(
          'Review not found',
          code: 'REVIEW_NOT_FOUND',
        );
      }

      // Delete associated photos
      for (final path in review.photoPaths) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Failed to delete photo: $path');
        }
      }

      await _reviewsBox.delete(reviewId);
    } catch (e) {
      if (e is ReviewException) rethrow;
      throw ReviewException(
        'Failed to delete review',
        code: 'DELETE_REVIEW_ERROR',
        originalError: e,
      );
    }
  }

  /// Calculate average rating for a place
  double getAverageRating(String placeName) {
    final reviews = getReviewsByPlace(placeName);
    if (reviews.isEmpty) return 0.0;

    final totalRating = reviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );
    return totalRating / reviews.length;
  }

  /// Process and save a photo for a review
  /// For web platform, returns the source path as-is since we can't save to file system
  Future<String> processAndSavePhoto(String sourcePath) async {
    try {
      if (kIsWeb) {
        // For web platform, return the source path as-is
        debugPrint('Web review photo processed: $sourcePath');
        return sourcePath;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final reviewsDir = Directory('${appDir.path}/review_photos');
      if (!await reviewsDir.exists()) {
        await reviewsDir.create(recursive: true);
      }

      final fileName = '${const Uuid().v4()}.jpg';
      final targetPath = '${reviewsDir.path}/$fileName';

      // Compress and save the image
      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        throw ReviewException(
          'Failed to compress image',
          code: 'IMAGE_COMPRESSION_ERROR',
        );
      }

      return result.path;
    } catch (e) {
      if (e is ReviewException) rethrow;
      throw ReviewException(
        'Failed to process photo',
        code: 'PHOTO_PROCESSING_ERROR',
        originalError: e,
      );
    }
  }

  /// Get top-rated places (for recommendations)
  List<MapEntry<String, double>> getTopRatedPlaces({int limit = 5}) {
    final places = <String, List<int>>{};

    for (final review in _reviewsBox.values) {
      places.putIfAbsent(review.placeName, () => []);
      places[review.placeName]!.add(review.rating);
    }

    final averageRatings = places.map((place, ratings) {
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      return MapEntry(place, avg);
    });

    final sortedPlaces = averageRatings.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedPlaces.take(limit).toList();
  }

  /// Clear reviews (for testing)
  @visibleForTesting
  Future<void> clearReviews() async {
    await _reviewsBox.clear();
  }
}

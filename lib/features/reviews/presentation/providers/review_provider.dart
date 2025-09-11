import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_planner/features/reviews/data/review_service.dart';
import 'package:travel_planner/features/reviews/domain/models/review.dart';

/// Review Service Provider
final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

/// State class for reviews
class ReviewsState {
  final List<Review> reviews;
  final Map<String, double> averageRatings;
  final bool isLoading;
  final String? errorMessage;
  final List<MapEntry<String, double>> recommendations;

  const ReviewsState({
    this.reviews = const [],
    this.averageRatings = const {},
    this.isLoading = false,
    this.errorMessage,
    this.recommendations = const [],
  });

  ReviewsState copyWith({
    List<Review>? reviews,
    Map<String, double>? averageRatings,
    bool? isLoading,
    String? errorMessage,
    List<MapEntry<String, double>>? recommendations,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      averageRatings: averageRatings ?? this.averageRatings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}

/// Reviews State Provider
final reviewsStateProvider =
    StateNotifierProvider<ReviewsNotifier, ReviewsState>((ref) {
  final reviewService = ref.watch(reviewServiceProvider);
  return ReviewsNotifier(reviewService);
});

/// Place-specific Reviews Provider
final placeReviewsProvider =
    Provider.family<List<Review>, String>((ref, placeName) {
  final state = ref.watch(reviewsStateProvider);
  return state.reviews
      .where((review) => review.placeName == placeName)
      .toList();
});

/// Trip-specific Reviews Provider
final tripReviewsProvider =
    Provider.family<List<Review>, String>((ref, tripId) {
  final state = ref.watch(reviewsStateProvider);
  return state.reviews.where((review) => review.tripId == tripId).toList();
});

/// Place Average Rating Provider
final placeAverageRatingProvider =
    Provider.family<double, String>((ref, placeName) {
  final state = ref.watch(reviewsStateProvider);
  return state.averageRatings[placeName] ?? 0.0;
});

/// Recommendations Provider
final recommendationsProvider = Provider<List<MapEntry<String, double>>>((ref) {
  final state = ref.watch(reviewsStateProvider);
  return state.recommendations;
});

/// Reviews State Notifier
class ReviewsNotifier extends StateNotifier<ReviewsState> {
  final ReviewService _reviewService;
  final _imagePicker = ImagePicker();

  ReviewsNotifier(this._reviewService) : super(const ReviewsState()) {
    // Load initial data
    loadReviews();
  }

  /// Load all reviews and calculate ratings
  Future<void> loadReviews() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final reviews = _reviewService.getAllReviews();
      final averageRatings = <String, double>{};

      // Calculate average ratings for each place
      for (final review in reviews) {
        averageRatings[review.placeName] =
            _reviewService.getAverageRating(review.placeName);
      }

      // Get recommendations
      final recommendations = _reviewService.getTopRatedPlaces();

      state = state.copyWith(
        reviews: reviews,
        averageRatings: averageRatings,
        recommendations: recommendations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Add a new review
  Future<void> addReview({
    required String placeName,
    required int rating,
    required String text,
    String? tripId,
    required ReviewUser user,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final review = await _reviewService.addReview(
        placeName: placeName,
        rating: rating,
        text: text,
        photoPaths: [],
        tripId: tripId,
        user: user,
      );

      final updatedReviews = [...state.reviews, review];
      final averageRating = _reviewService.getAverageRating(placeName);
      final recommendations = _reviewService.getTopRatedPlaces();

      state = state.copyWith(
        reviews: updatedReviews,
        averageRatings: {...state.averageRatings, placeName: averageRating},
        recommendations: recommendations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Add photos to a review
  Future<void> addPhotosToReview(String reviewId, List<XFile> photos) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final processedPaths = <String>[];
      for (final photo in photos) {
        final processedPath =
            await _reviewService.processAndSavePhoto(photo.path);
        processedPaths.add(processedPath);
      }

      final review = state.reviews.firstWhere((r) => r.id == reviewId);
      final updatedReview = await _reviewService.updateReview(
        reviewId: reviewId,
        photoPaths: [...review.photoPaths, ...processedPaths],
      );

      final updatedReviews = state.reviews.map((r) {
        return r.id == reviewId ? updatedReview : r;
      }).toList();

      state = state.copyWith(
        reviews: updatedReviews,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Update an existing review
  Future<void> updateReview({
    required String reviewId,
    String? placeName,
    int? rating,
    String? text,
    List<String>? photoPaths,
    String? Function()? tripId,
    ReviewUser? user,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedReview = await _reviewService.updateReview(
        reviewId: reviewId,
        placeName: placeName,
        rating: rating,
        text: text,
        photoPaths: photoPaths,
        tripId: tripId,
        user: user,
      );

      final updatedReviews = state.reviews.map((r) {
        return r.id == reviewId ? updatedReview : r;
      }).toList();

      final averageRatings = {...state.averageRatings};
      if (placeName != null || rating != null) {
        averageRatings[updatedReview.placeName] =
            _reviewService.getAverageRating(updatedReview.placeName);
      }

      final recommendations = _reviewService.getTopRatedPlaces();

      state = state.copyWith(
        reviews: updatedReviews,
        averageRatings: averageRatings,
        recommendations: recommendations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final review = state.reviews.firstWhere((r) => r.id == reviewId);
      await _reviewService.deleteReview(reviewId);

      final updatedReviews =
          state.reviews.where((r) => r.id != reviewId).toList();
      final averageRating = _reviewService.getAverageRating(review.placeName);
      final recommendations = _reviewService.getTopRatedPlaces();

      state = state.copyWith(
        reviews: updatedReviews,
        averageRatings: {
          ...state.averageRatings,
          review.placeName: averageRating,
        },
        recommendations: recommendations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Pick photos from gallery or camera
  Future<List<XFile>> pickPhotos({bool fromCamera = false}) async {
    try {
      if (fromCamera) {
        final photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        return photo != null ? [photo] : [];
      } else {
        final photos = await _imagePicker.pickMultiImage(imageQuality: 70);
        return photos;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to pick photos: ${e.toString()}',
      );
      return [];
    }
  }
}

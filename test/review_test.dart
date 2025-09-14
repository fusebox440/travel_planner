import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/reviews/domain/models/review.dart';
import 'package:travel_planner/features/reviews/data/review_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/mock/docs';
}

void main() {
  group('Review System Tests', () {
    late Box<Review> reviewBox;
    late ReviewService reviewService;

    setUpAll(() async {
      // Mock the path provider
      PathProviderPlatform.instance = MockPathProviderPlatform();

      await Hive.initFlutter();

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(31)) {
        Hive.registerAdapter(ReviewAdapter());
      }
      if (!Hive.isAdapterRegistered(32)) {
        Hive.registerAdapter(ReviewUserAdapter());
      }

      reviewBox = await Hive.openBox<Review>('test_reviews');
      reviewService = ReviewService();
      await reviewService.init();
    });

    setUp(() async {
      await reviewBox.clear();
    });

    test('Create and retrieve a review', () async {
      final user = ReviewUser(name: 'John Doe', avatarUrl: null);
      final review = Review.create(
        placeName: 'Eiffel Tower',
        rating: 5,
        text: 'Amazing experience!',
        photoPaths: [],
        tripId: 'trip1',
        user: user,
      );

      // Add review directly to box for testing
      await reviewBox.put(review.id, review);

      // Test retrieval logic
      final reviews = reviewBox.values
          .where((review) => review.placeName == 'Eiffel Tower')
          .toList();
      expect(reviews.length, 1);
      expect(reviews.first.rating, 5);
      expect(reviews.first.text, 'Amazing experience!');
    });

    test('Calculate average rating for a place', () async {
      final user = ReviewUser(name: 'John Doe', avatarUrl: null);

      // Add multiple reviews for the same place
      await reviewBox.put(
          'review1',
          Review.create(
            placeName: 'Louvre Museum',
            rating: 4,
            text: 'Great museum',
            photoPaths: [],
            tripId: 'trip1',
            user: user,
          ));

      await reviewBox.put(
          'review2',
          Review.create(
            placeName: 'Louvre Museum',
            rating: 5,
            text: 'Excellent collection',
            photoPaths: [],
            tripId: 'trip1',
            user: user,
          ));

      await reviewBox.put(
          'review3',
          Review.create(
            placeName: 'Louvre Museum',
            rating: 3,
            text: 'Too crowded',
            photoPaths: [],
            tripId: 'trip2',
            user: user,
          ));

      // Test average calculation
      final reviews = reviewBox.values
          .where((review) => review.placeName == 'Louvre Museum')
          .toList();

      final totalRating =
          reviews.fold<int>(0, (sum, review) => sum + review.rating);
      final averageRating = totalRating / reviews.length;

      expect(reviews.length, 3);
      expect(averageRating, 4.0);
    });

    tearDownAll(() async {
      await reviewBox.deleteFromDisk();
    });
  });
}

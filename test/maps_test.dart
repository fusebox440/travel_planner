import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_planner/features/maps/data/maps_service.dart';
import 'package:travel_planner/features/maps/data/bookmark_service.dart';
import 'package:travel_planner/features/maps/domain/models/place.dart';

class MockMapsService extends Mock implements MapsService {}

class MockBookmarkService extends Mock implements BookmarkService {}

void main() {
  late MockMapsService mapsService;
  late MockBookmarkService bookmarkService;

  setUp(() {
    mapsService = MockMapsService();
    bookmarkService = MockBookmarkService();
  });

  group('MapsService', () {
    test('searchPlaces returns list of places', () async {
      final testPlaces = [
        Place(
          name: 'Test Place',
          lat: 0.0,
          lng: 0.0,
          type: PlaceType.attraction,
        ),
      ];

      when(() => mapsService.searchPlaces('test')).thenAnswer(
        (_) async => testPlaces,
      );

      final result = await mapsService.searchPlaces('test');

      expect(result, equals(testPlaces));
      verify(() => mapsService.searchPlaces('test')).called(1);
    });

    test('getDirections returns directions result', () async {
      final from = const LatLng(0, 0);
      final to = const LatLng(1, 1);
      final testDirections = DirectionsResult(
        polylinePoints: [from, to],
        distance: '1 km',
        duration: '5 mins',
        steps: ['Step 1', 'Step 2'],
        mode: 'driving',
      );

      when(() => mapsService.getDirections(from, to))
          .thenAnswer((_) async => testDirections);

      final result = await mapsService.getDirections(from, to);

      expect(result.polylinePoints, equals([from, to]));
      expect(result.distance, equals('1 km'));
      expect(result.duration, equals('5 mins'));
      expect(result.steps, equals(['Step 1', 'Step 2']));
      expect(result.mode, equals('driving'));
      verify(() => mapsService.getDirections(from, to)).called(1);
    });
  });

  group('BookmarkService', () {
    test('addBookmark adds place to bookmarks', () async {
      final testPlace = Place(
        name: 'Test Place',
        lat: 0.0,
        lng: 0.0,
        type: PlaceType.attraction,
      );

      when(() => bookmarkService.addBookmark(testPlace))
          .thenAnswer((_) async {});
      when(() => bookmarkService.isBookmarked(testPlace.id))
          .thenAnswer((_) async => true);

      await bookmarkService.addBookmark(testPlace);
      final isBookmarked = await bookmarkService.isBookmarked(testPlace.id);

      expect(isBookmarked, isTrue);
      verify(() => bookmarkService.addBookmark(testPlace)).called(1);
      verify(() => bookmarkService.isBookmarked(testPlace.id)).called(1);
    });

    test('removeBookmark removes place from bookmarks', () async {
      const testPlaceId = 'test-id';

      when(() => bookmarkService.removeBookmark(testPlaceId))
          .thenAnswer((_) async {});
      when(() => bookmarkService.isBookmarked(testPlaceId))
          .thenAnswer((_) async => false);

      await bookmarkService.removeBookmark(testPlaceId);
      final isBookmarked = await bookmarkService.isBookmarked(testPlaceId);

      expect(isBookmarked, isFalse);
      verify(() => bookmarkService.removeBookmark(testPlaceId)).called(1);
      verify(() => bookmarkService.isBookmarked(testPlaceId)).called(1);
    });

    test('getBookmarks returns list of bookmarked places', () async {
      final testPlaces = [
        Place(
          name: 'Test Place 1',
          lat: 0.0,
          lng: 0.0,
          type: PlaceType.attraction,
        ),
        Place(
          name: 'Test Place 2',
          lat: 1.0,
          lng: 1.0,
          type: PlaceType.restaurant,
        ),
      ];

      when(() => bookmarkService.getBookmarks())
          .thenAnswer((_) async => testPlaces);

      final bookmarks = await bookmarkService.getBookmarks();

      expect(bookmarks, equals(testPlaces));
      expect(bookmarks.length, equals(2));
      verify(() => bookmarkService.getBookmarks()).called(1);
    });
  });
}

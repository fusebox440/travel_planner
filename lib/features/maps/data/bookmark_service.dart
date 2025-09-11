import 'package:hive/hive.dart';
import '../domain/models/place.dart';

class BookmarkService {
  static const _boxName = 'bookmarks';
  late Box<Place> _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Place>(_boxName);
    }
  }

  Future<void> addBookmark(Place place) async {
    final updatedPlace = place.copyWith(isBookmarked: true);
    await _box.put(place.id, updatedPlace);
  }

  Future<void> removeBookmark(String placeId) async {
    await _box.delete(placeId);
  }

  Future<List<Place>> getBookmarks() async {
    return _box.values.toList();
  }

  Future<bool> isBookmarked(String placeId) async {
    return _box.containsKey(placeId);
  }

  Future<void> close() async {
    await _box.close();
  }
}

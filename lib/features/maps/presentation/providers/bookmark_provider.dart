import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/bookmark_service.dart';
import '../../domain/models/place.dart';

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  final service = BookmarkService();
  service.init();
  ref.onDispose(() => service.close());
  return service;
});

class BookmarkState {
  final List<Place> bookmarks;
  final bool isLoading;
  final String? error;

  const BookmarkState({
    this.bookmarks = const [],
    this.isLoading = false,
    this.error,
  });

  BookmarkState copyWith({
    List<Place>? bookmarks,
    bool? isLoading,
    String? error,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  final BookmarkService _bookmarkService;

  BookmarkNotifier(this._bookmarkService) : super(const BookmarkState()) {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bookmarks = await _bookmarkService.getBookmarks();
      state = state.copyWith(bookmarks: bookmarks, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load bookmarks: $e',
        isLoading: false,
      );
    }
  }

  Future<void> addBookmark(Place place) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _bookmarkService.addBookmark(place);
      await loadBookmarks();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to add bookmark: $e',
        isLoading: false,
      );
    }
  }

  Future<void> removeBookmark(String placeId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _bookmarkService.removeBookmark(placeId);
      await loadBookmarks();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to remove bookmark: $e',
        isLoading: false,
      );
    }
  }
}

final bookmarkProvider =
    StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  final bookmarkService = ref.watch(bookmarkServiceProvider);
  return BookmarkNotifier(bookmarkService);
});

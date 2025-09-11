import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerformanceOptimizer {
  // Memory cache for expensive computations
  static final Map<String, dynamic> _cache = {};
  static const Duration _defaultCacheDuration = Duration(minutes: 5);

  // Cached data getter with expiration
  static T? getCachedData<T>(String key) {
    if (!_cache.containsKey(key)) return null;

    final cacheEntry = _cache[key] as _CacheEntry<T>;
    if (cacheEntry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return cacheEntry.data;
  }

  // Cache data with expiration
  static void cacheData<T>(
    String key,
    T data, {
    Duration? duration,
  }) {
    _cache[key] = _CacheEntry<T>(
      data: data,
      expiresAt: DateTime.now().add(duration ?? _defaultCacheDuration),
    );
  }

  // Clear expired cache entries
  static void clearExpiredCache() {
    _cache.removeWhere((_, value) => (value as _CacheEntry).isExpired);
  }

  // Clear all cache
  static void clearAllCache() {
    _cache.clear();
  }
}

// Cache entry with expiration
class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  _CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// Performance optimized list view
class PerformanceOptimizedListView extends ConsumerStatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const PerformanceOptimizedListView({
    super.key,
    required this.children,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  ConsumerState<PerformanceOptimizedListView> createState() =>
      _PerformanceOptimizedListViewState();
}

class _PerformanceOptimizedListViewState
    extends ConsumerState<PerformanceOptimizedListView> {
  final List<Widget> _visibleItems = [];
  final ScrollController _defaultController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateVisibleItems();
    (widget.controller ?? _defaultController).addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller?.hasClients != true) {
      _defaultController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    _updateVisibleItems();
  }

  void _updateVisibleItems() {
    final controller = widget.controller ?? _defaultController;
    if (!controller.hasClients) return;

    setState(() {
      _visibleItems.clear();
      final viewportHeight = controller.position.viewportDimension;
      final offset = controller.offset;

      // Calculate which items should be visible
      double currentHeight = 0;
      for (var child in widget.children) {
        if (currentHeight >= offset - viewportHeight &&
            currentHeight <= offset + viewportHeight * 2) {
          _visibleItems.add(child);
        }
        // Estimate height - in a real app, you might want to cache actual heights
        currentHeight += 50; // Example height
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.controller ?? _defaultController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      children: _visibleItems,
    );
  }
}

// Extension for widget optimization
extension PerformanceOptimizedWidget on Widget {
  Widget withOptimization({String? key}) {
    return _OptimizedWidget(
      key: Key(key ?? hashCode.toString()),
      child: this,
    );
  }
}

class _OptimizedWidget extends StatefulWidget {
  final Widget child;

  const _OptimizedWidget({
    required Key key,
    required this.child,
  }) : super(key: key);

  @override
  State<_OptimizedWidget> createState() => _OptimizedWidgetState();
}

class _OptimizedWidgetState extends State<_OptimizedWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

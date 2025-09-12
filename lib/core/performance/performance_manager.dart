import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Performance monitoring and optimization utilities
class PerformanceManager {
  static const _platform = MethodChannel('travel_planner/performance');

  /// Track memory usage
  static Future<Map<String, dynamic>?> getMemoryUsage() async {
    try {
      final result =
          await _platform.invokeMethod<Map<String, dynamic>>('getMemoryUsage');
      return result;
    } on PlatformException {
      return null;
    }
  }

  /// Clear image cache to free memory
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Optimize image cache settings
  static void optimizeImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
  }
}

/// Lazy loading list view with performance optimizations
class LazyLoadingListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<List<T>> Function()? onLoadMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final int initialLoadCount;

  const LazyLoadingListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.loadingWidget,
    this.emptyWidget,
    this.padding,
    this.controller,
    this.initialLoadCount = 20,
  });

  @override
  State<LazyLoadingListView<T>> createState() => _LazyLoadingListViewState<T>();
}

class _LazyLoadingListViewState<T> extends State<LazyLoadingListView<T>> {
  late ScrollController _scrollController;
  bool _isLoading = false;
  List<T> _displayedItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _initializeItems();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _initializeItems() {
    setState(() {
      _displayedItems = widget.items.take(widget.initialLoadCount).toList();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() async {
    if (_isLoading || widget.onLoadMore == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await widget.onLoadMore!();
      setState(() {
        _displayedItems.addAll(newItems);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedItems.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: _displayedItems.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _displayedItems.length) {
          return widget.loadingWidget ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
        }

        return widget.itemBuilder(context, _displayedItems[index], index);
      },
    );
  }
}

/// Optimized image widget with caching and lazy loading
class OptimizedImage extends StatefulWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableMemoryCache;
  final int? cacheWidth;
  final int? cacheHeight;

  const OptimizedImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  @override
  Widget build(BuildContext context) {
    if (widget.assetPath != null) {
      return Image.asset(
        widget.assetPath!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? _buildErrorWidget();
        },
      );
    }

    if (widget.imageUrl != null) {
      return Image.network(
        widget.imageUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return widget.placeholder ?? _buildPlaceholder(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? _buildErrorWidget();
        },
      );
    }

    return widget.errorWidget ?? _buildErrorWidget();
  }

  Widget _buildPlaceholder(ImageChunkEvent? loadingProgress) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress?.expectedTotalBytes != null
              ? loadingProgress!.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}

/// Skeleton loading widget for better perceived performance
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                math.max(0.0, _animation.value - 0.3),
                _animation.value,
                math.min(1.0, _animation.value + 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton layouts for different content types
class SkeletonLayouts {
  static Widget listTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SkeletonLoader(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 120, height: 16),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 80,
                  height: 12,
                  baseColor: Colors.grey[200],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget card() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: double.infinity, height: 200),
          SizedBox(height: 16),
          SkeletonLoader(width: 150, height: 20),
          SizedBox(height: 8),
          SkeletonLoader(width: 100, height: 16),
          SizedBox(height: 8),
          SkeletonLoader(width: 200, height: 14),
        ],
      ),
    );
  }

  static Widget profile() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonLoader(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          SizedBox(height: 16),
          SkeletonLoader(width: 120, height: 20),
          SizedBox(height: 8),
          SkeletonLoader(width: 80, height: 16),
        ],
      ),
    );
  }
}

/// Performance-optimized list with smooth animations
class SmoothAnimatedList extends StatefulWidget {
  final List<Widget> children;
  final Duration animationDuration;
  final Curve animationCurve;
  final double staggerDelay;
  final ScrollController? controller;

  const SmoothAnimatedList({
    super.key,
    required this.children,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOut,
    this.staggerDelay = 50.0,
    this.controller,
  });

  @override
  State<SmoothAnimatedList> createState() => _SmoothAnimatedListState();
}

class _SmoothAnimatedListState extends State<SmoothAnimatedList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: widget.animationCurve),
      );
    }).toList();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: (i * widget.staggerDelay).round()),
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _animations[index].value)),
              child: Opacity(
                opacity: _animations[index].value,
                child: widget.children[index],
              ),
            );
          },
        );
      },
    );
  }
}

/// Memory-efficient image cache manager
class ImageCacheManager {
  static const int _maxCacheSize = 100;
  static const int _maxMemorySize = 50 * 1024 * 1024; // 50MB

  static void initialize() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = _maxCacheSize;
    imageCache.maximumSizeBytes = _maxMemorySize;
  }

  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
  }

  static void evictImage(String url) {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.evict(NetworkImage(url));
  }

  static int get currentCacheSize {
    return PaintingBinding.instance.imageCache.currentSize;
  }

  static int get currentCacheSizeBytes {
    return PaintingBinding.instance.imageCache.currentSizeBytes;
  }
}

/// Performance monitoring widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  Map<String, dynamic>? _memoryStats;

  @override
  void initState() {
    super.initState();
    _updateMemoryStats();
  }

  void _updateMemoryStats() async {
    if (widget.showOverlay) {
      final stats = await PerformanceManager.getMemoryUsage();
      if (mounted) {
        setState(() {
          _memoryStats = stats;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay && _memoryStats != null)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Memory: ${_memoryStats!['used']}MB',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Cache: ${ImageCacheManager.currentCacheSize} items',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Cache Size: ${(ImageCacheManager.currentCacheSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

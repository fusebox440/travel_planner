import 'package:flutter/material.dart';
import 'package:travel_planner/core/performance/performance_manager.dart';

/// Skeleton screens for different app sections
class SkeletonScreens {
  /// Skeleton for trips list
  static Widget tripsListSkeleton() {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SkeletonLoader(
                      width: 60,
                      height: 60,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonLoader(width: 120, height: 20),
                          const SizedBox(height: 8),
                          SkeletonLoader(
                            width: 80,
                            height: 16,
                            baseColor: Colors.grey[200],
                          ),
                        ],
                      ),
                    ),
                    const SkeletonLoader(
                      width: 24,
                      height: 24,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SkeletonLoader(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 150, height: 12),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SkeletonLoader(width: 60, height: 24),
                    const SizedBox(width: 12),
                    const SkeletonLoader(width: 60, height: 24),
                    const Spacer(),
                    const SkeletonLoader(width: 80, height: 24),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Skeleton for weather screen
  static Widget weatherSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current weather card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                SkeletonLoader(
                  width: 100,
                  height: 20,
                  highlightColor: Colors.white24,
                  baseColor: Colors.white12,
                ),
                SizedBox(height: 16),
                SkeletonLoader(
                  width: 80,
                  height: 80,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  highlightColor: Colors.white24,
                  baseColor: Colors.white12,
                ),
                SizedBox(height: 16),
                SkeletonLoader(
                  width: 60,
                  height: 32,
                  highlightColor: Colors.white24,
                  baseColor: Colors.white12,
                ),
                SizedBox(height: 8),
                SkeletonLoader(
                  width: 120,
                  height: 16,
                  highlightColor: Colors.white24,
                  baseColor: Colors.white12,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Hourly forecast
          const Row(
            children: [
              SkeletonLoader(width: 100, height: 20),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SkeletonLoader(width: 30, height: 12),
                      SkeletonLoader(width: 40, height: 40),
                      SkeletonLoader(width: 25, height: 14),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Daily forecast
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      SkeletonLoader(width: 60, height: 16),
                      SizedBox(width: 16),
                      SkeletonLoader(width: 40, height: 40),
                      Spacer(),
                      SkeletonLoader(width: 80, height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton for maps screen
  static Widget mapsSkeleton() {
    return Stack(
      children: [
        // Map placeholder
        Container(
          color: Colors.grey[300],
          child: const Center(
            child: SkeletonLoader(
              width: 100,
              height: 100,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          ),
        ),

        // Search bar
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Row(
              children: [
                SkeletonLoader(width: 24, height: 24),
                SizedBox(width: 16),
                Expanded(
                    child: SkeletonLoader(width: double.infinity, height: 20)),
              ],
            ),
          ),
        ),

        // Bottom sheet
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SkeletonLoader(
                    width: 40,
                    height: 4,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const SkeletonLoader(width: 150, height: 24),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 100, height: 16),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: const Column(
                          children: [
                            SkeletonLoader(
                              width: 100,
                              height: 80,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            SizedBox(height: 8),
                            SkeletonLoader(width: 80, height: 12),
                            SizedBox(height: 4),
                            SkeletonLoader(width: 60, height: 10),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Skeleton for reviews screen
  static Widget reviewsSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SkeletonLoader(
                    width: 50,
                    height: 50,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SkeletonLoader(width: 100, height: 16),
                        const SizedBox(height: 4),
                        SkeletonLoader(
                          width: 80,
                          height: 12,
                          baseColor: Colors.grey[200],
                        ),
                      ],
                    ),
                  ),
                  const SkeletonLoader(width: 60, height: 20),
                ],
              ),
              const SizedBox(height: 16),
              const SkeletonLoader(width: double.infinity, height: 100),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SkeletonLoader(width: 80, height: 16),
                  const Spacer(),
                  const SkeletonLoader(width: 40, height: 16),
                  const SizedBox(width: 8),
                  const SkeletonLoader(width: 40, height: 16),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Skeleton for packing list
  static Widget packingListSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const SkeletonLoader(width: 150, height: 24),
          const SizedBox(height: 8),
          const SkeletonLoader(width: 100, height: 16),
          const SizedBox(height: 24),

          // Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: const SkeletonLoader(
                    width: 80,
                    height: 32,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Packing items
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      const SkeletonLoader(
                        width: 24,
                        height: 24,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child:
                            SkeletonLoader(width: double.infinity, height: 16),
                      ),
                      const SizedBox(width: 16),
                      SkeletonLoader(
                        width: 30,
                        height: 16,
                        baseColor: Colors.grey[200],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton for badges screen
  static Widget badgesSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User level card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                SkeletonLoader(
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  highlightColor: Colors.white24,
                  baseColor: Colors.white12,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        width: 150,
                        height: 20,
                        highlightColor: Colors.white24,
                        baseColor: Colors.white12,
                      ),
                      SizedBox(height: 8),
                      SkeletonLoader(
                        width: 100,
                        height: 16,
                        highlightColor: Colors.white24,
                        baseColor: Colors.white12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section title
          const SkeletonLoader(width: 120, height: 24),
          const SizedBox(height: 16),

          // Badges grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonLoader(
                        width: 50,
                        height: 50,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      SizedBox(height: 8),
                      SkeletonLoader(width: 60, height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Performance-aware skeleton wrapper
class SmartSkeleton extends StatefulWidget {
  final Widget skeleton;
  final Widget child;
  final Duration delay;
  final bool showSkeleton;

  const SmartSkeleton({
    super.key,
    required this.skeleton,
    required this.child,
    this.delay = const Duration(milliseconds: 500),
    this.showSkeleton = true,
  });

  @override
  State<SmartSkeleton> createState() => _SmartSkeletonState();
}

class _SmartSkeletonState extends State<SmartSkeleton> {
  bool _showSkeleton = true;

  @override
  void initState() {
    super.initState();
    if (widget.showSkeleton) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          setState(() {
            _showSkeleton = false;
          });
        }
      });
    } else {
      _showSkeleton = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showSkeleton ? widget.skeleton : widget.child,
    );
  }
}

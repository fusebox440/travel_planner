import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/core/theme/grey_mode_adjustments.dart';
import 'package:travel_planner/features/trips/presentation/providers/trip_providers.dart';
import 'package:travel_planner/features/trips/presentation/widgets/add_activity_sheet.dart';
import 'package:travel_planner/features/trips/presentation/widgets/full_screen_viewer.dart';
import 'package:travel_planner/src/models/activity.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/widgets/empty_state_widget.dart';
import 'package:travel_planner/widgets/skeletons.dart';
import 'package:uuid/uuid.dart';

class TripDetailScreen extends ConsumerWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripValue = ref.watch(tripDetailProvider(tripId));
    return Scaffold(
      body: tripValue.when(
        data: (trip) {
          if (trip == null) return const Center(child: Text('Trip not found'));
          return CustomScrollView(
            slivers: [
              _ParallaxHeader(trip: trip),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.checkroom_outlined),
                            title: const Text('View Packing List'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.go('/trip/${trip.id}/packing-list',
                                  extra: trip);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: ListTile(
                            leading: const Icon(
                                Icons.account_balance_wallet_outlined),
                            title: const Text('Budget Tracking'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.go('/trip/${trip.id}/budget');
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.search_outlined),
                            title: const Text('Search Bookings'),
                            subtitle: const Text(
                                'Find flights, hotels, cars & activities'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.go('/bookings/search');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AddDayButton(tripId: trip.id),
                  ...trip.days
                      .map((day) => _DayCard(tripId: trip.id, day: day)),
                  const SizedBox(height: 80),
                ]),
              ),
            ],
          );
        },
        loading: () => const CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              flexibleSpace:
                  FlexibleSpaceBar(background: MapPlaceholderSkeleton()),
            ),
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                SizedBox(height: 16),
                ActivityItemSkeleton(),
                ActivityItemSkeleton(),
                ActivityItemSkeleton(),
              ]),
            ),
          ],
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _ParallaxHeader extends StatelessWidget {
  final Trip trip;
  const _ParallaxHeader({required this.trip});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(trip.title,
            style: const TextStyle(shadows: [Shadow(blurRadius: 8)])),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildParallaxBackground(context),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _MapPreview(),
                  Text(
                    '${DateFormat.yMMMd().format(trip.startDate)} - ${DateFormat.yMMMd().format(trip.endDate)}',
                    style: const TextStyle(
                        color: Colors.white, shadows: [Shadow(blurRadius: 4)]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/trip/${trip.id}/edit');
          },
        ),
      ],
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    if (trip.imageUrl != null && trip.imageUrl!.isNotEmpty) {
      return GreyModeFilter(
        child: CachedNetworkImage(
          imageUrl: trip.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(color: Theme.of(context).colorScheme.primaryContainer),
          errorWidget: (context, url, error) => _buildGradientFallback(context),
        ),
      );
    } else {
      return _buildGradientFallback(context);
    }
  }

  Widget _buildGradientFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
      ),
    );
  }
}

class _MapPreview extends StatefulWidget {
  const _MapPreview();
  @override
  State<_MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<_MapPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.map, size: 30, color: Colors.grey),
              ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: _controller, curve: Curves.easeOut)),
                child: FadeTransition(
                  opacity:
                      Tween<double>(begin: 1.0, end: 0.0).animate(_controller),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddDayButton extends ConsumerWidget {
  final String tripId;
  const _AddDayButton({required this.tripId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Day'),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () {
          HapticFeedback.lightImpact();
          final trip = ref.read(tripDetailProvider(tripId)).value;
          if (trip != null) {
            final newDate = trip.days.isNotEmpty
                ? trip.days.last.date.add(const Duration(days: 1))
                : trip.startDate;
            final newDay = Day(
                id: const Uuid().v4(),
                date: newDate,
                activities: HiveList(Hive.box<Activity>('activities')));
            ref.read(tripListProvider.notifier).addDayToTrip(tripId, newDay);
          }
        },
      ),
    );
  }
}

class _DayCard extends StatefulWidget {
  final String tripId;
  final Day day;
  const _DayCard({required this.tripId, required this.day});
  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _isExpanded = true;
  void _showAddActivitySheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          AddActivitySheet(tripId: widget.tripId, dayId: widget.day.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            title: Text(DateFormat.yMMMEd().format(widget.day.date),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isExpanded = !_isExpanded);
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Visibility(
              visible: _isExpanded,
              child: Column(
                children: [
                  if (widget.day.activities.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.add_task_rounded,
                      title: 'Ready to plan your day?',
                      description: 'Add your first activity to get started!',
                      actionText: 'Add Activity',
                      onActionPressed: _showAddActivitySheet,
                    )
                  else
                    ...widget.day.activities.map((activity) => _ActivityCard(
                          tripId: widget.tripId,
                          dayId: widget.day.id,
                          activity: activity,
                        )),
                  if (widget.day.activities.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton.small(
                        heroTag: 'fab-${widget.day.id}',
                        tooltip: 'Add Activity',
                        onPressed: _showAddActivitySheet,
                        child: const Icon(Icons.add),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  final String tripId;
  final String dayId;
  final Activity activity;
  const _ActivityCard(
      {required this.tripId, required this.dayId, required this.activity});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: SizedBox(
        width: 100,
        child: activity.imagePaths.isEmpty
            ? const Icon(Icons.photo_size_select_actual_outlined,
                color: Colors.grey)
            : ListView(
                scrollDirection: Axis.horizontal,
                children: activity.imagePaths
                    .map((path) => Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      FullScreenImageViewer(imagePath: path)));
                            },
                            child: Hero(
                              tag: path,
                              child: Image.file(File(path),
                                  width: 50, height: 50, fit: BoxFit.cover),
                            ),
                          ),
                        ))
                    .toList(),
              ),
      ),
      title: Text(activity.title),
      subtitle: Text(DateFormat.jm().format(activity.startTime)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Toggle Reminder',
            child: Switch(
              value: activity.reminderId != null,
              onChanged: (val) {
                HapticFeedback.lightImpact();
                ref
                    .read(tripListProvider.notifier)
                    .toggleActivityReminder(tripId, dayId, activity.id, val);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Delete Activity',
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref
                  .read(tripListProvider.notifier)
                  .deleteActivity(tripId, dayId, activity.id);
            },
          ),
        ],
      ),
    );
  }
}

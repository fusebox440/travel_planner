import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/design/app_spacing.dart';
import 'package:travel_planner/features/reviews/presentation/providers/review_provider.dart';
import 'package:travel_planner/features/reviews/presentation/screens/add_review_screen.dart';
import 'package:travel_planner/features/reviews/presentation/widgets/review_card.dart';

class ReviewsScreen extends ConsumerWidget {
  final String placeName;
  final String? tripId;

  const ReviewsScreen({
    super.key,
    required this.placeName,
    this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = tripId != null
        ? ref.watch(tripReviewsProvider(tripId!))
        : ref.watch(placeReviewsProvider(placeName));

    final averageRating = ref.watch(placeAverageRatingProvider(placeName));
    final state = ref.watch(reviewsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(placeName),
            Text(
              '${averageRating.toStringAsFixed(1)} ★ · ${reviews.length} reviews',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
              ? _buildEmptyState(context)
              : _buildReviewsList(context, reviews, ref), // Pass ref to method
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddReviewScreen(
                placeName: placeName,
                tripId: tripId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(height: AppSpacing.medium),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: AppSpacing.small),
          Text(
            'Be the first to review this place!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(
      BuildContext context, List<dynamic> reviews, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.medium),
          child: ReviewCard(
            review: review,
            onTap: () {
              // TODO: Show full review details
            },
            onEditPressed: () {
              // TODO: Handle edit
            },
            onDeletePressed: () {
              // Show delete confirmation dialog
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Review'),
                  content: const Text(
                      'Are you sure you want to delete this review?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        ref
                            .read(reviewsStateProvider.notifier)
                            .deleteReview(review.id);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

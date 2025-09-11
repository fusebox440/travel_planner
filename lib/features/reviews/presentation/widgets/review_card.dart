import 'dart:io';
import 'package:flutter/material.dart';
import 'package:travel_planner/core/design/app_spacing.dart';
import 'package:travel_planner/features/reviews/domain/models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final bool showActions;

  const ReviewCard({
    super.key,
    required this.review,
    this.onTap,
    this.onEditPressed,
    this.onDeletePressed,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            _buildContent(context),
            if (review.photoPaths.isNotEmpty) _buildPhotoGrid(),
            if (showActions) _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          review.user.name.substring(0, 1).toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      title: Text(review.user.name),
      subtitle: Text(review.placeName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber),
          Text(
            review.rating.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.medium),
      child: Text(
        review.text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.small),
        itemCount: review.photoPaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xsmall),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(review.photoPaths[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onEditPressed != null)
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: onEditPressed,
          ),
        if (onDeletePressed != null)
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: onDeletePressed,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../domain/models/trip_template.dart';

class TemplateCard extends StatelessWidget {
  final TripTemplate template;
  final VoidCallback onTap;
  final bool showUsageStats;
  final bool showFullDetails;

  const TemplateCard({
    Key? key,
    required this.template,
    required this.onTap,
    this.showUsageStats = false,
    this.showFullDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildTags(),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Template icon/image
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor(template.category).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(template.category),
            color: _getCategoryColor(template.category),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (template.isOfficial)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Official',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    template.durationText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      template.formattedBudgetRange,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      template.description,
      style: const TextStyle(fontSize: 14, height: 1.4),
      maxLines: showFullDetails ? null : 2,
      overflow: showFullDetails ? null : TextOverflow.ellipsis,
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: template.tags
          .take(showFullDetails ? template.tags.length : 4)
          .map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        if (template.hasRatings) ...[
          Icon(
            Icons.star,
            size: 16,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            template.formattedRating,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            ' (${template.ratingCount})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(width: 16),
        ],
        if (showUsageStats) ...[
          Icon(
            Icons.people,
            size: 16,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 4),
          Text(
            '${template.usageCount} uses',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
        ] else
          const Spacer(),
        if (template.creatorName != null)
          Text(
            'by ${template.creatorName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          ),
      ],
    );
  }

  Color _getCategoryColor(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.business:
        return Colors.blue;
      case TemplateCategory.leisure:
        return Colors.green;
      case TemplateCategory.adventure:
        return Colors.orange;
      case TemplateCategory.family:
        return Colors.purple;
      case TemplateCategory.romantic:
        return Colors.red;
      case TemplateCategory.cultural:
        return Colors.brown;
      case TemplateCategory.beach:
        return Colors.cyan;
      case TemplateCategory.city:
        return Colors.grey;
      case TemplateCategory.nature:
        return Colors.teal;
      case TemplateCategory.foodie:
        return Colors.deepOrange;
      case TemplateCategory.budget:
        return Colors.indigo;
      case TemplateCategory.luxury:
        return Colors.amber;
      case TemplateCategory.solo:
        return Colors.blueGrey;
      case TemplateCategory.group:
        return Colors.pink;
      case TemplateCategory.custom:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.business:
        return Icons.business;
      case TemplateCategory.leisure:
        return Icons.beach_access;
      case TemplateCategory.adventure:
        return Icons.hiking;
      case TemplateCategory.family:
        return Icons.family_restroom;
      case TemplateCategory.romantic:
        return Icons.favorite;
      case TemplateCategory.cultural:
        return Icons.museum;
      case TemplateCategory.beach:
        return Icons.waves;
      case TemplateCategory.city:
        return Icons.location_city;
      case TemplateCategory.nature:
        return Icons.nature;
      case TemplateCategory.foodie:
        return Icons.restaurant;
      case TemplateCategory.budget:
        return Icons.money_off;
      case TemplateCategory.luxury:
        return Icons.diamond;
      case TemplateCategory.solo:
        return Icons.person;
      case TemplateCategory.group:
        return Icons.group;
      case TemplateCategory.custom:
        return Icons.build;
    }
  }
}

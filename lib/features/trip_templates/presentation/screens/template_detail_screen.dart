import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trip_template_providers.dart';
import '../../domain/models/trip_template.dart';

class TemplateDetailScreen extends ConsumerStatefulWidget {
  final String templateId;

  const TemplateDetailScreen({
    Key? key,
    required this.templateId,
  }) : super(key: key);

  @override
  ConsumerState<TemplateDetailScreen> createState() =>
      _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(templateByIdProvider(widget.templateId));

    return Scaffold(
      body: templateAsync.when(
        data: (template) {
          if (template == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Template not found'),
                ],
              ),
            );
          }
          return _buildTemplateDetail(template);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateDetail(TripTemplate template) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              template.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: Colors.black54, blurRadius: 2),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getCategoryColor(template.category),
                    _getCategoryColor(template.category).withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(template.category),
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    right: 16,
                    child: Column(
                      children: [
                        if (template.isOfficial)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Official',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${template.usageCount} uses',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickStats(template),
                const SizedBox(height: 24),
                _buildDescription(template),
                const SizedBox(height: 24),
                _buildTags(template),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.schedule), text: 'Itinerary'),
              Tab(icon: Icon(Icons.luggage), text: 'Packing'),
              Tab(icon: Icon(Icons.group), text: 'Companions'),
              Tab(icon: Icon(Icons.star), text: 'Reviews'),
            ],
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildItineraryTab(template),
              _buildPackingTab(template),
              _buildCompanionsTab(template),
              _buildReviewsTab(template),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(TripTemplate template) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.schedule,
            title: 'Duration',
            value: template.durationText,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            title: 'Budget',
            value: template.formattedBudgetRange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            title: 'Rating',
            value: template.hasRatings ? template.formattedRating : 'N/A',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(TripTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          template.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (template.creatorName != null) ...[
          const SizedBox(height: 12),
          Text(
            'Created by ${template.creatorName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildTags(TripTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: template.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildItineraryTab(TripTemplate template) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: template.dayStructures.length,
      itemBuilder: (context, index) {
        final day = template.dayStructures[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text('${day.dayNumber}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (day.description != null)
                            Text(
                              day.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${day.estimatedBudget.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (day.activities.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...day.activities.map((activity) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 52, bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            activity.startTime,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(activity.title),
                          ),
                          if (activity.estimatedCost > 0)
                            Text(
                              '\$${activity.estimatedCost.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackingTab(TripTemplate template) {
    if (template.packingItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.luggage, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No packing suggestions'),
          ],
        ),
      );
    }

    final itemsByCategory = <String, List<TemplatePackingItem>>{};
    for (final item in template.packingItems) {
      itemsByCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemsByCategory.keys.length,
      itemBuilder: (context, index) {
        final category = itemsByCategory.keys.elementAt(index);
        final items = itemsByCategory[category]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 12),
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          item.isEssential
                              ? Icons.priority_high
                              : Icons.circle_outlined,
                          size: 16,
                          color: item.isEssential ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.name)),
                        if (item.quantity > 1)
                          Text(
                            '× ${item.quantity}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompanionsTab(TripTemplate template) {
    if (template.suggestedCompanions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No companion suggestions'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: template.suggestedCompanions.length,
      itemBuilder: (context, index) {
        final companion = template.suggestedCompanions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(_getCompanionIcon(companion.role)),
            ),
            title: Text(companion.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(companion.role.toUpperCase()),
                if (companion.preferences != null) Text(companion.preferences!),
              ],
            ),
            trailing: companion.isOptional
                ? const Text('Optional')
                : const Text('Required'),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(TripTemplate template) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRatingSection(template),
          const SizedBox(height: 24),
          const Expanded(
            child: Center(
              child: Text('Reviews functionality coming soon...'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(TripTemplate template) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate this template',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _userRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _userRating = index + 1.0;
                      });
                    },
                  );
                }),
                const SizedBox(width: 16),
                if (_userRating > 0)
                  ElevatedButton(
                    onPressed: () => _submitRating(template.id),
                    child: const Text('Submit'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (template.hasRatings)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${template.formattedRating} (${template.ratingCount} reviews)',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            else
              Text(
                'Be the first to rate this template!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  void _submitRating(String templateId) async {
    try {
      await ref
          .read(templateOperationsProvider.notifier)
          .rateTemplate(templateId, _userRating);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
      setState(() {
        _userRating = 0;
      });
      // Refresh the template data
      ref.invalidate(templateByIdProvider(templateId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    }
  }

  Color _getCategoryColor(TemplateCategory category) {
    // Same implementation as in TemplateCard
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
    // Same implementation as in TemplateCard
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

  IconData _getCompanionIcon(String role) {
    switch (role.toLowerCase()) {
      case 'spouse':
      case 'partner':
        return Icons.favorite;
      case 'friend':
        return Icons.people;
      case 'colleague':
        return Icons.business;
      case 'child':
        return Icons.child_care;
      case 'family':
        return Icons.family_restroom;
      default:
        return Icons.person;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/trip_template.dart';
import '../providers/trip_template_providers.dart';

class TemplateFiltersWidget extends ConsumerStatefulWidget {
  const TemplateFiltersWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<TemplateFiltersWidget> createState() =>
      _TemplateFiltersWidgetState();
}

class _TemplateFiltersWidgetState extends ConsumerState<TemplateFiltersWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _filtersExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(templateFiltersProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search templates...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(templateFiltersProvider.notifier)
                                    .updateSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      ref
                          .read(templateFiltersProvider.notifier)
                          .updateSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_filtersExpanded
                      ? Icons.filter_list_off
                      : Icons.filter_list),
                  onPressed: () {
                    setState(() {
                      _filtersExpanded = !_filtersExpanded;
                    });
                  },
                  tooltip: _filtersExpanded ? 'Hide filters' : 'Show filters',
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _filtersExpanded ? null : 0,
            child: _filtersExpanded ? _buildExpandedFilters(filters) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedFilters(TemplateFilters filters) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),

          // Category filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildCategoryFilter(filters.category),

          const SizedBox(height: 16),

          // Duration filter
          Text(
            'Duration',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildDurationFilter(
              filters.minDurationDays, filters.maxDurationDays),

          const SizedBox(height: 16),

          // Budget filter
          Text(
            'Budget Range',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildBudgetFilter(filters.minBudget, filters.maxBudget),

          const SizedBox(height: 16),

          // Sort options
          Text(
            'Sort by',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildSortOptions(filters.sortOption),

          const SizedBox(height: 16),

          // Clear filters button
          Center(
            child: TextButton(
              onPressed: () {
                ref.read(templateFiltersProvider.notifier).clearFilters();
                _searchController.clear();
              },
              child: const Text('Clear All Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(TemplateCategory? selectedCategory) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: selectedCategory == null,
          onSelected: (selected) {
            ref.read(templateFiltersProvider.notifier).updateCategory(null);
          },
        ),
        ...TemplateCategory.values.map((category) {
          return FilterChip(
            label: Text(_formatCategoryName(category)),
            selected: selectedCategory == category,
            onSelected: (selected) {
              ref.read(templateFiltersProvider.notifier).updateCategory(
                    selected ? category : null,
                  );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDurationFilter(int? minDays, int? maxDays) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Min days',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final min = int.tryParse(value);
              ref
                  .read(templateFiltersProvider.notifier)
                  .updateDurationRange(min, maxDays);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Max days',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final max = int.tryParse(value);
              ref
                  .read(templateFiltersProvider.notifier)
                  .updateDurationRange(minDays, max);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetFilter(double? minBudget, double? maxBudget) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Min budget',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final min = double.tryParse(value);
              ref
                  .read(templateFiltersProvider.notifier)
                  .updateBudgetRange(min, maxBudget);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Max budget',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final max = double.tryParse(value);
              ref
                  .read(templateFiltersProvider.notifier)
                  .updateBudgetRange(minBudget, max);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions(TemplateSortOption selectedOption) {
    return Wrap(
      spacing: 8,
      children: TemplateSortOption.values.map((option) {
        return FilterChip(
          label: Text(_formatSortOption(option)),
          selected: selectedOption == option,
          onSelected: (selected) {
            if (selected) {
              ref
                  .read(templateFiltersProvider.notifier)
                  .updateSortOption(option);
            }
          },
        );
      }).toList(),
    );
  }

  String _formatCategoryName(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.business:
        return 'Business';
      case TemplateCategory.leisure:
        return 'Leisure';
      case TemplateCategory.adventure:
        return 'Adventure';
      case TemplateCategory.family:
        return 'Family';
      case TemplateCategory.romantic:
        return 'Romantic';
      case TemplateCategory.cultural:
        return 'Cultural';
      case TemplateCategory.beach:
        return 'Beach';
      case TemplateCategory.city:
        return 'City';
      case TemplateCategory.nature:
        return 'Nature';
      case TemplateCategory.foodie:
        return 'Foodie';
      case TemplateCategory.budget:
        return 'Budget';
      case TemplateCategory.luxury:
        return 'Luxury';
      case TemplateCategory.solo:
        return 'Solo';
      case TemplateCategory.group:
        return 'Group';
      case TemplateCategory.custom:
        return 'Custom';
    }
  }

  String _formatSortOption(TemplateSortOption option) {
    switch (option) {
      case TemplateSortOption.popularity:
        return 'Popularity';
      case TemplateSortOption.rating:
        return 'Rating';
      case TemplateSortOption.duration:
        return 'Duration';
      case TemplateSortOption.budget:
        return 'Budget';
      case TemplateSortOption.newest:
        return 'Newest';
      case TemplateSortOption.alphabetical:
        return 'A-Z';
    }
  }
}

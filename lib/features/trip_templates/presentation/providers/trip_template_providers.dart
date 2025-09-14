import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/trip_templates/domain/models/trip_template.dart';
import 'package:travel_planner/features/trip_templates/domain/services/trip_template_service.dart';

// Service provider
final tripTemplateServiceProvider = Provider<TripTemplateService>((ref) {
  return TripTemplateService();
});

// All templates provider
final allTemplatesProvider = FutureProvider<List<TripTemplate>>((ref) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getAllTemplates();
});

// Featured templates provider
final featuredTemplatesProvider =
    FutureProvider<List<TripTemplate>>((ref) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getFeaturedTemplates();
});

// Official templates provider
final officialTemplatesProvider =
    FutureProvider<List<TripTemplate>>((ref) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getOfficialTemplates();
});

// Popular templates provider
final popularTemplatesProvider =
    FutureProvider<List<TripTemplate>>((ref) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getPopularTemplates();
});

// My templates provider
final myTemplatesProvider =
    FutureProvider.family<List<TripTemplate>, String>((ref, userId) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getMyTemplates(userId);
});

// Template by ID provider
final templateByIdProvider =
    FutureProvider.family<TripTemplate?, String>((ref, templateId) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getTemplateById(templateId);
});

// Templates by category provider
final templatesByCategoryProvider =
    FutureProvider.family<List<TripTemplate>, TemplateCategory>(
        (ref, category) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getTemplatesByCategory(category);
});

// Search templates provider
final searchTemplatesProvider =
    FutureProvider.family<List<TripTemplate>, String>((ref, query) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.searchTemplates(query);
});

// Templates by duration provider
final templatesByDurationProvider =
    FutureProvider.family<List<TripTemplate>, Map<String, int>>(
        (ref, params) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getTemplatesByDuration(params['min']!, params['max']!);
});

// Templates by budget provider
final templatesByBudgetProvider =
    FutureProvider.family<List<TripTemplate>, Map<String, double>>(
        (ref, params) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getTemplatesByBudget(params['min']!, params['max']!);
});

// Template statistics provider
final templateStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(tripTemplateServiceProvider);
  return await service.getTemplateStatistics();
});

// Recommendations provider
final templateRecommendationsProvider =
    FutureProvider.family<List<TripTemplate>, Map<String, dynamic>>(
        (ref, preferences) async {
  final service = ref.read(tripTemplateServiceProvider);

  return await service.getRecommendations(
    preferredCategories: preferences['categories'] as List<TemplateCategory>?,
    preferredDuration: preferences['duration'] as int?,
    budgetRange: preferences['budget'] as double?,
    interests: preferences['interests'] as List<String>?,
  );
});

// State notifier for template management operations
class TemplateOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  TemplateOperationsNotifier(this._service)
      : super(const AsyncValue.data(null));

  final TripTemplateService _service;

  Future<void> saveTemplate(TripTemplate template) async {
    state = const AsyncValue.loading();
    try {
      await _service.saveTemplate(template);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateTemplate(TripTemplate template) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateTemplate(template);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTemplate(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteTemplate(id);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<TripTemplate> useTemplate(String templateId) async {
    state = const AsyncValue.loading();
    try {
      final template = await _service.useTemplate(templateId);
      state = const AsyncValue.data(null);
      return template;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> rateTemplate(String templateId, double rating) async {
    state = const AsyncValue.loading();
    try {
      await _service.rateTemplate(templateId, rating);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<TripTemplate> createTemplateFromTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      final template = await _service.createTemplateFromTrip(tripId);
      state = const AsyncValue.data(null);
      return template;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<TripTemplate> duplicateTemplate(String templateId) async {
    state = const AsyncValue.loading();
    try {
      final template = await _service.duplicateTemplate(templateId);
      state = const AsyncValue.data(null);
      return template;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final templateOperationsProvider =
    StateNotifierProvider<TemplateOperationsNotifier, AsyncValue<void>>((ref) {
  final service = ref.read(tripTemplateServiceProvider);
  return TemplateOperationsNotifier(service);
});

// Filter state notifier for template browsing
class TemplateFiltersNotifier extends StateNotifier<TemplateFilters> {
  TemplateFiltersNotifier() : super(const TemplateFilters());

  void updateCategory(TemplateCategory? category) {
    state = state.copyWith(category: category);
  }

  void updateDurationRange(int? minDays, int? maxDays) {
    state = state.copyWith(minDurationDays: minDays, maxDurationDays: maxDays);
  }

  void updateBudgetRange(double? minBudget, double? maxBudget) {
    state = state.copyWith(minBudget: minBudget, maxBudget: maxBudget);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateSortOption(TemplateSortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void clearFilters() {
    state = const TemplateFilters();
  }
}

final templateFiltersProvider =
    StateNotifierProvider<TemplateFiltersNotifier, TemplateFilters>((ref) {
  return TemplateFiltersNotifier();
});

// Filtered templates provider based on current filters
final filteredTemplatesProvider =
    FutureProvider<List<TripTemplate>>((ref) async {
  final filters = ref.watch(templateFiltersProvider);
  final service = ref.read(tripTemplateServiceProvider);

  List<TripTemplate> templates;

  // Apply primary filter
  if (filters.searchQuery.isNotEmpty) {
    templates = await service.searchTemplates(filters.searchQuery);
  } else if (filters.category != null) {
    templates = await service.getTemplatesByCategory(filters.category!);
  } else {
    templates = await service.getAllTemplates();
  }

  // Apply secondary filters
  if (filters.minDurationDays != null || filters.maxDurationDays != null) {
    templates = templates.where((template) {
      final minDays = filters.minDurationDays ?? 1;
      final maxDays = filters.maxDurationDays ?? 365;
      return template.durationDays >= minDays &&
          template.durationDays <= maxDays;
    }).toList();
  }

  if (filters.minBudget != null || filters.maxBudget != null) {
    templates = templates.where((template) {
      final minBudget = filters.minBudget ?? 0;
      final maxBudget = filters.maxBudget ?? double.infinity;
      return template.estimatedBudgetMin <= maxBudget &&
          template.estimatedBudgetMax >= minBudget;
    }).toList();
  }

  // Apply sorting
  switch (filters.sortOption) {
    case TemplateSortOption.popularity:
      templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));
      break;
    case TemplateSortOption.rating:
      templates.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case TemplateSortOption.duration:
      templates.sort((a, b) => a.durationDays.compareTo(b.durationDays));
      break;
    case TemplateSortOption.budget:
      templates
          .sort((a, b) => a.estimatedBudgetMin.compareTo(b.estimatedBudgetMin));
      break;
    case TemplateSortOption.newest:
      templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case TemplateSortOption.alphabetical:
      templates.sort((a, b) => a.name.compareTo(b.name));
      break;
  }

  return templates;
});

// Supporting classes
class TemplateFilters {
  final TemplateCategory? category;
  final int? minDurationDays;
  final int? maxDurationDays;
  final double? minBudget;
  final double? maxBudget;
  final String searchQuery;
  final TemplateSortOption sortOption;

  const TemplateFilters({
    this.category,
    this.minDurationDays,
    this.maxDurationDays,
    this.minBudget,
    this.maxBudget,
    this.searchQuery = '',
    this.sortOption = TemplateSortOption.popularity,
  });

  TemplateFilters copyWith({
    TemplateCategory? category,
    int? minDurationDays,
    int? maxDurationDays,
    double? minBudget,
    double? maxBudget,
    String? searchQuery,
    TemplateSortOption? sortOption,
  }) {
    return TemplateFilters(
      category: category ?? this.category,
      minDurationDays: minDurationDays ?? this.minDurationDays,
      maxDurationDays: maxDurationDays ?? this.maxDurationDays,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

enum TemplateSortOption {
  popularity,
  rating,
  duration,
  budget,
  newest,
  alphabetical,
}

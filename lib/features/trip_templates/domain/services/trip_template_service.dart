import 'package:travel_planner/features/trip_templates/domain/models/trip_template.dart';
import 'package:travel_planner/features/trip_templates/domain/repositories/trip_template_repository.dart';
import 'package:travel_planner/features/trip_templates/data/repositories/hive_trip_template_repository.dart';

class TripTemplateService {
  late final TripTemplateRepository _repository;

  TripTemplateService() {
    _repository = HiveTripTemplateRepository();
  }

  // Constructor for testing with mock repository
  TripTemplateService.withRepository(TripTemplateRepository repository)
      : _repository = repository;

  Future<List<TripTemplate>> getAllTemplates() async {
    return await _repository.getAllTemplates();
  }

  Future<TripTemplate?> getTemplateById(String id) async {
    try {
      return await _repository.getTemplateById(id);
    } catch (e) {
      return null;
    }
  }

  Future<List<TripTemplate>> getTemplatesByCategory(
      TemplateCategory category) async {
    return await _repository.getTemplatesByCategory(category);
  }

  Future<List<TripTemplate>> searchTemplates(String query) async {
    if (query.trim().isEmpty) {
      return await getAllTemplates();
    }
    return await _repository.searchTemplates(query);
  }

  Future<List<TripTemplate>> getPopularTemplates() async {
    return await _repository.getPopularTemplates();
  }

  Future<List<TripTemplate>> getMyTemplates(String userId) async {
    return await _repository.getMyTemplates(userId);
  }

  Future<List<TripTemplate>> getOfficialTemplates() async {
    return await _repository.getOfficialTemplates();
  }

  Future<List<TripTemplate>> getFeaturedTemplates() async {
    final official = await getOfficialTemplates();
    final popular = await getPopularTemplates();

    // Combine and deduplicate
    final featured = <String, TripTemplate>{};

    for (final template in official) {
      featured[template.id] = template;
    }

    for (final template in popular.take(5)) {
      featured[template.id] = template;
    }

    final result = featured.values.toList();
    result.sort((a, b) {
      // Sort by: official first, then by usage count
      if (a.isOfficial && !b.isOfficial) return -1;
      if (!a.isOfficial && b.isOfficial) return 1;
      return b.usageCount.compareTo(a.usageCount);
    });

    return result;
  }

  Future<List<TripTemplate>> getTemplatesByDuration(
      int minDays, int maxDays) async {
    final allTemplates = await getAllTemplates();
    return allTemplates
        .where((template) =>
            template.durationDays >= minDays &&
            template.durationDays <= maxDays)
        .toList();
  }

  Future<List<TripTemplate>> getTemplatesByBudget(
      double minBudget, double maxBudget) async {
    final allTemplates = await getAllTemplates();
    return allTemplates
        .where((template) =>
            template.estimatedBudgetMin <= maxBudget &&
            template.estimatedBudgetMax >= minBudget)
        .toList();
  }

  Future<void> saveTemplate(TripTemplate template) async {
    await _repository.saveTemplate(template);
  }

  Future<void> updateTemplate(TripTemplate template) async {
    await _repository.updateTemplate(template);
  }

  Future<void> deleteTemplate(String id) async {
    await _repository.deleteTemplate(id);
  }

  Future<TripTemplate> useTemplate(String templateId) async {
    // Increment usage count when template is used
    await _repository.incrementUsageCount(templateId);

    final template = await getTemplateById(templateId);
    if (template == null) {
      throw Exception('Template not found');
    }

    return template;
  }

  Future<void> rateTemplate(String templateId, double rating) async {
    if (rating < 0 || rating > 5) {
      throw ArgumentError('Rating must be between 0 and 5');
    }

    await _repository.rateTemplate(templateId, rating);
  }

  Future<TripTemplate> createTemplateFromTrip(String tripId) async {
    return await _repository.createTemplateFromTrip(tripId);
  }

  Future<TripTemplate> duplicateTemplate(String templateId) async {
    final original = await getTemplateById(templateId);
    if (original == null) {
      throw Exception('Template not found');
    }

    final duplicate = TripTemplate.create(
      name: '${original.name} (Copy)',
      description: original.description,
      category: original.category,
      durationDays: original.durationDays,
      estimatedBudgetMin: original.estimatedBudgetMin,
      estimatedBudgetMax: original.estimatedBudgetMax,
      currency: original.currency,
      suitableDestinations: List.from(original.suitableDestinations),
      tags: List.from(original.tags),
      dayStructures: original.dayStructures
          .map((day) => TemplateDayStructure(
                dayNumber: day.dayNumber,
                title: day.title,
                description: day.description,
                activities: day.activities
                    .map((activity) => TemplateActivityItem(
                          title: activity.title,
                          description: activity.description,
                          startTime: activity.startTime,
                          endTime: activity.endTime,
                          category: activity.category,
                          priority: activity.priority,
                          estimatedCost: activity.estimatedCost,
                          location: activity.location,
                          notes: activity.notes,
                        ))
                    .toList(),
                estimatedBudget: day.estimatedBudget,
              ))
          .toList(),
      suggestedCompanions: original.suggestedCompanions
          .map((companion) => TemplateCompanion(
                name: companion.name,
                role: companion.role,
                preferences: companion.preferences,
                isOptional: companion.isOptional,
              ))
          .toList(),
      packingItems: original.packingItems
          .map((item) => TemplatePackingItem(
                name: item.name,
                category: item.category,
                quantity: item.quantity,
                isEssential: item.isEssential,
                notes: item.notes,
                conditions: List.from(item.conditions),
              ))
          .toList(),
      imageUrl: original.imageUrl,
      creatorId: 'current_user', // TODO: Get from auth service
      creatorName: 'Me', // TODO: Get from user profile
      isPublic: false, // Duplicates start as private
      metadata: Map.from(original.metadata),
    );

    await saveTemplate(duplicate);
    return duplicate;
  }

  Future<List<TripTemplate>> getRecommendations({
    List<TemplateCategory>? preferredCategories,
    int? preferredDuration,
    double? budgetRange,
    List<String>? interests,
  }) async {
    final allTemplates = await getAllTemplates();

    // Score templates based on preferences
    final scoredTemplates = allTemplates.map((template) {
      double score = 0.0;

      // Category preference
      if (preferredCategories?.contains(template.category) == true) {
        score += 3.0;
      }

      // Duration preference (within 2 days)
      if (preferredDuration != null) {
        final durationDiff = (template.durationDays - preferredDuration).abs();
        if (durationDiff <= 2) {
          score += 2.0 - (durationDiff * 0.5);
        }
      }

      // Budget preference (within range)
      if (budgetRange != null) {
        if (template.estimatedBudgetMin <= budgetRange &&
            template.estimatedBudgetMax >= budgetRange * 0.8) {
          score += 2.0;
        }
      }

      // Interest matching
      if (interests != null) {
        final matchingInterests = interests
            .where((interest) => template.tags.any(
                (tag) => tag.toLowerCase().contains(interest.toLowerCase())))
            .length;
        score += matchingInterests * 1.0;
      }

      // Boost popular and official templates
      if (template.isOfficial) score += 1.0;
      if (template.usageCount > 10) score += 0.5;
      if (template.hasRatings && template.rating >= 4.0) score += 1.0;

      return MapEntry(template, score);
    }).where((entry) => entry.value > 0);

    // Sort by score and return top recommendations
    final recommendations = scoredTemplates.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return recommendations.take(10).map((entry) => entry.key).toList();
  }

  Future<void> populateInitialData() async {
    final repo = _repository as HiveTripTemplateRepository;
    await repo.populateOfficialTemplates();
  }

  Future<Map<String, dynamic>> getTemplateStatistics() async {
    final templates = await getAllTemplates();

    final categoryCount = <TemplateCategory, int>{};
    double totalRating = 0;
    int ratedTemplates = 0;
    int totalUsage = 0;

    for (final template in templates) {
      categoryCount[template.category] =
          (categoryCount[template.category] ?? 0) + 1;

      if (template.hasRatings) {
        totalRating += template.rating;
        ratedTemplates++;
      }

      totalUsage += template.usageCount;
    }

    return {
      'totalTemplates': templates.length,
      'categoryBreakdown':
          categoryCount.map((key, value) => MapEntry(key.name, value)),
      'averageRating': ratedTemplates > 0 ? totalRating / ratedTemplates : 0.0,
      'totalUsage': totalUsage,
      'officialTemplates': templates.where((t) => t.isOfficial).length,
      'publicTemplates': templates.where((t) => t.isPublic).length,
    };
  }
}

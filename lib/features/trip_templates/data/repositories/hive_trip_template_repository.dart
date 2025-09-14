import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/features/trip_templates/domain/models/trip_template.dart';
import 'package:travel_planner/features/trip_templates/domain/repositories/trip_template_repository.dart';

class HiveTripTemplateRepository implements TripTemplateRepository {
  static const String _boxName = 'trip_templates';
  static const String _ratingsBoxName = 'template_ratings';

  Box<TripTemplate>? _templatesBox;
  Box<Map>? _ratingsBox; // Store user ratings for templates

  Future<Box<TripTemplate>> get _templateBox async {
    if (_templatesBox?.isOpen != true) {
      _templatesBox = await Hive.openBox<TripTemplate>(_boxName);
    }
    return _templatesBox!;
  }

  Future<Box<Map>> get _ratingBox async {
    if (_ratingsBox?.isOpen != true) {
      _ratingsBox = await Hive.openBox<Map>(_ratingsBoxName);
    }
    return _ratingsBox!;
  }

  @override
  Future<List<TripTemplate>> getAllTemplates() async {
    final box = await _templateBox;
    return box.values.toList();
  }

  @override
  Future<TripTemplate?> getTemplateById(String id) async {
    final box = await _templateBox;
    return box.values.firstWhere(
      (template) => template.id == id,
      orElse: () => throw StateError('Template not found'),
    );
  }

  @override
  Future<List<TripTemplate>> getTemplatesByCategory(
      TemplateCategory category) async {
    final box = await _templateBox;
    return box.values
        .where((template) => template.category == category)
        .toList();
  }

  @override
  Future<List<TripTemplate>> searchTemplates(String query) async {
    final box = await _templateBox;
    return box.values
        .where((template) => template.matchesSearch(query))
        .toList();
  }

  @override
  Future<List<TripTemplate>> getPopularTemplates() async {
    final box = await _templateBox;
    final templates = box.values.toList();
    templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return templates.take(10).toList(); // Top 10 most used templates
  }

  @override
  Future<List<TripTemplate>> getMyTemplates(String userId) async {
    final box = await _templateBox;
    return box.values
        .where((template) => template.creatorId == userId)
        .toList();
  }

  @override
  Future<List<TripTemplate>> getOfficialTemplates() async {
    final box = await _templateBox;
    return box.values.where((template) => template.isOfficial).toList();
  }

  @override
  Future<void> saveTemplate(TripTemplate template) async {
    final box = await _templateBox;
    await box.put(template.id, template);
  }

  @override
  Future<void> updateTemplate(TripTemplate template) async {
    final box = await _templateBox;
    final updatedTemplate = template.copyWith(lastModified: DateTime.now());
    await box.put(template.id, updatedTemplate);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final box = await _templateBox;
    final template = box.values.firstWhere(
      (template) => template.id == id,
      orElse: () => throw StateError('Template not found'),
    );
    await template.delete(); // Delete from Hive
  }

  @override
  Future<void> incrementUsageCount(String id) async {
    final box = await _templateBox;
    final template = box.values.firstWhere(
      (template) => template.id == id,
      orElse: () => throw StateError('Template not found'),
    );

    final updatedTemplate = template.copyWith(
      usageCount: template.usageCount + 1,
      lastModified: DateTime.now(),
    );

    await box.put(id, updatedTemplate);
  }

  @override
  Future<void> rateTemplate(String id, double rating) async {
    final box = await _templateBox;
    final ratingsBox = await _ratingBox;

    final template = box.values.firstWhere(
      (template) => template.id == id,
      orElse: () => throw StateError('Template not found'),
    );

    // Store individual rating
    final existingRatings = ratingsBox
        .get(id, defaultValue: <String, dynamic>{}) as Map<String, dynamic>;
    final userId = 'current_user'; // TODO: Get from auth service
    final wasNewRating = !existingRatings.containsKey(userId);
    existingRatings[userId] = rating;
    await ratingsBox.put(id, existingRatings);

    // Update template average rating
    final ratings = existingRatings.values.cast<double>().toList();
    final newAverage = ratings.reduce((a, b) => a + b) / ratings.length;
    final newRatingCount =
        wasNewRating ? template.ratingCount + 1 : template.ratingCount;

    final updatedTemplate = template.copyWith(
      rating: newAverage,
      ratingCount: newRatingCount,
      lastModified: DateTime.now(),
    );

    await box.put(id, updatedTemplate);
  }

  @override
  Future<TripTemplate> createTemplateFromTrip(String tripId) async {
    // Get trip from Hive
    final tripsBox = Hive.box<Trip>('trips');
    final trip = tripsBox.values.firstWhere(
      (trip) => trip.id == tripId,
      orElse: () => throw StateError('Trip not found'),
    );

    // Convert trip days to template day structures
    final dayStructures = <TemplateDayStructure>[];
    for (int i = 0; i < trip.days.length; i++) {
      final day = trip.days[i];
      final activities = day.activities.map((activity) {
        final startTime = TimeOfDay.fromDateTime(activity.startTime);
        final endTime = TimeOfDay.fromDateTime(activity.endTime);

        return TemplateActivityItem(
          title: activity.title,
          description: activity.notes, // Use notes as description
          startTime:
              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
          endTime:
              '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
          category:
              'activity', // Default category since Activity doesn't have this field
          priority:
              'medium', // Default priority since Activity doesn't have this field
          estimatedCost:
              0.0, // Default cost since Activity doesn't have this field
          location: activity.locationName,
          notes: activity.notes,
        );
      }).toList();

      final dayStructure = TemplateDayStructure(
        dayNumber: i + 1,
        title: 'Day ${i + 1}',
        description: null,
        activities: activities,
        estimatedBudget: activities.fold(
            0.0, (sum, activity) => sum + activity.estimatedCost),
      );

      dayStructures.add(dayStructure);
    }

    // Convert packing list to template packing items
    final packingItems = trip.packingList.map((item) {
      return TemplatePackingItem(
        name: item.name,
        category: item.category.toString(),
        quantity: item.quantity,
        isEssential: item.isPacked, // Use packed status as essential indicator
        notes: null,
        conditions: [], // Empty for now, could be enhanced
      );
    }).toList();

    // Create template
    final template = TripTemplate.create(
      name: '${trip.title} Template',
      description: 'Template created from trip: ${trip.title}',
      category: TemplateCategory
          .custom, // Default to custom for user-created templates
      durationDays: trip.days.length,
      estimatedBudgetMin:
          dayStructures.fold(0.0, (sum, day) => sum + day.estimatedBudget) *
              0.8, // 20% lower
      estimatedBudgetMax:
          dayStructures.fold(0.0, (sum, day) => sum + day.estimatedBudget) *
              1.2, // 20% higher
      currency:
          'USD', // Default currency, could be enhanced to detect from expenses
      suitableDestinations: [trip.locationName],
      tags: [trip.locationName, TemplateCategory.custom.name],
      dayStructures: dayStructures,
      packingItems: packingItems,
      creatorId: 'current_user', // TODO: Get from auth service
      creatorName: 'Me', // TODO: Get from user profile
    );

    await saveTemplate(template);
    return template;
  }

  @override
  Future<void> clearCache() async {
    final box = await _templateBox;
    final ratingsBox = await _ratingBox;
    await box.clear();
    await ratingsBox.clear();
  }

  // Utility method to populate initial official templates
  Future<void> populateOfficialTemplates() async {
    final templates = await getAllTemplates();
    if (templates.where((template) => template.isOfficial).isNotEmpty) {
      return; // Already populated
    }

    // Create some sample official templates
    final officialTemplates = [
      TripTemplate.create(
        name: 'Weekend City Break',
        description:
            'Perfect 2-day city exploration with culture, dining, and relaxation',
        category: TemplateCategory.city,
        durationDays: 2,
        estimatedBudgetMin: 200,
        estimatedBudgetMax: 500,
        currency: 'USD',
        suitableDestinations: [
          'Any major city',
          'European capitals',
          'US cities'
        ],
        tags: ['weekend', 'city', 'culture', 'dining', 'short trip'],
        dayStructures: [
          TemplateDayStructure(
            dayNumber: 1,
            title: 'Arrival & Exploration',
            description: 'Check-in, city center tour, local dining',
            activities: [
              TemplateActivityItem(
                title: 'Hotel Check-in',
                startTime: '14:00',
                endTime: '15:00',
                category: 'accommodation',
                priority: 'medium',
                estimatedCost: 0,
              ),
              TemplateActivityItem(
                title: 'City Walking Tour',
                startTime: '15:30',
                endTime: '18:00',
                category: 'sightseeing',
                priority: 'high',
                estimatedCost: 25,
                notes: 'Visit main attractions and landmarks',
              ),
              TemplateActivityItem(
                title: 'Local Restaurant Dinner',
                startTime: '19:00',
                endTime: '21:00',
                category: 'dinner',
                priority: 'medium',
                estimatedCost: 60,
              ),
            ],
            estimatedBudget: 85,
          ),
          TemplateDayStructure(
            dayNumber: 2,
            title: 'Museums & Departure',
            description: 'Cultural sites, shopping, and departure',
            activities: [
              TemplateActivityItem(
                title: 'Museum Visit',
                startTime: '10:00',
                endTime: '12:30',
                category: 'cultural',
                priority: 'high',
                estimatedCost: 20,
              ),
              TemplateActivityItem(
                title: 'Shopping & Souvenirs',
                startTime: '13:00',
                endTime: '15:00',
                category: 'shopping',
                priority: 'low',
                estimatedCost: 50,
              ),
              TemplateActivityItem(
                title: 'Airport/Station Transfer',
                startTime: '16:00',
                endTime: '17:00',
                category: 'transportation',
                priority: 'critical',
                estimatedCost: 25,
              ),
            ],
            estimatedBudget: 95,
          ),
        ],
        suggestedCompanions: [
          TemplateCompanion(
            name: 'Travel Partner',
            role: 'spouse',
            isOptional: true,
          ),
        ],
        packingItems: [
          TemplatePackingItem(
            name: 'Comfortable Walking Shoes',
            category: 'clothing',
            quantity: 1,
            isEssential: true,
            conditions: ['city exploration'],
          ),
          TemplatePackingItem(
            name: 'Camera',
            category: 'electronics',
            quantity: 1,
            isEssential: false,
            conditions: ['sightseeing'],
          ),
        ],
        creatorId: 'system',
        creatorName: 'Travel Planner',
        isPublic: true,
        isOfficial: true,
      ),
      TripTemplate.create(
        name: 'Family Beach Vacation',
        description:
            '7-day family-friendly beach resort experience with activities for all ages',
        category: TemplateCategory.family,
        durationDays: 7,
        estimatedBudgetMin: 1500,
        estimatedBudgetMax: 3000,
        currency: 'USD',
        suitableDestinations: [
          'Beach resorts',
          'Coastal destinations',
          'Family resorts'
        ],
        tags: ['family', 'beach', 'resort', 'kids', 'relaxation', 'week-long'],
        dayStructures: [
          TemplateDayStructure(
            dayNumber: 1,
            title: 'Arrival & Resort Orientation',
            description: 'Check-in, resort familiarization, beach time',
            activities: [
              TemplateActivityItem(
                title: 'Resort Check-in',
                startTime: '15:00',
                endTime: '16:00',
                category: 'accommodation',
                priority: 'critical',
                estimatedCost: 0,
              ),
              TemplateActivityItem(
                title: 'Resort Tour & Facilities',
                startTime: '16:30',
                endTime: '17:30',
                category: 'entertainment',
                priority: 'medium',
                estimatedCost: 0,
                notes: 'Learn about pools, restaurants, kids club',
              ),
              TemplateActivityItem(
                title: 'Beach Sunset',
                startTime: '18:00',
                endTime: '19:30',
                category: 'relaxation',
                priority: 'medium',
                estimatedCost: 0,
              ),
            ],
            estimatedBudget: 50,
          ),
          // Additional days would be added here...
        ],
        suggestedCompanions: [
          TemplateCompanion(
            name: 'Spouse/Partner',
            role: 'spouse',
            isOptional: false,
          ),
          TemplateCompanion(
            name: 'Child 1',
            role: 'child',
            preferences: 'Age-appropriate activities',
            isOptional: false,
          ),
          TemplateCompanion(
            name: 'Child 2',
            role: 'child',
            preferences: 'Age-appropriate activities',
            isOptional: true,
          ),
        ],
        packingItems: [
          TemplatePackingItem(
            name: 'Swimwear',
            category: 'clothing',
            quantity: 3,
            isEssential: true,
            conditions: ['beach', 'pool'],
          ),
          TemplatePackingItem(
            name: 'Sunscreen SPF 50+',
            category: 'personal_care',
            quantity: 2,
            isEssential: true,
            conditions: ['beach', 'sun exposure'],
          ),
          TemplatePackingItem(
            name: 'Kids Beach Toys',
            category: 'other',
            quantity: 1,
            isEssential: false,
            conditions: ['family', 'beach'],
            notes: 'Buckets, shovels, inflatables',
          ),
        ],
        creatorId: 'system',
        creatorName: 'Travel Planner',
        isPublic: true,
        isOfficial: true,
      ),
    ];

    for (final template in officialTemplates) {
      await saveTemplate(template);
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/trip_templates/domain/models/trip_template.dart';

void main() {
  group('Trip Templates', () {
    test('should create a trip template with all required fields', () {
      final template = TripTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'A test template',
        category: TemplateCategory.adventure,
        durationDays: 5,
        estimatedBudgetMin: 500.0,
        estimatedBudgetMax: 1000.0,
        currency: 'USD',
        suitableDestinations: ['Paris', 'London'],
        dayStructures: [],
        suggestedCompanions: [],
        packingItems: [],
        tags: ['test', 'template'],
        isOfficial: false,
        isPublic: true,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        creatorId: 'test-user',
        creatorName: 'Test User',
        rating: 0.0,
        ratingCount: 0,
        usageCount: 0,
        metadata: {},
      );

      expect(template.name, equals('Test Template'));
      expect(template.category, equals(TemplateCategory.adventure));
      expect(template.durationDays, equals(5));
      expect(template.suitableDestinations.length, equals(2));
    });

    test('should create template activity item correctly', () {
      final activity = TemplateActivityItem(
        title: 'Visit Eiffel Tower',
        description: 'Iconic landmark visit',
        startTime: '09:00',
        endTime: '11:00',
        category: 'sightseeing',
        priority: 'high',
        estimatedCost: 25.0,
        location: 'Paris, France',
        notes: 'Book tickets in advance',
      );

      expect(activity.title, equals('Visit Eiffel Tower'));
      expect(activity.startTime, equals('09:00'));
      expect(activity.estimatedCost, equals(25.0));
    });

    test('should create day structure with activities', () {
      final activities = [
        TemplateActivityItem(
          title: 'Morning Walk',
          startTime: '08:00',
          endTime: '09:00',
          category: 'recreation',
          priority: 'medium',
          estimatedCost: 0.0,
        ),
        TemplateActivityItem(
          title: 'Museum Visit',
          startTime: '10:00',
          endTime: '12:00',
          category: 'culture',
          priority: 'high',
          estimatedCost: 15.0,
        ),
      ];

      final dayStructure = TemplateDayStructure(
        dayNumber: 1,
        title: 'Arrival Day',
        description: 'First day activities',
        activities: activities,
        estimatedBudget: 15.0,
      );

      expect(dayStructure.dayNumber, equals(1));
      expect(dayStructure.activities.length, equals(2));
      expect(dayStructure.estimatedBudget, equals(15.0));
    });

    test('should create template companion correctly', () {
      final companion = TemplateCompanion(
        name: 'Travel Buddy',
        role: 'friend',
        preferences: 'Loves hiking and photography',
        isOptional: false,
      );

      expect(companion.name, equals('Travel Buddy'));
      expect(companion.role, equals('friend'));
      expect(companion.isOptional, equals(false));
    });

    test('should create template packing item correctly', () {
      final packingItem = TemplatePackingItem(
        name: 'Hiking Boots',
        category: 'clothing',
        quantity: 1,
        isEssential: true,
        notes: 'Waterproof recommended',
        conditions: ['hiking', 'wet weather'],
      );

      expect(packingItem.name, equals('Hiking Boots'));
      expect(packingItem.isEssential, equals(true));
      expect(packingItem.conditions.length, equals(2));
    });

    test('should serialize and deserialize template correctly', () {
      final originalTemplate = TripTemplate(
        id: 'test-id',
        name: 'Serialization Test',
        description: 'Testing JSON conversion',
        category: TemplateCategory.beach,
        durationDays: 3,
        estimatedBudgetMin: 200.0,
        estimatedBudgetMax: 400.0,
        currency: 'USD',
        suitableDestinations: ['Beach Resort'],
        dayStructures: [],
        suggestedCompanions: [],
        packingItems: [],
        tags: ['beach', 'relaxation'],
        isOfficial: false,
        isPublic: true,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        creatorId: 'test-user',
        creatorName: 'Test User',
        rating: 4.5,
        ratingCount: 10,
        usageCount: 25,
        metadata: {},
      );

      final json = originalTemplate.toJson();
      final recreatedTemplate = TripTemplate.fromJson(json);

      expect(recreatedTemplate.name, equals(originalTemplate.name));
      expect(recreatedTemplate.category, equals(originalTemplate.category));
      expect(recreatedTemplate.durationDays,
          equals(originalTemplate.durationDays));
      expect(recreatedTemplate.rating, equals(originalTemplate.rating));
    });
  });
}

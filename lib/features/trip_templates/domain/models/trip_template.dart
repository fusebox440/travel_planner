import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'trip_template.g.dart';

@HiveType(typeId: 42) // Template category enum
enum TemplateCategory {
  @HiveField(0)
  business,
  @HiveField(1)
  leisure,
  @HiveField(2)
  adventure,
  @HiveField(3)
  family,
  @HiveField(4)
  romantic,
  @HiveField(5)
  cultural,
  @HiveField(6)
  beach,
  @HiveField(7)
  city,
  @HiveField(8)
  nature,
  @HiveField(9)
  foodie,
  @HiveField(10)
  budget,
  @HiveField(11)
  luxury,
  @HiveField(12)
  solo,
  @HiveField(13)
  group,
  @HiveField(14)
  custom,
}

@HiveType(typeId: 43) // Template day structure
class TemplateDayStructure extends HiveObject {
  @HiveField(0)
  final int dayNumber;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final List<TemplateActivityItem> activities;

  @HiveField(4)
  final double estimatedBudget;

  TemplateDayStructure({
    required this.dayNumber,
    required this.title,
    this.description,
    required this.activities,
    required this.estimatedBudget,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'description': description,
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'estimatedBudget': estimatedBudget,
    };
  }

  factory TemplateDayStructure.fromJson(Map<String, dynamic> json) {
    return TemplateDayStructure(
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      activities: (json['activities'] as List)
          .map((activity) =>
              TemplateActivityItem.fromJson(activity as Map<String, dynamic>))
          .toList(),
      estimatedBudget: (json['estimatedBudget'] as num).toDouble(),
    );
  }
}

@HiveType(typeId: 44) // Template activity item
class TemplateActivityItem extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final String startTime; // Format: "HH:mm"

  @HiveField(3)
  final String endTime; // Format: "HH:mm"

  @HiveField(4)
  final String category; // Maps to ActivitySubtype

  @HiveField(5)
  final String priority; // Maps to ActivityPriority

  @HiveField(6)
  final double estimatedCost;

  @HiveField(7)
  final String? location;

  @HiveField(8)
  final String? notes;

  TemplateActivityItem({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.priority,
    required this.estimatedCost,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      'priority': priority,
      'estimatedCost': estimatedCost,
      'location': location,
      'notes': notes,
    };
  }

  factory TemplateActivityItem.fromJson(Map<String, dynamic> json) {
    return TemplateActivityItem(
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

@HiveType(typeId: 45) // Template companion profile
class TemplateCompanion extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String role; // e.g., "spouse", "friend", "colleague", "child"

  @HiveField(2)
  final String? preferences; // Travel preferences, dietary restrictions, etc.

  @HiveField(3)
  final bool isOptional; // Whether this companion is required for the template

  TemplateCompanion({
    required this.name,
    required this.role,
    this.preferences,
    required this.isOptional,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'preferences': preferences,
      'isOptional': isOptional,
    };
  }

  factory TemplateCompanion.fromJson(Map<String, dynamic> json) {
    return TemplateCompanion(
      name: json['name'] as String,
      role: json['role'] as String,
      preferences: json['preferences'] as String?,
      isOptional: json['isOptional'] as bool,
    );
  }
}

@HiveType(typeId: 46) // Template packing item
class TemplatePackingItem extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String category; // Maps to ItemCategory

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final bool isEssential;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final List<String> conditions; // Weather/activity conditions when needed

  TemplatePackingItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.isEssential,
    this.notes,
    required this.conditions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'isEssential': isEssential,
      'notes': notes,
      'conditions': conditions,
    };
  }

  factory TemplatePackingItem.fromJson(Map<String, dynamic> json) {
    return TemplatePackingItem(
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      isEssential: json['isEssential'] as bool,
      notes: json['notes'] as String?,
      conditions: List<String>.from(json['conditions'] as List),
    );
  }
}

@HiveType(typeId: 41) // Main trip template model
class TripTemplate extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final TemplateCategory category;

  @HiveField(4)
  final int durationDays;

  @HiveField(5)
  final double estimatedBudgetMin;

  @HiveField(6)
  final double estimatedBudgetMax;

  @HiveField(7)
  final String currency;

  @HiveField(8)
  final List<String>
      suitableDestinations; // General destination types or specific places

  @HiveField(9)
  final List<String> tags; // Searchable tags

  @HiveField(10)
  final List<TemplateDayStructure> dayStructures;

  @HiveField(11)
  final List<TemplateCompanion> suggestedCompanions;

  @HiveField(12)
  final List<TemplatePackingItem> packingItems;

  @HiveField(13)
  final String? imageUrl; // Template thumbnail

  @HiveField(14)
  final String creatorId; // User who created the template

  @HiveField(15)
  final String? creatorName; // Display name of creator

  @HiveField(16)
  final DateTime createdAt;

  @HiveField(17)
  final DateTime lastModified;

  @HiveField(18)
  final int usageCount; // How many times this template has been used

  @HiveField(19)
  final double rating; // Average rating from users

  @HiveField(20)
  final int ratingCount; // Number of ratings

  @HiveField(21)
  final bool isPublic; // Whether this template can be shared

  @HiveField(22)
  final bool isOfficial; // Whether this is an official/curated template

  @HiveField(23)
  final Map<String, dynamic> metadata; // Additional flexible metadata

  TripTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.durationDays,
    required this.estimatedBudgetMin,
    required this.estimatedBudgetMax,
    required this.currency,
    required this.suitableDestinations,
    required this.tags,
    required this.dayStructures,
    required this.suggestedCompanions,
    required this.packingItems,
    this.imageUrl,
    required this.creatorId,
    this.creatorName,
    required this.createdAt,
    required this.lastModified,
    required this.usageCount,
    required this.rating,
    required this.ratingCount,
    required this.isPublic,
    required this.isOfficial,
    required this.metadata,
  });

  factory TripTemplate.create({
    required String name,
    required String description,
    required TemplateCategory category,
    required int durationDays,
    required double estimatedBudgetMin,
    required double estimatedBudgetMax,
    required String currency,
    required List<String> suitableDestinations,
    required List<String> tags,
    required List<TemplateDayStructure> dayStructures,
    List<TemplateCompanion>? suggestedCompanions,
    List<TemplatePackingItem>? packingItems,
    String? imageUrl,
    required String creatorId,
    String? creatorName,
    bool isPublic = false,
    bool isOfficial = false,
    Map<String, dynamic>? metadata,
  }) {
    return TripTemplate(
      id: const Uuid().v4(),
      name: name,
      description: description,
      category: category,
      durationDays: durationDays,
      estimatedBudgetMin: estimatedBudgetMin,
      estimatedBudgetMax: estimatedBudgetMax,
      currency: currency,
      suitableDestinations: suitableDestinations,
      tags: tags,
      dayStructures: dayStructures,
      suggestedCompanions: suggestedCompanions ?? [],
      packingItems: packingItems ?? [],
      imageUrl: imageUrl,
      creatorId: creatorId,
      creatorName: creatorName,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      usageCount: 0,
      rating: 0.0,
      ratingCount: 0,
      isPublic: isPublic,
      isOfficial: isOfficial,
      metadata: metadata ?? {},
    );
  }

  TripTemplate copyWith({
    String? name,
    String? description,
    TemplateCategory? category,
    int? durationDays,
    double? estimatedBudgetMin,
    double? estimatedBudgetMax,
    String? currency,
    List<String>? suitableDestinations,
    List<String>? tags,
    List<TemplateDayStructure>? dayStructures,
    List<TemplateCompanion>? suggestedCompanions,
    List<TemplatePackingItem>? packingItems,
    String? imageUrl,
    String? creatorName,
    DateTime? lastModified,
    int? usageCount,
    double? rating,
    int? ratingCount,
    bool? isPublic,
    bool? isOfficial,
    Map<String, dynamic>? metadata,
  }) {
    return TripTemplate(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      durationDays: durationDays ?? this.durationDays,
      estimatedBudgetMin: estimatedBudgetMin ?? this.estimatedBudgetMin,
      estimatedBudgetMax: estimatedBudgetMax ?? this.estimatedBudgetMax,
      currency: currency ?? this.currency,
      suitableDestinations: suitableDestinations ?? this.suitableDestinations,
      tags: tags ?? this.tags,
      dayStructures: dayStructures ?? this.dayStructures,
      suggestedCompanions: suggestedCompanions ?? this.suggestedCompanions,
      packingItems: packingItems ?? this.packingItems,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorId: creatorId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt,
      lastModified: lastModified ?? this.lastModified,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isPublic: isPublic ?? this.isPublic,
      isOfficial: isOfficial ?? this.isOfficial,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'durationDays': durationDays,
      'estimatedBudgetMin': estimatedBudgetMin,
      'estimatedBudgetMax': estimatedBudgetMax,
      'currency': currency,
      'suitableDestinations': suitableDestinations,
      'tags': tags,
      'dayStructures': dayStructures.map((day) => day.toJson()).toList(),
      'suggestedCompanions':
          suggestedCompanions.map((companion) => companion.toJson()).toList(),
      'packingItems': packingItems.map((item) => item.toJson()).toList(),
      'imageUrl': imageUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'usageCount': usageCount,
      'rating': rating,
      'ratingCount': ratingCount,
      'isPublic': isPublic,
      'isOfficial': isOfficial,
      'metadata': metadata,
    };
  }

  factory TripTemplate.fromJson(Map<String, dynamic> json) {
    return TripTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: TemplateCategory.values.firstWhere(
        (category) => category.name == json['category'],
        orElse: () => TemplateCategory.custom,
      ),
      durationDays: json['durationDays'] as int,
      estimatedBudgetMin: (json['estimatedBudgetMin'] as num).toDouble(),
      estimatedBudgetMax: (json['estimatedBudgetMax'] as num).toDouble(),
      currency: json['currency'] as String,
      suitableDestinations:
          List<String>.from(json['suitableDestinations'] as List),
      tags: List<String>.from(json['tags'] as List),
      dayStructures: (json['dayStructures'] as List)
          .map((day) =>
              TemplateDayStructure.fromJson(day as Map<String, dynamic>))
          .toList(),
      suggestedCompanions: (json['suggestedCompanions'] as List)
          .map((companion) =>
              TemplateCompanion.fromJson(companion as Map<String, dynamic>))
          .toList(),
      packingItems: (json['packingItems'] as List)
          .map((item) =>
              TemplatePackingItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      usageCount: json['usageCount'] as int,
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
      isPublic: json['isPublic'] as bool,
      isOfficial: json['isOfficial'] as bool,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  // Utility methods
  String get formattedBudgetRange =>
      '$currency ${estimatedBudgetMin.toStringAsFixed(0)} - ${estimatedBudgetMax.toStringAsFixed(0)}';

  String get durationText => durationDays == 1 ? '1 day' : '$durationDays days';

  bool get hasRatings => ratingCount > 0;

  String get formattedRating => rating.toStringAsFixed(1);

  double get totalEstimatedCost => dayStructures.fold(
        0.0,
        (sum, day) => sum + day.estimatedBudget,
      );

  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
        suitableDestinations
            .any((dest) => dest.toLowerCase().contains(lowerQuery));
  }
}

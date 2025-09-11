import 'package:hive/hive.dart';

part 'nlu_intent.g.dart';

@HiveType(typeId: 14)
enum IntentType {
  @HiveField(0)
  searchFlight,
  @HiveField(1)
  addActivity,
  @HiveField(2)
  weather,
  @HiveField(3)
  currencyConvert,
  @HiveField(4)
  packingSuggest,
  @HiveField(5)
  bookHotel,
  @HiveField(6)
  mapsDirections,
  @HiveField(7)
  faq,
  @HiveField(8)
  smallTalk
}

@HiveType(typeId: 15)
class NluIntent extends HiveObject {
  @HiveField(0)
  final IntentType type;

  @HiveField(1)
  final Map<String, dynamic> entities;

  @HiveField(2)
  final double confidence;

  NluIntent({
    required this.type,
    Map<String, dynamic>? entities,
    this.confidence = 1.0,
  }) : entities = entities ?? {};

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'entities': entities,
      'confidence': confidence,
    };
  }

  factory NluIntent.fromJson(Map<String, dynamic> json) {
    return NluIntent(
      type: IntentType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      entities: json['entities'] as Map<String, dynamic>,
      confidence: json['confidence'] as double,
    );
  }

  // Helper methods for common entity access patterns
  String? getStringEntity(String key) => entities[key] as String?;
  num? getNumericEntity(String key) => entities[key] as num?;
  DateTime? getDateTimeEntity(String key) {
    final value = entities[key];
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  List<String>? getStringListEntity(String key) =>
      (entities[key] as List?)?.cast<String>();

  bool hasEntity(String key) => entities.containsKey(key);

  void addEntity(String key, dynamic value) {
    entities[key] = value;
  }

  // Helper for common intent checks
  bool get isNavigation => type == IntentType.mapsDirections;
  bool get isWeather => type == IntentType.weather;
  bool get isBooking =>
      type == IntentType.searchFlight || type == IntentType.bookHotel;
  bool get requiresLocation => isNavigation || isWeather || isBooking;
  bool get requiresDate =>
      type == IntentType.addActivity ||
      type == IntentType.searchFlight ||
      type == IntentType.bookHotel ||
      type == IntentType.weather;

  // Create specific intent instances
  static NluIntent weather({
    required String location,
    DateTime? date,
    Map<String, dynamic>? additionalEntities,
  }) {
    return NluIntent(
      type: IntentType.weather,
      entities: {
        'location': location,
        if (date != null) 'date': date,
        if (additionalEntities != null) ...additionalEntities,
      },
    );
  }

  static NluIntent currencyConvert({
    required String from,
    required String to,
    required double amount,
  }) {
    return NluIntent(
      type: IntentType.currencyConvert,
      entities: {
        'from': from,
        'to': to,
        'amount': amount,
      },
    );
  }

  static NluIntent addActivity({
    required String title,
    required DateTime date,
    String? location,
    String? notes,
  }) {
    return NluIntent(
      type: IntentType.addActivity,
      entities: {
        'title': title,
        'date': date,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      },
    );
  }

  static NluIntent searchFlight({
    required String origin,
    required String destination,
    required DateTime departDate,
    DateTime? returnDate,
    int? passengers,
  }) {
    return NluIntent(
      type: IntentType.searchFlight,
      entities: {
        'origin': origin,
        'destination': destination,
        'departDate': departDate,
        if (returnDate != null) 'returnDate': returnDate,
        if (passengers != null) 'passengers': passengers,
      },
    );
  }
}

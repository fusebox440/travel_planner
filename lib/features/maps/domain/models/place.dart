import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'place.g.dart';

enum PlaceType {
  attraction,
  restaurant,
  hotel,
  custom;

  String get displayName {
    switch (this) {
      case PlaceType.attraction:
        return 'Attraction';
      case PlaceType.restaurant:
        return 'Restaurant';
      case PlaceType.hotel:
        return 'Hotel';
      case PlaceType.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case PlaceType.attraction:
        return 'place';
      case PlaceType.restaurant:
        return 'restaurant';
      case PlaceType.hotel:
        return 'hotel';
      case PlaceType.custom:
        return 'location_on';
    }
  }
}

@HiveType(typeId: 12) // Feature models range 10-19
class Place extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double lat;

  @HiveField(3)
  final double lng;

  @HiveField(4)
  final PlaceType type;

  @HiveField(5)
  bool isBookmarked;

  @HiveField(6)
  final DateTime createdAt;

  Place({
    String? id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    this.isBookmarked = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Place copyWith({
    String? name,
    double? lat,
    double? lng,
    PlaceType? type,
    bool? isBookmarked,
  }) {
    return Place(
      id: id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      type: type ?? this.type,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'type': type.name,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: json['lat'] as double,
      lng: json['lng'] as double,
      type: PlaceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PlaceType.custom,
      ),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory Place.fromGooglePlace(dynamic googlePlace) {
    return Place(
      name: googlePlace['name'] as String,
      lat: googlePlace['geometry']['location']['lat'] as double,
      lng: googlePlace['geometry']['location']['lng'] as double,
      type: _inferPlaceType(googlePlace['types'] as List<dynamic>),
    );
  }

  static PlaceType _inferPlaceType(List<dynamic> types) {
    if (types.contains('lodging')) return PlaceType.hotel;
    if (types.contains('restaurant')) return PlaceType.restaurant;
    if (types.contains('tourist_attraction') ||
        types.contains('point_of_interest')) {
      return PlaceType.attraction;
    }
    return PlaceType.custom;
  }
}

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'packing_item.dart';

part 'packing_list.g.dart';

enum TripType { business, leisure, adventure }

enum Weather { hot, mild, cold }

@HiveType(typeId: 4) // Core models range 0-9
class PackingList extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tripId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final TripType tripType;

  @HiveField(4)
  final int durationInDays;

  @HiveField(5)
  final Weather weather;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final List<String> itemIds;

  // Getter to retrieve actual PackingItem objects
  List<PackingItem> get items {
    final box = Hive.box<PackingItem>('packing_items');
    return itemIds
        .map((id) => box.get(id))
        .where((item) => item != null)
        .cast<PackingItem>()
        .toList();
  }

  PackingList({
    required this.id,
    required this.tripId,
    required this.title,
    required this.tripType,
    required this.durationInDays,
    required this.weather,
    required this.createdAt,
    required this.updatedAt,
    this.itemIds = const [],
  });

  factory PackingList.create({
    required String tripId,
    required String title,
    required TripType tripType,
    required int durationInDays,
    required Weather weather,
  }) {
    final now = DateTime.now();
    return PackingList(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      tripType: tripType,
      durationInDays: durationInDays,
      weather: weather,
      createdAt: now,
      updatedAt: now,
      itemIds: [],
    );
  }

  PackingList copyWith({
    String? title,
    TripType? tripType,
    int? durationInDays,
    Weather? weather,
    List<String>? itemIds,
  }) {
    return PackingList(
      id: id,
      tripId: tripId,
      title: title ?? this.title,
      tripType: tripType ?? this.tripType,
      durationInDays: durationInDays ?? this.durationInDays,
      weather: weather ?? this.weather,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      itemIds: itemIds ?? this.itemIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'tripType': tripType.name,
      'durationInDays': durationInDays,
      'weather': weather.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'itemIds': itemIds,
    };
  }

  factory PackingList.fromJson(Map<String, dynamic> json) {
    return PackingList(
      id: json['id'],
      tripId: json['tripId'],
      title: json['title'],
      tripType: TripType.values.firstWhere((e) => e.name == json['tripType']),
      durationInDays: json['durationInDays'],
      weather: Weather.values.firstWhere((e) => e.name == json['weather']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      itemIds: List<String>.from(json['itemIds'] ?? []),
    );
  }
}

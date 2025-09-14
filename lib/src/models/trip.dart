import 'package:hive/hive.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/companion.dart';

part 'trip.g.dart';

@HiveType(typeId: 0)
class Trip extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String locationName;

  @HiveField(3)
  final double locationLat;

  @HiveField(4)
  final double locationLng;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime endDate;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime lastModified;

  @HiveField(9)
  final HiveList<Day> days;

  @HiveField(10)
  final String? imageUrl;

  @HiveField(11)
  final HiveList<PackingItem> packingList;

  @HiveField(12)
  final HiveList<Companion> companions;

  Trip({
    required this.id,
    required this.title,
    required this.locationName,
    required this.locationLat,
    required this.locationLng,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.lastModified,
    required this.days,
    this.imageUrl,
    required this.packingList,
    required this.companions,
  });

  Trip copyWith({
    String? title,
    String? locationName,
    double? locationLat,
    double? locationLng,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastModified,
    HiveList<Day>? days,
    String? imageUrl,
    HiveList<PackingItem>? packingList,
    HiveList<Companion>? companions,
  }) {
    return Trip(
      id: id,
      title: title ?? this.title,
      locationName: locationName ?? this.locationName,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt,
      lastModified: lastModified ?? this.lastModified,
      days: days ?? this.days,
      imageUrl: imageUrl ?? this.imageUrl,
      packingList: packingList ?? this.packingList,
      companions: companions ?? this.companions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'locationName': locationName,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'days': days.map((day) => day.toJson()).toList(),
      'imageUrl': imageUrl,
      'packingList': packingList.map((item) => item.toJson()).toList(),
      'companions': companions.map((comp) => comp.toJson()).toList(),
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json, Box<Day> dayBox) {
    final packingListBox = Hive.box<PackingItem>('packing_items');
    final packingList = (json['packingList'] as List? ?? [])
        .map((itemJson) =>
            PackingItem.fromJson(itemJson as Map<String, dynamic>))
        .toList();
    final packingListHiveList = HiveList<PackingItem>(packingListBox)
      ..addAll(packingList);

    final companionBox = Hive.box<Companion>('companions');
    final companions = (json['companions'] as List? ?? [])
        .map((compJson) => Companion.fromJson(compJson as Map<String, dynamic>))
        .toList();
    final companionHiveList = HiveList<Companion>(companionBox)
      ..addAll(companions);

    final days = (json['days'] as List)
        .map((dayJson) => Day.fromJson(dayJson as Map<String, dynamic>))
        .toList();
    final dayHiveList = HiveList<Day>(dayBox)..addAll(days);

    return Trip(
      id: json['id'] as String,
      title: json['title'] as String,
      locationName: json['locationName'] as String,
      locationLat: (json['locationLat'] as num).toDouble(),
      locationLng: (json['locationLng'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      days: dayHiveList,
      imageUrl: json['imageUrl'] as String?,
      packingList: packingListHiveList,
      companions: companionHiveList,
    );
  }
}

import 'package:hive/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 2)
class Activity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime endTime;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String? locationName;

  @HiveField(6)
  final double? lat;

  @HiveField(7)
  final double? lng;

  @HiveField(8)
  final List<String> imagePaths;

  @HiveField(9)
  int? reminderId;

  Activity({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.notes,
    this.locationName,
    this.lat,
    this.lng,
    required this.imagePaths,
    this.reminderId,
  });

  Activity copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    String? locationName,
    double? lat,
    double? lng,
    List<String>? imagePaths,
    int? reminderId,
  }) {
    return Activity(
      id: id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      locationName: locationName ?? this.locationName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      imagePaths: imagePaths ?? this.imagePaths,
      reminderId: reminderId ?? this.reminderId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'notes': notes,
      'locationName': locationName,
      'lat': lat,
      'lng': lng,
      'imagePaths': imagePaths,
      'reminderId': reminderId,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      notes: json['notes'] as String?,
      locationName: json['locationName'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      imagePaths: List<String>.from(json['imagePaths'] as List),
      reminderId: json['reminderId'] as int?,
    );
  }
}
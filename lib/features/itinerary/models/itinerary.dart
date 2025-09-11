import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'itinerary.g.dart';

@HiveType(typeId: 13) // Feature models range 10-19
class Itinerary extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tripId;

  @HiveField(2)
  List<ItineraryDay> days;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime lastModified;

  Itinerary({
    String? id,
    required this.tripId,
    List<ItineraryDay>? days,
    DateTime? createdAt,
    DateTime? lastModified,
  })  : id = id ?? const Uuid().v4(),
        days = days ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  void addDay(ItineraryDay day) {
    days.add(day);
    lastModified = DateTime.now();
  }

  void removeDay(String dayId) {
    days.removeWhere((day) => day.id == dayId);
    lastModified = DateTime.now();
  }

  void updateDay(ItineraryDay updatedDay) {
    final index = days.indexWhere((day) => day.id == updatedDay.id);
    if (index != -1) {
      days[index] = updatedDay;
      lastModified = DateTime.now();
    }
  }

  void reorderDays(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final day = days.removeAt(oldIndex);
    days.insert(newIndex, day);
    lastModified = DateTime.now();
  }

  Duration get duration {
    if (days.isEmpty) return Duration.zero;
    return days.last.date.difference(days.first.date);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'days': days.map((day) => day.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      days: (json['days'] as List)
          .map((day) => ItineraryDay.fromJson(day))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
    );
  }
}

@HiveType(typeId: 14) // Feature models range 10-19
class ItineraryDay extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  List<ItineraryItem> items;

  @HiveField(3)
  String? notes;

  ItineraryDay({
    String? id,
    required this.date,
    List<ItineraryItem>? items,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        items = items ?? [];

  void addItem(ItineraryItem item) {
    items.add(item);
    items.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void removeItem(String itemId) {
    items.removeWhere((item) => item.id == itemId);
  }

  void updateItem(ItineraryItem updatedItem) {
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      items.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
  }

  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
    };
  }

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      id: json['id'] as String,
      date: DateTime.parse(json['date']),
      items: (json['items'] as List)
          .map((item) => ItineraryItem.fromJson(item))
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

@HiveType(typeId: 22) // Enum range 20-29
enum ItineraryItemType {
  @HiveField(0)
  flight,
  @HiveField(1)
  accommodation,
  @HiveField(2)
  activity,
  @HiveField(3)
  transportation,
  @HiveField(4)
  meal,
  @HiveField(5)
  custom
}

@HiveType(typeId: 16) // Feature models range 10-19
class ItineraryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final ItineraryItemType type;

  @HiveField(3)
  final TimeOfDay startTime;

  @HiveField(4)
  final TimeOfDay? endTime;

  @HiveField(5)
  final String? location;

  @HiveField(6)
  final String? bookingId;

  @HiveField(7)
  final Map<String, dynamic>? details;

  @HiveField(8)
  final String? notes;

  ItineraryItem({
    String? id,
    required this.title,
    required this.type,
    required this.startTime,
    this.endTime,
    this.location,
    this.bookingId,
    this.details,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Duration? get duration {
    if (endTime == null) return null;
    final start = startTime.hour * 60 + startTime.minute;
    final end = endTime!.hour * 60 + endTime!.minute;
    return Duration(minutes: end - start);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      if (endTime != null) 'endTime': '${endTime!.hour}:${endTime!.minute}',
      if (location != null) 'location': location,
      if (bookingId != null) 'bookingId': bookingId,
      if (details != null) 'details': details,
      if (notes != null) 'notes': notes,
    };
  }

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    final startTimeParts = (json['startTime'] as String).split(':');
    final endTimeParts = json['endTime']?.split(':');

    return ItineraryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      type: ItineraryItemType.values.firstWhere(
        (type) => type.toString() == json['type'],
      ),
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: endTimeParts != null
          ? TimeOfDay(
              hour: int.parse(endTimeParts[0]),
              minute: int.parse(endTimeParts[1]),
            )
          : null,
      location: json['location'] as String?,
      bookingId: json['bookingId'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
    );
  }

  ItineraryItem copyWith({
    String? title,
    ItineraryItemType? type,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? bookingId,
    Map<String, dynamic>? details,
    String? notes,
  }) {
    return ItineraryItem(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      bookingId: bookingId ?? this.bookingId,
      details: details ?? this.details,
      notes: notes ?? this.notes,
    );
  }
}

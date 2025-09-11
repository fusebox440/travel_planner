import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'booking.g.dart';

@HiveType(typeId: 20) // Moved to enum range to avoid conflicts
enum BookingType {
  @HiveField(0)
  flight,
  @HiveField(1)
  hotel,
  @HiveField(2)
  car,
  @HiveField(3)
  activity
}

@HiveType(typeId: 21) // Sequential enum ID
enum BookingStatus {
  @HiveField(0)
  reserved,
  @HiveField(1)
  cancelled,
  @HiveField(2)
  completed
}

@HiveType(typeId: 15) // Feature models range 10-19
class Booking extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final BookingType type;

  @HiveField(2)
  final String provider;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final Map<String, dynamic> details;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final String currencyCode;

  @HiveField(7)
  final DateTime date;

  @HiveField(8)
  final String tripId;

  @HiveField(9)
  BookingStatus status;

  @HiveField(10)
  final DateTime createdAt;

  Booking({
    String? id,
    required this.type,
    required this.provider,
    required this.title,
    required this.details,
    required this.price,
    required this.currencyCode,
    required this.date,
    required this.tripId,
    this.status = BookingStatus.reserved,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Booking copyWith({
    String? id,
    BookingType? type,
    String? provider,
    String? title,
    Map<String, dynamic>? details,
    double? price,
    String? currencyCode,
    DateTime? date,
    String? tripId,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      title: title ?? this.title,
      details: details ?? Map<String, dynamic>.from(this.details),
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      date: date ?? this.date,
      tripId: tripId ?? this.tripId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'provider': provider,
      'title': title,
      'details': details,
      'price': price,
      'currencyCode': currencyCode,
      'date': date.toIso8601String(),
      'tripId': tripId,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      type: BookingType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      provider: json['provider'] as String,
      title: json['title'] as String,
      details: json['details'] as Map<String, dynamic>,
      price: json['price'] as double,
      currencyCode: json['currencyCode'] as String,
      date: DateTime.parse(json['date'] as String),
      tripId: json['tripId'] as String,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

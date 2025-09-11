import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class TileRegion {
  final String id;
  final String name;
  final LatLngBounds bounds;
  final int minZoom;
  final int maxZoom;
  final DateTime createdAt;

  TileRegion({
    String? id,
    required this.name,
    required this.bounds,
    this.minZoom = 10,
    this.maxZoom = 16,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'min_lat': bounds.southwest.latitude,
      'max_lat': bounds.northeast.latitude,
      'min_lng': bounds.southwest.longitude,
      'max_lng': bounds.northeast.longitude,
      'min_zoom': minZoom,
      'max_zoom': maxZoom,
      'timestamp': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TileRegion.fromMap(Map<String, dynamic> map) {
    return TileRegion(
      id: map['id'] as String,
      name: map['name'] as String,
      bounds: LatLngBounds(
        southwest: LatLng(
          map['min_lat'] as double,
          map['min_lng'] as double,
        ),
        northeast: LatLng(
          map['max_lat'] as double,
          map['max_lng'] as double,
        ),
      ),
      minZoom: map['min_zoom'] as int,
      maxZoom: map['max_zoom'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}

class MapTile {
  final int z;
  final int x;
  final int y;

  const MapTile({
    required this.z,
    required this.x,
    required this.y,
  });
}

class TransitStop {
  final String id;
  final String name;
  final LatLng location;
  final List<TransitLine> lines;

  TransitStop({
    required this.id,
    required this.name,
    required this.location,
    required this.lines,
  });
}

class TransitLine {
  final String id;
  final String name;
  final String type; // bus, train, subway, etc.
  final String color;
  final List<TransitSchedule> schedule;

  TransitLine({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.schedule,
  });
}

class TransitSchedule {
  final String tripId;
  final String destination;
  final DateTime departureTime;
  final int delayMinutes;
  final bool isRealTime;

  TransitSchedule({
    required this.tripId,
    required this.destination,
    required this.departureTime,
    this.delayMinutes = 0,
    this.isRealTime = false,
  });
}

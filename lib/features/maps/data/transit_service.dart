import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/models/tile_region.dart';

class TransitService {
  static const apiKey = 'YOUR_TRANSIT_API_KEY'; // TODO: Move to config

  Future<List<TransitStop>> getNearbyStops(LatLng location,
      {double radius = 500}) async {
    final url = Uri.https(
      'transit.api.example.com', // Replace with actual transit API
      '/stops/nearby',
      {
        'lat': location.latitude.toString(),
        'lng': location.longitude.toString(),
        'radius': radius.toString(),
        'key': apiKey,
      },
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to get nearby stops');
      }

      final data = json.decode(response.body);
      return (data['stops'] as List).map((stop) {
        return TransitStop(
          id: stop['id'],
          name: stop['name'],
          location: LatLng(
            stop['location']['lat'],
            stop['location']['lng'],
          ),
          lines: (stop['lines'] as List).map((line) {
            return TransitLine(
              id: line['id'],
              name: line['name'],
              type: line['type'],
              color: line['color'],
              schedule: (line['departures'] as List).map((departure) {
                return TransitSchedule(
                  tripId: departure['trip_id'],
                  destination: departure['destination'],
                  departureTime: DateTime.parse(departure['time']),
                  delayMinutes: departure['delay'] ?? 0,
                  isRealTime: departure['realtime'] ?? false,
                );
              }).toList(),
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get nearby stops: $e');
    }
  }

  Future<List<TransitSchedule>> getStopSchedule(String stopId) async {
    final url = Uri.https(
      'transit.api.example.com',
      '/stops/$stopId/schedule',
      {'key': apiKey},
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to get stop schedule');
      }

      final data = json.decode(response.body);
      return (data['departures'] as List).map((departure) {
        return TransitSchedule(
          tripId: departure['trip_id'],
          destination: departure['destination'],
          departureTime: DateTime.parse(departure['time']),
          delayMinutes: departure['delay'] ?? 0,
          isRealTime: departure['realtime'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get stop schedule: $e');
    }
  }

  Future<Map<String, dynamic>> getTransitRoute(
    LatLng from,
    LatLng to,
    DateTime departAt,
  ) async {
    final url = Uri.https(
      'transit.api.example.com',
      '/route',
      {
        'from_lat': from.latitude.toString(),
        'from_lng': from.longitude.toString(),
        'to_lat': to.latitude.toString(),
        'to_lng': to.longitude.toString(),
        'depart_at': departAt.toIso8601String(),
        'key': apiKey,
      },
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to get transit route');
      }

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to get transit route: $e');
    }
  }
}

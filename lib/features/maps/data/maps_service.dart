import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/models/place.dart';

class DirectionsResult {
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;
  final List<String> steps;
  final String mode;

  DirectionsResult({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
    required this.steps,
    required this.mode,
  });
}

class MapsService {
  static const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // TODO: Move to config
  final _location = Location();
  final _polylinePoints = PolylinePoints();
  StreamController<LocationData>? _locationController;

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return false;
    }

    return true;
  }

  Stream<LocationData> get locationStream {
    _locationController ??= StreamController<LocationData>.broadcast();

    _location.onLocationChanged.listen(
      (locationData) => _locationController?.add(locationData),
      onError: (error) => _locationController?.addError(error),
    );

    return _locationController!.stream;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      return await _location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Future<List<Place>> searchPlaces(String query, {LatLng? near}) async {
    final params = {
      'key': apiKey,
      'query': query,
    };

    if (near != null) {
      params['location'] = '${near.latitude},${near.longitude}';
      params['radius'] = '5000'; // 5km radius
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/textsearch/json',
      params,
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to search places');
      }

      final data = json.decode(response.body);
      if (data['status'] != 'OK') {
        throw Exception(data['error_message'] ?? 'Failed to search places');
      }

      return (data['results'] as List)
          .map((place) => Place.fromGooglePlace(place))
          .toList();
    } catch (e) {
      throw Exception('Failed to search places: $e');
    }
  }

  Future<DirectionsResult> getDirections(
    LatLng from,
    LatLng to, {
    String mode = 'driving',
  }) async {
    final params = {
      'key': apiKey,
      'origin': '${from.latitude},${from.longitude}',
      'destination': '${to.latitude},${to.longitude}',
      'mode': mode,
    };

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      params,
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to get directions');
      }

      final data = json.decode(response.body);
      if (data['status'] != 'OK') {
        throw Exception(data['error_message'] ?? 'Failed to get directions');
      }

      final route = data['routes'][0];
      final leg = route['legs'][0];
      final polylinePoints = _polylinePoints.decodePolyline(
        route['overview_polyline']['points'],
      );

      return DirectionsResult(
        polylinePoints: polylinePoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
        distance: leg['distance']['text'],
        duration: leg['duration']['text'],
        steps: (leg['steps'] as List)
            .map((step) => step['html_instructions'] as String)
            .toList(),
        mode: mode,
      );
    } catch (e) {
      throw Exception('Failed to get directions: $e');
    }
  }

  Future<void> downloadOfflineMap(String region) async {
    // TODO: Implement offline maps downloading
    // This is a stub for future implementation
    await Future.delayed(const Duration(seconds: 2));
  }

  void dispose() {
    _locationController?.close();
    _locationController = null;
  }
}

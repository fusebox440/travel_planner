import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../data/maps_service.dart';
import '../../domain/models/place.dart';

// Service provider
final mapsServiceProvider = Provider<MapsService>((ref) {
  final service = MapsService();
  ref.onDispose(() => service.dispose());
  return service;
});

// State classes
class MapState {
  final LocationData? userLocation;
  final List<Place> searchResults;
  final DirectionsResult? directions;
  final bool isLoading;
  final String? error;
  final MapType mapType;
  final CameraPosition? cameraPosition;

  const MapState({
    this.userLocation,
    this.searchResults = const [],
    this.directions,
    this.isLoading = false,
    this.error,
    this.mapType = MapType.normal,
    this.cameraPosition,
  });

  MapState copyWith({
    LocationData? userLocation,
    List<Place>? searchResults,
    DirectionsResult? directions,
    bool? isLoading,
    String? error,
    MapType? mapType,
    CameraPosition? cameraPosition,
  }) {
    return MapState(
      userLocation: userLocation ?? this.userLocation,
      searchResults: searchResults ?? this.searchResults,
      directions: directions ?? this.directions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      mapType: mapType ?? this.mapType,
      cameraPosition: cameraPosition ?? this.cameraPosition,
    );
  }
}

class MapsNotifier extends StateNotifier<MapState> {
  final MapsService _mapsService;
  StreamSubscription<LocationData>? _locationSubscription;

  MapsNotifier(this._mapsService) : super(const MapState()) {
    _init();
  }

  Future<void> _init() async {
    final hasPermission = await _mapsService.requestLocationPermission();
    if (!hasPermission) {
      state = state.copyWith(
        error: 'Location permission denied',
        isLoading: false,
      );
      return;
    }

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationSubscription = _mapsService.locationStream.listen(
      (location) {
        state = state.copyWith(
          userLocation: location,
          cameraPosition: CameraPosition(
            target: LatLng(location.latitude!, location.longitude!),
            zoom: 15,
          ),
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Failed to get location updates: $error',
          isLoading: false,
        );
      },
    );
  }

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _mapsService.searchPlaces(
        query,
        near: state.userLocation != null
            ? LatLng(
                state.userLocation!.latitude!,
                state.userLocation!.longitude!,
              )
            : null,
      );
      state = state.copyWith(searchResults: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to search places: $e',
        isLoading: false,
      );
    }
  }

  Future<void> getDirections(LatLng destination,
      {String mode = 'driving'}) async {
    if (state.userLocation == null) {
      state = state.copyWith(error: 'Current location not available');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final directions = await _mapsService.getDirections(
        LatLng(
          state.userLocation!.latitude!,
          state.userLocation!.longitude!,
        ),
        destination,
        mode: mode,
      );
      state = state.copyWith(directions: directions, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to get directions: $e',
        isLoading: false,
      );
    }
  }

  void toggleMapType() {
    final currentType = state.mapType;
    final newType = currentType == MapType.normal
        ? MapType.satellite
        : currentType == MapType.satellite
            ? MapType.terrain
            : MapType.normal;

    state = state.copyWith(mapType: newType);
  }

  void clearDirections() {
    state = state.copyWith(directions: null);
  }

  void clearSearch() {
    state = state.copyWith(searchResults: []);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}

// Provider
final mapsProvider = StateNotifierProvider<MapsNotifier, MapState>((ref) {
  final mapsService = ref.watch(mapsServiceProvider);
  return MapsNotifier(mapsService);
});

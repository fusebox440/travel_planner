import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travel_planner/features/trips/presentation/widgets/location_result.dart';

class MapPicker extends StatefulWidget {
  const MapPicker({super.key});

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(12.9165, 79.1325),
    zoom: 12,
  );

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = 'Long-press on the map to select a location.';

  @override
  void initState() {
    super.initState();
    _requestPermissionAndSetCurrentLocation();
  }

  Future<void> _requestPermissionAndSetCurrentLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _initialCameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14,
          );
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(_initialCameraPosition),
          );
        });
      } catch (e) {
        debugPrint("Error getting current location: $e");
      }
    } else {
      debugPrint("Location permission denied.");
    }
  }

  void _onLongPress(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _selectedAddress =
      'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    });
  }

  void _onConfirm() {
    if (_selectedLocation != null) {
      final result = LocationResult(
        name: _selectedAddress,
        lat: _selectedLocation!.latitude,
        lng: _selectedLocation!.longitude,
      );
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onLongPress: _onLongPress,
            markers: _selectedLocation == null
                ? {}
                : {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: _selectedLocation!,
                infoWindow: const InfoWindow(title: 'Selected Location'),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              // FIX: Corrected deprecated withOpacity
              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(230),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedAddress, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _selectedLocation == null ? null : _onConfirm,
                    child: const Text('Confirm Location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
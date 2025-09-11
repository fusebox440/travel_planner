import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/maps_provider.dart';
import '../providers/bookmark_provider.dart';
import '../../domain/models/place.dart';

class MapScreen extends ConsumerStatefulWidget {
  final Place? initialPlace;

  const MapScreen({super.key, this.initialPlace});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final _searchController = TextEditingController();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMapStyle();
  }

  Future<void> _updateMapStyle() async {
    if (_mapController == null) return;

    // TODO: Load custom map style JSON
    // final style = await rootBundle.loadString('assets/map_style.json');
    // await _mapController!.setMapStyle(style);
  }

  void _addMarker(Place place) {
    final marker = Marker(
      markerId: MarkerId(place.id),
      position: LatLng(place.lat, place.lng),
      infoWindow: InfoWindow(
        title: place.name,
        snippet: place.type.displayName,
      ),
      onTap: () => _showPlaceDetails(place),
    );

    setState(() {
      _markers = {..._markers, marker};
    });
  }

  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PlaceDetailsSheet(place: place),
    );
  }

  void _updatePolyline() {
    final directions = ref.read(mapsProvider).directions;
    if (directions == null) {
      setState(() => _polylines = {});
      return;
    }

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Theme.of(context).colorScheme.primary,
      points: directions.polylinePoints,
      width: 5,
    );

    setState(() => _polylines = {polyline});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapsProvider);

    // Update markers and polylines when state changes
    if (state.searchResults.isNotEmpty) {
      for (final place in state.searchResults) {
        _addMarker(place);
      }
    }
    if (state.directions != null) {
      _updatePolyline();
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(state),
          _buildSearchBar(),
          if (state.directions != null) _buildDirectionsPanel(state),
          if (state.isLoading) const Center(child: CircularProgressIndicator()),
          if (state.error != null) _buildErrorSnackbar(state.error!),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'recenter',
            onPressed: _recenterMap,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'mapType',
            onPressed: () => ref.read(mapsProvider.notifier).toggleMapType(),
            child: const Icon(Icons.layers),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(MapState state) {
    if (state.userLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: widget.initialPlace != null
          ? CameraPosition(
              target: LatLng(
                widget.initialPlace!.lat,
                widget.initialPlace!.lng,
              ),
              zoom: 15,
            )
          : CameraPosition(
              target: LatLng(
                state.userLocation!.latitude!,
                state.userLocation!.longitude!,
              ),
              zoom: 15,
            ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: state.mapType,
      markers: _markers,
      polylines: _polylines,
      onTap: (_) => ref.read(mapsProvider.notifier).clearDirections(),
    );
  }

  Widget _buildSearchBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search places...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(mapsProvider.notifier).clearSearch();
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (query) =>
                ref.read(mapsProvider.notifier).searchPlaces(query),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionsPanel(MapState state) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.7,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(
                  '${state.directions!.duration} (${state.directions!.distance})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      ref.read(mapsProvider.notifier).clearDirections(),
                ),
              ],
            ),
            const Divider(),
            ...state.directions!.steps.map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(step),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSnackbar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
    return const SizedBox.shrink();
  }

  void _recenterMap() {
    final state = ref.read(mapsProvider);
    if (state.userLocation == null || _mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            state.userLocation!.latitude!,
            state.userLocation!.longitude!,
          ),
          zoom: 15,
        ),
      ),
    );
  }
}

class _PlaceDetailsSheet extends ConsumerWidget {
  final Place place;

  const _PlaceDetailsSheet({required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked = bookmarkState.bookmarks.any((b) => b.id == place.id);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      place.type.displayName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () {
                  if (isBookmarked) {
                    ref
                        .read(bookmarkProvider.notifier)
                        .removeBookmark(place.id);
                  } else {
                    ref.read(bookmarkProvider.notifier).addBookmark(place);
                  }
                },
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.directions,
                label: 'Directions',
                onPressed: () {
                  ref.read(mapsProvider.notifier).getDirections(
                        LatLng(place.lat, place.lng),
                      );
                  Navigator.pop(context);
                },
              ),
              _ActionButton(
                icon: Icons.directions_walk,
                label: 'Walking',
                onPressed: () {
                  ref.read(mapsProvider.notifier).getDirections(
                        LatLng(place.lat, place.lng),
                        mode: 'walking',
                      );
                  Navigator.pop(context);
                },
              ),
              _ActionButton(
                icon: Icons.directions_transit,
                label: 'Transit',
                onPressed: () {
                  ref.read(mapsProvider.notifier).getDirections(
                        LatLng(place.lat, place.lng),
                        mode: 'transit',
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../providers/bookmark_provider.dart';
import '../providers/maps_provider.dart';
import 'map_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkProvider);
    final mapsState = ref.watch(mapsProvider);
    final userLocation = mapsState.userLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Places'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.bookmarks.isEmpty
              ? _buildEmptyState(context)
              : _buildBookmarksList(
                  context,
                  state.bookmarks,
                  userLocation,
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved places yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Bookmark places you want to visit',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList(
    BuildContext context,
    List<dynamic> bookmarks,
    LocationData? userLocation,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final place = bookmarks[index];
        String? distance;

        if (userLocation != null) {
          final placeLocation = LatLng(place.lat, place.lng);
          final userLatLng =
              LatLng(userLocation.latitude!, userLocation.longitude!);
          distance = _calculateDistance(placeLocation, userLatLng);
        }

        return Card(
          child: ListTile(
            leading: Icon(
              Icons.place,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(place.name),
            subtitle: Text(place.type.displayName),
            trailing: distance != null
                ? Text(
                    distance,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MapScreen(initialPlace: place),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _calculateDistance(LatLng from, LatLng to) {
    // TODO: Implement proper distance calculation
    // For now, return a placeholder
    return '2.5 km away';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/maps_provider.dart';
import '../../data/transit_service.dart';
import '../../domain/models/tile_region.dart';

final transitServiceProvider = Provider<TransitService>((ref) {
  return TransitService();
});

class TransitScreen extends ConsumerStatefulWidget {
  final LatLng destination;

  const TransitScreen({
    super.key,
    required this.destination,
  });

  @override
  ConsumerState<TransitScreen> createState() => _TransitScreenState();
}

class _TransitScreenState extends ConsumerState<TransitScreen> {
  List<TransitStop>? _nearbyStops;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNearbyStops();
  }

  Future<void> _loadNearbyStops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transitService = ref.read(transitServiceProvider);
      final state = ref.read(mapsProvider);

      if (state.userLocation == null) {
        throw Exception('Location not available');
      }

      final stops = await transitService.getNearbyStops(
        LatLng(
          state.userLocation!.latitude!,
          state.userLocation!.longitude!,
        ),
      );

      setState(() {
        _nearbyStops = stops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Transit'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNearbyStops,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _buildStopsList(),
      ),
    );
  }

  Widget _buildStopsList() {
    if (_nearbyStops == null || _nearbyStops!.isEmpty) {
      return const Center(
        child: Text('No transit stops found nearby'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nearbyStops!.length,
      itemBuilder: (context, index) {
        final stop = _nearbyStops![index];
        return Card(
          child: ExpansionTile(
            leading: const Icon(Icons.directions_bus),
            title: Text(stop.name),
            subtitle: Text(
              'Lines: ${stop.lines.map((l) => l.name).join(", ")}',
            ),
            children: [
              _buildStopSchedule(stop),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStopSchedule(TransitStop stop) {
    return Column(
      children: stop.lines.map((line) {
        return _buildLineDepartures(line);
      }).toList(),
    );
  }

  Widget _buildLineDepartures(TransitLine line) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(int.parse(line.color.replaceAll('#', '0xFF'))),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${line.name} (${line.type})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...line.schedule
              .where((s) => s.departureTime.isAfter(DateTime.now()))
              .take(3)
              .map((schedule) {
            final delay = schedule.delayMinutes > 0
                ? ' (+${schedule.delayMinutes}min)'
                : '';
            return Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${schedule.departureTime.hour.toString().padLeft(2, '0')}:${schedule.departureTime.minute.toString().padLeft(2, '0')}$delay',
                    style: TextStyle(
                      color: schedule.isRealTime
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '→ ${schedule.destination}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

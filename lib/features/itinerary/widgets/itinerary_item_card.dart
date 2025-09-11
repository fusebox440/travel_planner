import 'package:flutter/material.dart';
import '../models/itinerary.dart';

class ItineraryItemCard extends StatelessWidget {
  final ItineraryItem item;
  final VoidCallback onTap;
  final bool isDragging;

  const ItineraryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: isDragging ? 8 : 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildTimeColumn(context),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailsColumn(context),
              ),
              _buildTypeIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatTime(item.startTime),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (item.endTime != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatTime(item.endTime!),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (item.location != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.location!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (item.notes != null) ...[
          const SizedBox(height: 4),
          Text(
            item.notes!,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (item.type) {
      case ItineraryItemType.flight:
        icon = Icons.flight;
        color = Colors.blue;
        break;
      case ItineraryItemType.accommodation:
        icon = Icons.hotel;
        color = Colors.purple;
        break;
      case ItineraryItemType.activity:
        icon = Icons.local_activity;
        color = Colors.orange;
        break;
      case ItineraryItemType.transportation:
        icon = Icons.directions_car;
        color = Colors.green;
        break;
      case ItineraryItemType.meal:
        icon = Icons.restaurant;
        color = Colors.red;
        break;
      case ItineraryItemType.custom:
        icon = Icons.event;
        color = Colors.grey;
        break;
    }

    return Icon(
      icon,
      color: color,
      size: 24,
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

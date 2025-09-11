import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import 'itinerary_item_card.dart';

class ItineraryDayCard extends StatelessWidget {
  final ItineraryDay day;
  final bool isSelected;
  final Function(String) onDaySelected;
  final VoidCallback onAddItem;
  final VoidCallback onRemoveDay;

  const ItineraryDayCard({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onDaySelected,
    required this.onAddItem,
    required this.onRemoveDay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onDaySelected(day.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            if (day.items.isNotEmpty) ...[
              const Divider(),
              _buildItemsList(),
            ],
            if (isSelected) _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(day.date),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (day.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    day.notes!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showDayOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: day.items.map((item) {
        return ItineraryItemCard(
          item: item,
          onTap: () {},
        );
      }).toList(),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            onPressed: onAddItem,
          ),
        ],
      ),
    );
  }

  void _showDayOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Edit Notes'),
              onTap: () {
                Navigator.pop(context);
                _showEditNotesDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove Day'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditNotesDialog(BuildContext context) async {
    final controller = TextEditingController(text: day.notes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Day Notes'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Add notes for this day...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Update notes
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Day'),
        content: Text(
          'Are you sure you want to remove ${_formatDate(day.date)} '
          'from the itinerary?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onRemoveDay();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

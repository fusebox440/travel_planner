import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';
import '../providers/itinerary_provider.dart';
import '../widgets/itinerary_day_card.dart';
import '../widgets/import_dialog.dart';
import '../widgets/add_item_dialog.dart';

class ItineraryScreen extends ConsumerWidget {
  final String tripId;

  const ItineraryScreen({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(itineraryProvider(tripId));

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: ${state.error}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state.itinerary == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No itinerary found'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _showCreateDialog(context, ref),
                child: const Text('Create Itinerary'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Itinerary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () => _showImportDialog(context, ref),
            tooltip: 'Import from Email or Bookings',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDayDialog(context, ref),
            tooltip: 'Add Day',
          ),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.itinerary!.days.length,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          ref
              .read(itineraryProvider(tripId).notifier)
              .reorderDays(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final day = state.itinerary!.days[index];
          return ItineraryDayCard(
            key: ValueKey(day.id),
            day: day,
            isSelected: day.id == state.selectedDayId,
            onDaySelected: (dayId) {
              ref
                  .read(itineraryProvider(tripId).notifier)
                  .setSelectedDay(dayId);
            },
            onAddItem: () => _showAddItemDialog(context, ref, day.id),
            onRemoveDay: () {
              ref.read(itineraryProvider(tripId).notifier).removeDay(day.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showShareDialog(context),
        child: const Icon(Icons.share),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Itinerary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('When does your trip start?'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null && context.mounted) {
                  final days = await showDialog<int>(
                    context: context,
                    builder: (context) => NumberPickerDialog(
                      minValue: 1,
                      maxValue: 30,
                      title: 'How many days?',
                    ),
                  );
                  if (days != null && context.mounted) {
                    Navigator.pop(context, {
                      'startDate': date,
                      'days': days,
                    });
                  }
                }
              },
              child: const Text('Select Start Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      ref.read(itineraryProvider(tripId).notifier).createItinerary(
            result['startDate'] as DateTime,
            result['days'] as int,
          );
    }
  }

  Future<void> _showImportDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<ImportResult>(
      context: context,
      builder: (context) => const ImportDialog(),
    );

    if (result != null) {
      switch (result.type) {
        case ImportType.bookings:
          ref
              .read(itineraryProvider(tripId).notifier)
              .importBookings(result.bookings!);
          break;
        case ImportType.email:
          ref
              .read(itineraryProvider(tripId).notifier)
              .importFromEmail(result.emailContent!);
          break;
      }
    }
  }

  Future<void> _showAddDayDialog(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      ref.read(itineraryProvider(tripId).notifier).addDay(date);
    }
  }

  Future<void> _showAddItemDialog(
    BuildContext context,
    WidgetRef ref,
    String dayId,
  ) async {
    final result = await showDialog<ItineraryItem>(
      context: context,
      builder: (context) => const AddItemDialog(),
    );

    if (result != null) {
      ref.read(itineraryProvider(tripId).notifier).addItem(dayId, result);
    }
  }

  Future<void> _showShareDialog(BuildContext context) async {
    // TODO: Implement sharing functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Itinerary'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Message'),
            ),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('Copy Link'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class NumberPickerDialog extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final String title;

  const NumberPickerDialog({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.title,
  });

  @override
  State<NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.minValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _selectedValue > widget.minValue
                ? () => setState(() => _selectedValue--)
                : null,
          ),
          Text(
            _selectedValue.toString(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _selectedValue < widget.maxValue
                ? () => setState(() => _selectedValue++)
                : null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedValue),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

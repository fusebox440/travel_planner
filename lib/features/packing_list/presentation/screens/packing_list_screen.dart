import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_planner/features/trips/presentation/providers/trip_providers.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/widgets/ui_components.dart';

class PackingListScreen extends ConsumerStatefulWidget {
  final String tripId;
  const PackingListScreen({super.key, required this.tripId});

  @override
  ConsumerState<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends ConsumerState<PackingListScreen> {
  final _textController = TextEditingController();

  void _addItem() {
    if (_textController.text.trim().isEmpty) return;
    final newItem = PackingItem.create(name: _textController.text.trim());
    ref.read(tripListProvider.notifier).addPackingItem(widget.tripId, newItem);
    _textController.clear();
    FocusScope.of(context).unfocus(); // Dismiss keyboard
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing List'),
      ),
      body: tripAsync.when(
        data: (trip) {
          if (trip == null) return const Center(child: Text('Trip not found.'));
          final packingList = trip.packingList;

          return Column(
            children: [
              Expanded(
                child: packingList.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/empty_travel.json',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your packing list is empty.',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first item below.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: packingList.length,
                  itemBuilder: (context, index) {
                    final item = packingList[index];
                    return CheckboxListTile(
                      value: item.isChecked,
                      onChanged: (bool? value) {
                        HapticFeedback.lightImpact();
                        if (value != null) {
                          item.isChecked = value;
                          ref.read(tripListProvider.notifier).updatePackingItem(widget.tripId, item);
                        }
                      },
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          color: item.isChecked ? Colors.grey : null,
                        ),
                      ),
                      secondary: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(tripListProvider.notifier).deletePackingItem(widget.tripId, item.id);
                        },
                      ),
                    );
                  },
                ),
              ),
              // Add Item Input Area
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: FormInput(
                        label: 'New Item',
                        controller: _textController,
                        hintText: 'e.g., Sunscreen',
                      ),
                    ),
                    const SizedBox(width: 8),
                    PrimaryButton(
                      text: 'Add',
                      onPressed: _addItem,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
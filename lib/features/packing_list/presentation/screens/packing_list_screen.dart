import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/packing_list/presentation/providers/packing_list_provider.dart';
import 'package:travel_planner/src/models/item_category.dart';
import 'package:travel_planner/src/models/trip.dart';

class PackingListScreen extends ConsumerWidget {
  final Trip trip;
  const PackingListScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packingListAsync = ref.watch(packingListProvider(trip));

    return Scaffold(
      appBar: AppBar(
        title: Text('${trip.title} - Packing List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset List',
            onPressed: () =>
                ref.read(packingListProvider(trip).notifier).resetList(),
          ),
        ],
      ),
      body: packingListAsync.when(
        data: (list) {
          if (list == null)
            return const Center(child: Text('No packing list found.'));

          final items = list.items;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return CheckboxListTile(
                value: item.isChecked,
                onChanged: (_) => ref
                    .read(packingListProvider(trip).notifier)
                    .toggleItem(item.id),
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration:
                        item.isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                secondary: IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => ref
                      .read(packingListProvider(trip).notifier)
                      .deleteItem(item.id),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddItemDialog(context, ref, trip),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => _AddPackingItemDialog(
        onAddItem: (name, category) {
          // Convert ItemCategory to String using .name
          ref
              .read(packingListProvider(trip).notifier)
              .addItem(name, category.name);
        },
      ),
    );
  }
}

class _AddPackingItemDialog extends StatefulWidget {
  final Function(String, ItemCategory) onAddItem;
  const _AddPackingItemDialog({required this.onAddItem});

  @override
  State<_AddPackingItemDialog> createState() => _AddPackingItemDialogState();
}

class _AddPackingItemDialogState extends State<_AddPackingItemDialog> {
  final _controller = TextEditingController();
  var _category = ItemCategory.Other;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Item Name'),
            autofocus: true,
          ),
          DropdownButton<ItemCategory>(
            value: _category,
            isExpanded: true,
            items: ItemCategory.values
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat.toString().split('.').last),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _category = val!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAddItem(_controller.text, _category);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

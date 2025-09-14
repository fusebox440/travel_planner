import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/budget/presentation/providers/budget_provider.dart';
import 'package:travel_planner/src/models/companion.dart';

class ManageCompanionsScreen extends ConsumerStatefulWidget {
  final String tripId;
  const ManageCompanionsScreen({super.key, required this.tripId});

  @override
  ConsumerState<ManageCompanionsScreen> createState() =>
      _ManageCompanionsScreenState();
}

class _ManageCompanionsScreenState
    extends ConsumerState<ManageCompanionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Companion'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                HapticFeedback.lightImpact();

                final companion = Companion.create(
                  name: _nameController.text,
                  email: _emailController.text.isEmpty
                      ? null
                      : _emailController.text,
                  phone: _phoneController.text.isEmpty
                      ? null
                      : _phoneController.text,
                );

                final budgetService =
                    await ref.read(budgetServiceProvider.future);
                await budgetService.addCompanionToTrip(
                    widget.tripId, companion);

                if (!mounted) return;
                Navigator.pop(context);

                // Clear form
                _nameController.clear();
                _emailController.clear();
                _phoneController.clear();

                // Invalidate the provider to refresh the UI
                ref.invalidate(tripCompanionsProvider(widget.tripId));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companions = ref.watch(tripCompanionsProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Companions'),
      ),
      body: companions.when(
        data: (companionsList) {
          if (companionsList.isEmpty) {
            return const Center(
              child: Text('No companions added yet'),
            );
          }

          return ListView.builder(
            itemCount: companionsList.length,
            itemBuilder: (context, index) {
              final companion = companionsList[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    companion.name[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(companion.name),
                subtitle: Text(companion.email ?? companion.phone ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Companion'),
                        content: Text(
                          'Are you sure you want to delete ${companion.name}? '
                          'This will not affect existing expenses.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed ?? false) {
                      HapticFeedback.lightImpact();
                      final budgetService =
                          await ref.read(budgetServiceProvider.future);
                      await budgetService.deleteCompanionFromTrip(
                          widget.tripId, companion.id);

                      // Invalidate the provider to refresh the UI
                      ref.invalidate(tripCompanionsProvider(widget.tripId));
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

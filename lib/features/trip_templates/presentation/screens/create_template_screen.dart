import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/trip_template.dart';
import '../providers/trip_template_providers.dart';

class CreateTemplateScreen extends ConsumerStatefulWidget {
  final String? fromTripId; // If creating from existing trip

  const CreateTemplateScreen({
    Key? key,
    this.fromTripId,
  }) : super(key: key);

  @override
  ConsumerState<CreateTemplateScreen> createState() =>
      _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends ConsumerState<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  TemplateCategory _selectedCategory = TemplateCategory.custom;
  int _duration = 3;
  double _minBudget = 100;
  double _maxBudget = 500;
  final List<String> _tags = [];
  final List<String> _destinations = [];
  bool _isPublic = false;

  final _tagController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.fromTripId != null) {
      _prefillFromTrip();
    }
  }

  void _prefillFromTrip() {
    // This would normally load trip data and prefill the form
    // For now, just set some defaults
    _nameController.text = 'My Trip Template';
    _descriptionController.text = 'Template created from my trip';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.fromTripId != null ? 'Create from Trip' : 'Create Template'),
        actions: [
          TextButton(
            onPressed: _createTemplate,
            child: const Text('Create'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildCategorySelection(),
              const SizedBox(height: 24),
              _buildDurationAndBudget(),
              const SizedBox(height: 24),
              _buildTags(),
              const SizedBox(height: 24),
              _buildDestinations(),
              const SizedBox(height: 24),
              _buildSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a template name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TemplateCategory.values.map((category) {
                return FilterChip(
                  label: Text(_formatCategoryName(category)),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationAndBudget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration & Budget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration: $_duration days',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: _duration.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        onChanged: (value) {
                          setState(() {
                            _duration = value.round();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Min Budget (\$)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _minBudget.toString(),
                    onChanged: (value) {
                      _minBudget = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Max Budget (\$)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _maxBudget.toString(),
                    onChanged: (value) {
                      _maxBudget = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Add tag',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(_tagController.text),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suitable Destinations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Add destination',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: _addDestination,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addDestination(_destinationController.text),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _destinations.map((destination) {
                return Chip(
                  label: Text(destination),
                  onDeleted: () {
                    setState(() {
                      _destinations.remove(destination);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Make Public'),
              subtitle: const Text('Allow other users to use this template'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _addDestination(String destination) {
    if (destination.isNotEmpty && !_destinations.contains(destination)) {
      setState(() {
        _destinations.add(destination);
        _destinationController.clear();
      });
    }
  }

  void _createTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one tag')),
      );
      return;
    }

    if (_destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one destination')),
      );
      return;
    }

    try {
      TripTemplate template;

      if (widget.fromTripId != null) {
        // Create template from existing trip
        template = await ref
            .read(templateOperationsProvider.notifier)
            .createTemplateFromTrip(widget.fromTripId!);

        // Update with form data
        template = template.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          tags: _tags,
          suitableDestinations: _destinations,
          isPublic: _isPublic,
        );

        await ref
            .read(templateOperationsProvider.notifier)
            .updateTemplate(template);
      } else {
        // Create new template
        template = TripTemplate.create(
          name: _nameController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          durationDays: _duration,
          estimatedBudgetMin: _minBudget,
          estimatedBudgetMax: _maxBudget,
          currency: 'USD',
          suitableDestinations: _destinations,
          tags: _tags,
          dayStructures: [], // Empty for now, would be filled by user
          creatorId: 'current_user', // TODO: Get from auth service
          creatorName: 'Me', // TODO: Get from user profile
          isPublic: _isPublic,
        );

        await ref
            .read(templateOperationsProvider.notifier)
            .saveTemplate(template);
      }

      // Refresh the templates list
      ref.invalidate(allTemplatesProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template created successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create template: $e')),
      );
    }
  }

  String _formatCategoryName(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.business:
        return 'Business';
      case TemplateCategory.leisure:
        return 'Leisure';
      case TemplateCategory.adventure:
        return 'Adventure';
      case TemplateCategory.family:
        return 'Family';
      case TemplateCategory.romantic:
        return 'Romantic';
      case TemplateCategory.cultural:
        return 'Cultural';
      case TemplateCategory.beach:
        return 'Beach';
      case TemplateCategory.city:
        return 'City';
      case TemplateCategory.nature:
        return 'Nature';
      case TemplateCategory.foodie:
        return 'Foodie';
      case TemplateCategory.budget:
        return 'Budget';
      case TemplateCategory.luxury:
        return 'Luxury';
      case TemplateCategory.solo:
        return 'Solo';
      case TemplateCategory.group:
        return 'Group';
      case TemplateCategory.custom:
        return 'Custom';
    }
  }
}

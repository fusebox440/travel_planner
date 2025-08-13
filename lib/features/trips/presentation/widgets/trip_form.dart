import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/core/design/design_tokens.dart';
import 'package:travel_planner/features/trips/presentation/providers/trip_providers.dart';
import 'package:travel_planner/features/trips/presentation/widgets/location_result.dart';
import 'package:travel_planner/features/trips/presentation/widgets/map_picker.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/widgets/cover_image_picker.dart';
import 'package:uuid/uuid.dart';

class TripForm extends ConsumerStatefulWidget {
  final Trip? initialTrip;
  const TripForm({super.key, this.initialTrip});

  @override
  ConsumerState<TripForm> createState() => _TripFormState();
}

class _TripFormState extends ConsumerState<TripForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late DateTime _startDate;
  late DateTime _endDate;
  double? _selectedLat;
  double? _selectedLng;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    final trip = widget.initialTrip;
    _titleController = TextEditingController(text: trip?.title);
    _locationController = TextEditingController(text: trip?.locationName);
    _startDate = trip?.startDate ?? DateTime.now();
    _endDate = trip?.endDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedLat = trip?.locationLat;
    _selectedLng = trip?.locationLng;
    _imageUrl = trip?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact(); // Medium impact for success
      final isEditing = widget.initialTrip != null;
      final tripToSave = isEditing
          ? widget.initialTrip!.copyWith(
        title: _titleController.text,
        locationName: _locationController.text,
        locationLat: _selectedLat,
        locationLng: _selectedLng,
        startDate: _startDate,
        endDate: _endDate,
        lastModified: DateTime.now(),
        imageUrl: _imageUrl,
      )
          : Trip(
        id: const Uuid().v4(),
        title: _titleController.text,
        locationName: _locationController.text,
        locationLat: _selectedLat ?? 0,
        locationLng: _selectedLng ?? 0,
        startDate: _startDate,
        endDate: _endDate,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        days: HiveList(Hive.box<Day>('days')),
        imageUrl: _imageUrl,
        packingList: HiveList(Hive.box<PackingItem>('packing_items')),
      );
      try {
        if (isEditing) {
          await ref.read(tripListProvider.notifier).updateTrip(tripToSave);
          if (mounted) context.go('/trip/${tripToSave.id}');
        } else {
          await ref.read(tripListProvider.notifier).addTrip(tripToSave);
          if (mounted) context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save trip: $e')),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    HapticFeedback.lightImpact();
    final initialDate = isStartDate ? _startDate : _endDate;
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (newDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = newDate;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = newDate;
        }
      });
    }
  }

  void _pickOnMap() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(builder: (context) => const MapPicker()),
    );
    if (result != null) {
      setState(() {
        _locationController.text = result.name;
        _selectedLat = result.lat;
        _selectedLng = result.lng;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return SingleChildScrollView(
      padding: DesignTokens.spacingM,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CoverImagePicker(
              initialImageUrl: _imageUrl,
              onImageChanged: (newUrl) {
                setState(() {
                  _imageUrl = newUrl;
                });
              },
            ),
            SizedBox(height: DesignTokens.spacingM.top),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Trip Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a trip name.';
                }
                return null;
              },
            ),
            SizedBox(height: DesignTokens.spacingM.top),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location.';
                }
                return null;
              },
            ),
            SizedBox(height: DesignTokens.spacingS.top),
            ElevatedButton.icon(
              onPressed: _pickOnMap,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Pick on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            SizedBox(height: DesignTokens.spacingM.top),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Start Date'),
                      child: Text(dateFormat.format(_startDate)),
                    ),
                  ),
                ),
                SizedBox(width: DesignTokens.spacingS.left),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'End Date'),
                      child: Text(dateFormat.format(_endDate)),
                    ),
                  ),
                ),
              ],
            ),
            if (_endDate.isBefore(_startDate))
              Padding(
                padding: EdgeInsets.only(top: DesignTokens.spacingXS.top),
                child: Text(
                  'End date must be after start date.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            SizedBox(height: DesignTokens.spacingXL.top),
            ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                padding: DesignTokens.spacingM,
              ),
              child: Text(widget.initialTrip != null ? 'Save Changes' : 'Create Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
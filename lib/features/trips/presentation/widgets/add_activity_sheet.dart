import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/core/services/image_service.dart';
import 'package:travel_planner/features/trips/presentation/providers/trip_providers.dart';
import 'package:travel_planner/src/models/activity.dart';
import 'package:uuid/uuid.dart';

class AddActivitySheet extends ConsumerStatefulWidget {
  final String tripId;
  final String dayId;
  const AddActivitySheet({super.key, required this.tripId, required this.dayId});

  @override
  ConsumerState<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends ConsumerState<AddActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  // Store paths instead of files
  final List<String> _imagePaths = [];

  Future<void> _pickImage(ImageSource source) async {
    final imagePath = await ImageService().pickAndSaveImage(source);
    if (imagePath != null) {
      setState(() {
        _imagePaths.add(imagePath);
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final activity = Activity(
        id: const Uuid().v4(),
        title: _titleController.text,
        locationName: _locationController.text,
        startTime: DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute),
        endTime: DateTime(now.year, now.month, now.day, _selectedTime.hour + 1, _selectedTime.minute),
        imagePaths: _imagePaths,
      );
      ref.read(tripListProvider.notifier).addActivityToDay(widget.tripId, widget.dayId, activity);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add New Activity', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Activity Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location (Optional)'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Time'),
                trailing: Text(DateFormat.jm().format(DateTime(2023, 1, 1, _selectedTime.hour, _selectedTime.minute))),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _selectedTime);
                  if (time != null) setState(() => _selectedTime = time);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._imagePaths.map((path) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover),
                    )),
                    // Add buttons for camera and gallery
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      tooltip: 'Add from Gallery',
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () => _pickImage(ImageSource.camera),
                      tooltip: 'Take Photo',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onSave,
                child: const Text('Save Activity'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
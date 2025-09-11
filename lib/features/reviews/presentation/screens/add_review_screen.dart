import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_planner/core/design/app_spacing.dart';
import 'package:travel_planner/features/reviews/domain/models/review.dart';
import 'package:travel_planner/features/reviews/presentation/providers/review_provider.dart';

class AddReviewScreen extends ConsumerStatefulWidget {
  final String placeName;
  final String? tripId;

  const AddReviewScreen({
    super.key,
    required this.placeName,
    this.tripId,
  });

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  int _rating = 0;
  List<XFile> _selectedPhotos = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos({bool fromCamera = false}) async {
    final photos = await ref
        .read(reviewsStateProvider.notifier)
        .pickPhotos(fromCamera: fromCamera);
    setState(() {
      _selectedPhotos.addAll(photos);
    });
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate() || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final currentUser = ReviewUser(
      name: 'John Doe', // TODO: Get from auth service
    );

    await ref.read(reviewsStateProvider.notifier).addReview(
          placeName: widget.placeName,
          rating: _rating,
          text: _textController.text,
          tripId: widget.tripId,
          user: currentUser,
        );

    if (_selectedPhotos.isNotEmpty) {
      // TODO: Add photos to the review
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${widget.placeName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _submitReview,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.medium),
          children: [
            _buildRatingSelector(),
            SizedBox(height: AppSpacing.medium),
            _buildReviewField(),
            SizedBox(height: AppSpacing.medium),
            _buildPhotoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSpacing.small),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            return IconButton(
              icon: Icon(
                rating <= _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => setState(() => _rating = rating),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReviewField() {
    return TextFormField(
      controller: _textController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Review',
        hintText: 'Share your experience...',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your review';
        }
        return null;
      },
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: () => _pickPhotos(),
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () => _pickPhotos(fromCamera: true),
                ),
              ],
            ),
          ],
        ),
        if (_selectedPhotos.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.small),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedPhotos[index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _selectedPhotos.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

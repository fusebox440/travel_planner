import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_planner/core/services/image_service.dart';

class CoverImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final ValueChanged<String> onImageChanged;

  const CoverImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onImageChanged,
  });

  @override
  State<CoverImagePicker> createState() => _CoverImagePickerState();
}

class _CoverImagePickerState extends State<CoverImagePicker> {
  bool _isUploading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  Future<void> _pickImage() async {
    setState(() {
      _isUploading = true;
    });

    final newImagePath = await ImageService().pickAndSaveImage(ImageSource.gallery);

    if (newImagePath != null) {
      // If a new image was successfully picked and saved,
      // update the state and notify the parent widget.
      setState(() {
        _currentImageUrl = newImagePath;
      });
      widget.onImageChanged(newImagePath);
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use a placeholder if no image is available.
    final placeholder = Container(
      color: theme.colorScheme.secondaryContainer,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 50,
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The main image display
          SizedBox(
            height: 200,
            width: double.infinity,
            child: _currentImageUrl == null
                ? placeholder
                : _currentImageUrl!.startsWith('http')
                ? CachedNetworkImage( // For network images
              imageUrl: _currentImageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => placeholder,
              errorWidget: (context, url, error) => placeholder,
            )
                : Image.file( // For local file images
              File(_currentImageUrl!),
              fit: BoxFit.cover,
            ),
          ),
          // Bottom gradient for text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          // "Change Cover Image" button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: _isUploading ? null : _pickImage,
              icon: const Icon(Icons.edit_outlined),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
              tooltip: 'Change Cover Image',
            ),
          ),
          // Loading indicator
          if (_isUploading)
            const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class BookingFilters extends StatefulWidget {
  final Map<String, dynamic> activeFilters;
  final Function(Map<String, dynamic>) onFilterChanged;

  const BookingFilters({
    super.key,
    required this.activeFilters,
    required this.onFilterChanged,
  });

  @override
  State<BookingFilters> createState() => _BookingFiltersState();
}

class _BookingFiltersState extends State<BookingFilters> {
  RangeValues _priceRange = const RangeValues(0, 100000);
  double _rating = 0;
  List<String> _selectedAmenities = [];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    if (widget.activeFilters.containsKey('maxPrice')) {
      _priceRange = RangeValues(0, widget.activeFilters['maxPrice']);
    }
    if (widget.activeFilters.containsKey('minRating')) {
      _rating = widget.activeFilters['minRating'];
    }
    if (widget.activeFilters.containsKey('amenities')) {
      _selectedAmenities = List<String>.from(widget.activeFilters['amenities']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filters'),
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceRangeFilter(),
                  const SizedBox(height: 16),
                  _buildRatingFilter(),
                  const SizedBox(height: 16),
                  _buildAmenitiesFilter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          max: 100000,
          divisions: 100,
          labels: RangeLabels(
            _priceRange.start.round().toString(),
            _priceRange.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
            widget.onFilterChanged({
              ...widget.activeFilters,
              'minPrice': values.start,
              'maxPrice': values.end,
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('₹${_priceRange.start.round()}'),
            Text('₹${_priceRange.end.round()}'),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Rating',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _rating,
          max: 5,
          divisions: 10,
          label: _rating.toString(),
          onChanged: (double value) {
            setState(() {
              _rating = value;
            });
            widget.onFilterChanged({
              ...widget.activeFilters,
              'minRating': value,
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0'),
            Text(_rating.toStringAsFixed(1)),
            const Text('5'),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesFilter() {
    const amenities = [
      'WiFi',
      'Pool',
      'Spa',
      'Gym',
      'Restaurant',
      'Bar',
      'Parking',
      'Room Service',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: amenities.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedAmenities.add(amenity);
                  } else {
                    _selectedAmenities.remove(amenity);
                  }
                });
                widget.onFilterChanged({
                  ...widget.activeFilters,
                  'amenities': _selectedAmenities,
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

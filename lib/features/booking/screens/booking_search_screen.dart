import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_filters.dart';

class BookingSearchScreen extends ConsumerStatefulWidget {
  const BookingSearchScreen({super.key});

  @override
  ConsumerState<BookingSearchScreen> createState() =>
      _BookingSearchScreenState();
}

class _BookingSearchScreenState extends ConsumerState<BookingSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      ref.read(bookingSearchProvider.notifier).clearFilters();
    }
  }

  void _handleSearch(String query) {
    final notifier = ref.read(bookingSearchProvider.notifier);
    final now = DateTime.now();

    switch (_tabController.index) {
      case 0: // Flights
        notifier.searchFlights(
          origin: 'DEL', // TODO: Get from user input
          destination: query,
          departureDate: now.add(const Duration(days: 7)),
        );
        break;
      case 1: // Hotels
        notifier.searchHotels(
          location: query,
          checkIn: now.add(const Duration(days: 7)),
          checkOut: now.add(const Duration(days: 9)),
        );
        break;
      case 2: // Cars
        notifier.searchCars(
          location: query,
          pickupDate: now.add(const Duration(days: 7)),
          dropoffDate: now.add(const Duration(days: 9)),
        );
        break;
      case 3: // Activities
        notifier.searchActivities(
          location: query,
          date: now.add(const Duration(days: 7)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(bookingSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.flight), text: 'Flights'),
            Tab(icon: Icon(Icons.hotel), text: 'Hotels'),
            Tab(icon: Icon(Icons.directions_car), text: 'Cars'),
            Tab(icon: Icon(Icons.local_activity), text: 'Activities'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              onSubmitted: _handleSearch,
              hintText: 'Search destinations...',
              leading: const Icon(Icons.search),
            ),
          ),
          BookingFilters(
            activeFilters: searchState.activeFilters,
            onFilterChanged: (filters) {
              ref.read(bookingSearchProvider.notifier).updateFilters(filters);
              _handleSearch(_searchController.text);
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResultsList(searchState, BookingType.flight),
                _buildResultsList(searchState, BookingType.hotel),
                _buildResultsList(searchState, BookingType.car),
                _buildResultsList(searchState, BookingType.activity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BookingSearchState state, BookingType type) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text(
          'Error: ${state.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.searchResults.isEmpty) {
      return const Center(
        child: Text('No results found. Try adjusting your search.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final booking = state.searchResults[index];
        return BookingCard(
          booking: booking,
          onTap: () => Navigator.pushNamed(
            context,
            '/bookings/details',
            arguments: booking,
          ),
        );
      },
    );
  }
}

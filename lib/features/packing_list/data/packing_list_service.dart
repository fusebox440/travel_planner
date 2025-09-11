import 'package:hive/hive.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/packing_list.dart';
import 'package:travel_planner/src/models/item_category.dart';

class PackingListService {
  late final Box<PackingList> _packingListBox;

  PackingListService() {
    _packingListBox = Hive.box<PackingList>('packing_lists');
  }

  /// Creates a new packing list for a trip and populates it with suggestions.
  Future<PackingList> createAndSuggestPackingList({
    required String tripId,
    required TripType tripType,
    required int durationInDays,
    required Weather weather,
  }) async {
    final newList = PackingList.create(
      title: 'Packing List',
      tripId: tripId,
      tripType: tripType,
      durationInDays: durationInDays,
      weather: weather,
    );

    final suggestions = _generateSuggestions(newList);

    // Save individual items to the database
    for (final item in suggestions) {
      await item.save();
    }

    await _packingListBox.put(newList.id, newList);
    return newList;
  }

  Future<PackingList?> getPackingListForTrip(String tripId) async {
    return _packingListBox.values.firstWhere((list) => list.tripId == tripId,
        orElse: () => throw StateError('No element'));
  }

  Future<void> updatePackingList(PackingList list) async {
    await list.save();
  }

  Future<void> deletePackingList(String listId) async {
    await _packingListBox.delete(listId);
  }

  /// Generates a list of suggested PackingItems based on trip metadata.
  List<PackingItem> _generateSuggestions(PackingList metadata) {
    final suggestions = <PackingItem>[];

    // Documents (always needed)
    suggestions.add(PackingItem.create(
        title: 'Passport / ID',
        category: ItemCategory.Documents.name,
        quantity: 1));
    suggestions.add(PackingItem.create(
        title: 'Tickets / Boarding Pass',
        category: ItemCategory.Documents.name,
        quantity: 1));

    // Based on Trip Type
    if (metadata.tripType == TripType.business) {
      suggestions.add(PackingItem.create(
          title: 'Laptop & Charger',
          category: ItemCategory.Electronics.name,
          quantity: 1));
      suggestions.add(PackingItem.create(
          title: 'Formal Wear',
          category: ItemCategory.Clothing.name,
          quantity: 2));
    }
    if (metadata.tripType == TripType.leisure) {
      suggestions.add(PackingItem.create(
          title: 'Camera',
          category: ItemCategory.Electronics.name,
          quantity: 1));
      suggestions.add(PackingItem.create(
          title: 'Casual Outfits',
          category: ItemCategory.Clothing.name,
          quantity: 3));
    }

    // Based on Weather
    if (metadata.weather == Weather.hot) {
      suggestions.add(PackingItem.create(
          title: 'Sunscreen',
          category: ItemCategory.Toiletries.name,
          quantity: 1));
      suggestions.add(PackingItem.create(
          title: 'Swimwear',
          category: ItemCategory.Clothing.name,
          quantity: 1));
      suggestions.add(PackingItem.create(
          title: 'Sunglasses', category: ItemCategory.Other.name, quantity: 1));
    } else if (metadata.weather == Weather.cold) {
      suggestions.add(PackingItem.create(
          title: 'Heavy Jacket',
          category: ItemCategory.Clothing.name,
          quantity: 1));
      suggestions.add(PackingItem.create(
          title: 'Gloves & Scarf',
          category: ItemCategory.Clothing.name,
          quantity: 1));
    }

    // Based on Duration
    if (metadata.durationInDays >= 7) {
      suggestions.add(PackingItem.create(
          title: 'Extra Underwear & Socks',
          category: ItemCategory.Clothing.name,
          quantity: 5));
      suggestions.add(PackingItem.create(
          title: 'Basic Medications',
          category: ItemCategory.Medication.name,
          quantity: 1));
    }

    return suggestions;
  }
}

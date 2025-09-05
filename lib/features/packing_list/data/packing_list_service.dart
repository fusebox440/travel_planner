import 'package:hive/hive.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/packing_list.dart';

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
    required WeatherCondition weather,
  }) async {
    final newList = PackingList.create(
      tripId: tripId,
      tripType: tripType,
      durationInDays: durationInDays,
      weather: weather,
    );

    final suggestions = _generateSuggestions(newList);
    newList.items.addAll(suggestions);

    await _packingListBox.put(newList.id, newList);
    return newList;
  }

  Future<PackingList?> getPackingListForTrip(String tripId) async {
    return _packingListBox.values.firstWhere((list) => list.tripId == tripId, orElse: () => null);
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
    suggestions.add(PackingItem.create(name: 'Passport / ID', category: ItemCategory.Documents));
    suggestions.add(PackingItem.create(name: 'Tickets / Boarding Pass', category: ItemCategory.Documents));

    // Based on Trip Type
    if (metadata.tripType == TripType.Business) {
      suggestions.add(PackingItem.create(name: 'Laptop & Charger', category: ItemCategory.Electronics));
      suggestions.add(PackingItem.create(name: 'Formal Wear', category: ItemCategory.Clothing));
    }
    if (metadata.tripType == TripType.Leisure) {
      suggestions.add(PackingItem.create(name: 'Camera', category: ItemCategory.Electronics));
      suggestions.add(PackingItem.create(name: 'Casual Outfits', category: ItemCategory.Clothing));
    }

    // Based on Weather
    if (metadata.weather == WeatherCondition.Hot) {
      suggestions.add(PackingItem.create(name: 'Sunscreen', category: ItemCategory.Toiletries));
      suggestions.add(PackingItem.create(name: 'Swimwear', category: ItemCategory.Clothing));
      suggestions.add(PackingItem.create(name: 'Sunglasses', category: ItemCategory.Clothing));
    } else if (metadata.weather == WeatherCondition.Cold) {
      suggestions.add(PackingItem.create(name: 'Heavy Jacket', category: ItemCategory.Clothing));
      suggestions.add(PackingItem.create(name: 'Gloves & Scarf', category: ItemCategory.Clothing));
    }

    // Based on Duration
    if (metadata.durationInDays >= 7) {
      suggestions.add(PackingItem.create(name: 'Extra Underwear & Socks', category: ItemCategory.Clothing));
      suggestions.add(PackingItem.create(name: 'Basic Medications', category: ItemCategory.Medication));
    }

    return suggestions;
  }
}
import 'package:hive/hive.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/packing_list.dart';
import 'package:travel_planner/src/models/item_category.dart';

class PackingListService {
  late final Box<PackingList> _packingListBox;
  late final Box<PackingItem> _packingItemBox;
  bool _initialized = false;

  PackingListService._privateConstructor();
  static final PackingListService _instance =
      PackingListService._privateConstructor();
  factory PackingListService() => _instance;

  /// Initialize Hive boxes for packing lists and items
  Future<void> init() async {
    if (_initialized) return;

    _packingListBox = await Hive.openBox<PackingList>('packing_lists');
    _packingItemBox = await Hive.openBox<PackingItem>('packing_items');
    _initialized = true;
  }

  /// Safely get items for a packing list, ensuring boxes are initialized
  Future<List<PackingItem>> getItemsForListSafe(String packingListId) async {
    await init(); // Ensure boxes are open
    return getItemsForList(packingListId);
  }

  // For testing purposes
  void dispose() {
    _initialized = false;
  }

  /// Creates a new packing list for a trip and populates it with suggestions.
  Future<PackingList> createAndSuggestPackingList({
    required String tripId,
    required TripType tripType,
    required int durationInDays,
    required WeatherCondition weather,
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
    try {
      return _packingListBox.values.firstWhere(
        (list) => list.tripId == tripId,
      );
    } catch (e) {
      return null; // Return null when no packing list is found for the trip
    }
  }

  /// Creates a new packing list without suggestions
  Future<PackingList> createPackingList(PackingList list) async {
    await _packingListBox.put(list.id, list);
    return list;
  }

  /// Adds a single item to a packing list
  Future<void> addItem(String packingListId, PackingItem item) async {
    // Save the item first
    await _packingItemBox.put(item.id, item);

    // Update the packing list to include this item
    final packingList = _packingListBox.get(packingListId);
    if (packingList != null) {
      final updatedItemIds = [...packingList.itemIds, item.id];
      final updatedList = packingList.copyWith(itemIds: updatedItemIds);
      await _packingListBox.put(packingListId, updatedList);
    }
  }

  /// Gets all items for a specific packing list
  Future<List<PackingItem>> getItemsForList(String packingListId) async {
    final packingList = _packingListBox.get(packingListId);
    if (packingList == null) return [];

    final items = <PackingItem>[];
    for (final itemId in packingList.itemIds) {
      final item = _packingItemBox.get(itemId);
      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }

  /// Gets a specific item by ID
  Future<PackingItem?> getItem(String itemId) async {
    return _packingItemBox.get(itemId);
  }

  /// Marks an item as packed/unpacked
  Future<void> markItemPacked(String itemId, bool isPacked) async {
    final item = _packingItemBox.get(itemId);
    if (item != null) {
      final updatedItem = item.copyWith(isPacked: isPacked);
      await _packingItemBox.put(itemId, updatedItem);
    }
  }

  /// Removes an item from a packing list
  Future<void> removeItem(String itemId) async {
    // Delete the item from the items box
    await _packingItemBox.delete(itemId);

    // Update any packing lists that reference this item
    for (final packingList in _packingListBox.values) {
      if (packingList.itemIds.contains(itemId)) {
        final updatedItemIds =
            packingList.itemIds.where((id) => id != itemId).toList();
        final updatedList = packingList.copyWith(itemIds: updatedItemIds);
        await _packingListBox.put(packingList.id, updatedList);
      }
    }
  }

  /// Calculates the packing progress as a percentage
  Future<double> calculateProgress(String packingListId) async {
    final items = await getItemsForList(packingListId);
    if (items.isEmpty) return 0.0;

    final packedCount = items.where((item) => item.isPacked).length;
    return packedCount / items.length;
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
    if (metadata.weather == WeatherCondition.hot) {
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
    } else if (metadata.weather == WeatherCondition.cold) {
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

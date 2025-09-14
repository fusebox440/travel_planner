import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/packing_list/data/packing_list_service.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/packing_list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/mock/docs';
}

void main() {
  group('Packing List Tests', () {
    late Box<PackingList> packingListBox;
    late Box<PackingItem> packingItemBox;
    late PackingListService packingListService;

    setUpAll(() async {
      // Mock the path provider
      PathProviderPlatform.instance = MockPathProviderPlatform();

      await Hive.initFlutter();

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(PackingListAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(PackingItemAdapter());
      }
      if (!Hive.isAdapterRegistered(50)) {
        Hive.registerAdapter(TripTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(51)) {
        Hive.registerAdapter(WeatherConditionAdapter());
      }

      packingListBox = await Hive.openBox<PackingList>('test_packing_lists');
      packingItemBox = await Hive.openBox<PackingItem>('test_packing_items');
      packingListService = PackingListService();
      await packingListService.init();
    });

    setUp(() async {
      await packingListBox.clear();
      await packingItemBox.clear();
      // Reset the singleton for testing
      packingListService.dispose();
    });

    test('Create new packing list', () async {
      final packingList = PackingList.create(
        tripId: 'test_trip',
        title: 'Summer Packing List',
        tripType: TripType.leisure,
        durationInDays: 5,
        weather: WeatherCondition.hot,
      );

      await packingListService.createPackingList(packingList);

      final retrievedList =
          await packingListService.getPackingListForTrip('test_trip');
      expect(retrievedList, isNotNull);
      expect(retrievedList?.title, 'Summer Packing List');
    });

    test('Add items to packing list', () async {
      final packingList = PackingList.create(
        tripId: 'test_trip',
        title: 'Beach Trip List',
        tripType: TripType.leisure,
        durationInDays: 7,
        weather: WeatherCondition.hot,
      );

      await packingListService.createPackingList(packingList);

      final item1 = PackingItem.create(
        title: 'Sunscreen',
        category: 'Essentials',
        quantity: 1,
      );

      final item2 = PackingItem.create(
        title: 'Beach Towel',
        category: 'Beach Gear',
        quantity: 2,
      );

      await packingListService.addItem(packingList.id, item1);
      await packingListService.addItem(packingList.id, item2);

      final items = await packingListService.getItemsForList(packingList.id);
      expect(items.length, 2);
      expect(items.any((item) => item.title == 'Sunscreen'), true);
      expect(items.any((item) => item.title == 'Beach Towel'), true);
    });

    test('Mark item as packed', () async {
      final packingList = PackingList.create(
        tripId: 'test_trip',
        title: 'Trip List',
        tripType: TripType.business,
        durationInDays: 3,
        weather: WeatherCondition.mild,
      );

      await packingListService.createPackingList(packingList);

      final item = PackingItem.create(
        title: 'Passport',
        category: 'Documents',
        quantity: 1,
      );

      await packingListService.addItem(packingList.id, item);
      await packingListService.markItemPacked(item.id, true);

      final updatedItem = await packingListService.getItem(item.id);
      expect(updatedItem?.isPacked, true);
    });

    test('Calculate packing progress', () async {
      final packingList = PackingList.create(
        tripId: 'test_trip',
        title: 'Trip List',
        tripType: TripType.leisure,
        durationInDays: 5,
        weather: WeatherCondition.mild,
      );

      await packingListService.createPackingList(packingList);

      final items = [
        PackingItem.create(
          title: 'Item 1',
          category: 'Category 1',
          quantity: 1,
          isPacked: true,
        ),
        PackingItem.create(
          title: 'Item 2',
          category: 'Category 1',
          quantity: 1,
          isPacked: true,
        ),
        PackingItem.create(
          title: 'Item 3',
          category: 'Category 2',
          quantity: 1,
          isPacked: false,
        ),
      ];

      for (final item in items) {
        await packingListService.addItem(packingList.id, item);
      }

      final progress =
          await packingListService.calculateProgress(packingList.id);
      expect(progress, 0.6666666666666666); // 2 out of 3 items packed
    });

    test('Delete packing list item', () async {
      final packingList = PackingList.create(
        tripId: 'test_trip',
        title: 'Trip List',
        tripType: TripType.adventure,
        durationInDays: 10,
        weather: WeatherCondition.cold,
      );

      await packingListService.createPackingList(packingList);

      final item = PackingItem.create(
        title: 'To be deleted',
        category: 'Test',
        quantity: 1,
      );

      await packingListService.addItem(packingList.id, item);
      await packingListService.removeItem(item.id);

      final items = await packingListService.getItemsForList(packingList.id);
      expect(items.length, 0);
    });

    tearDownAll(() async {
      await packingListBox.deleteFromDisk();
      await packingItemBox.deleteFromDisk();
      packingListService.dispose();
    });
  });
}

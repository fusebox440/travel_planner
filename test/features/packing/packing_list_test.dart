import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/packing_list/data/packing_list_service.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/packing_list.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('Packing List Tests', () {
    late Box<PackingList> packingListBox;
    late Box<PackingItem> packingItemBox;
    late PackingListService packingListService;

    setUpAll(() async {
      await Hive.initFlutter();
      Hive.registerAdapter(PackingListAdapter());
      Hive.registerAdapter(PackingItemAdapter());
      packingListBox = await Hive.openBox<PackingList>('test_packing_lists');
      packingItemBox = await Hive.openBox<PackingItem>('test_packing_items');
      packingListService = await PackingListService.getInstance();
    });

    setUp(() async {
      await packingListBox.clear();
      await packingItemBox.clear();
    });

    test('Create new packing list', () async {
      final packingList = PackingList.create(
        tripId: 'test_trip',
        title: 'Summer Packing List',
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

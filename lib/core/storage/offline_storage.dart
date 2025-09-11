import 'package:hive_flutter/hive_flutter.dart';
import 'package:travel_planner/core/error/error_handler.dart';

class OfflineStorage {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters for your models here
    // Hive.registerAdapter(TripAdapter());
    // Hive.registerAdapter(ExpenseAdapter());
    // etc.
  }

  static Future<Box<T>> openBox<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      }
      return await Hive.openBox<T>(boxName);
    } catch (e, stackTrace) {
      AppErrorHandler.handleError(e, stackTrace);
      rethrow;
    }
  }

  static Future<void> clearBox(String boxName) async {
    final box = await openBox(boxName);
    await box.clear();
  }

  static Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }

  static Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      await box.compact();
      await box.close();
    }
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }
}

// Base repository class for offline-first data access
abstract class BaseRepository<T> {
  final String boxName;
  late Box<T> _box;

  BaseRepository(this.boxName);

  Future<void> initialize() async {
    _box = await OfflineStorage.openBox<T>(boxName);
  }

  Future<void> add(String key, T item) async {
    await _box.put(key, item);
  }

  Future<void> update(String key, T item) async {
    await _box.put(key, item);
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  T? get(String key) {
    return _box.get(key);
  }

  List<T> getAll() {
    return _box.values.toList();
  }

  Stream<BoxEvent> watch(String key) {
    return _box.watch(key: key);
  }

  Future<void> close() async {
    await OfflineStorage.closeBox(boxName);
  }
}

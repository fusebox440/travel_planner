import 'package:hive/hive.dart';
import 'package:travel_planner/features/trip_templates/domain/models/trip_template.dart';

/// Initialize the Hive adapters for Trip Templates
class TripTemplateHiveAdapters {
  static void registerAdapters() {
    // Register template-related type adapters
    if (!Hive.isAdapterRegistered(41)) {
      Hive.registerAdapter(TripTemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(42)) {
      Hive.registerAdapter(TemplateCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(43)) {
      Hive.registerAdapter(TemplateDayStructureAdapter());
    }
    if (!Hive.isAdapterRegistered(44)) {
      Hive.registerAdapter(TemplateActivityItemAdapter());
    }
    if (!Hive.isAdapterRegistered(45)) {
      Hive.registerAdapter(TemplateCompanionAdapter());
    }
    if (!Hive.isAdapterRegistered(46)) {
      Hive.registerAdapter(TemplatePackingItemAdapter());
    }
  }
}

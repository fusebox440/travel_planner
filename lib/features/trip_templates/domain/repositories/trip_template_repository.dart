import '../models/trip_template.dart';

abstract class TripTemplateRepository {
  Future<List<TripTemplate>> getAllTemplates();
  Future<TripTemplate?> getTemplateById(String id);
  Future<List<TripTemplate>> getTemplatesByCategory(TemplateCategory category);
  Future<List<TripTemplate>> searchTemplates(String query);
  Future<List<TripTemplate>> getPopularTemplates();
  Future<List<TripTemplate>> getMyTemplates(String userId);
  Future<List<TripTemplate>> getOfficialTemplates();
  Future<void> saveTemplate(TripTemplate template);
  Future<void> updateTemplate(TripTemplate template);
  Future<void> deleteTemplate(String id);
  Future<void> incrementUsageCount(String id);
  Future<void> rateTemplate(String id, double rating);
  Future<TripTemplate> createTemplateFromTrip(String tripId);
  Future<void> clearCache();
}

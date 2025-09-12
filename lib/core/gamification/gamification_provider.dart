import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/gamification/gamification.dart';

/// Provider for managing gamification state
class GamificationState {
  final List<Badge> unlockedBadges;
  final Map<String, int> progressCounters;
  final bool showCelebration;
  final Badge? celebratingBadge;

  const GamificationState({
    this.unlockedBadges = const [],
    this.progressCounters = const {},
    this.showCelebration = false,
    this.celebratingBadge,
  });

  GamificationState copyWith({
    List<Badge>? unlockedBadges,
    Map<String, int>? progressCounters,
    bool? showCelebration,
    Badge? celebratingBadge,
  }) {
    return GamificationState(
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      progressCounters: progressCounters ?? this.progressCounters,
      showCelebration: showCelebration ?? this.showCelebration,
      celebratingBadge: celebratingBadge ?? this.celebratingBadge,
    );
  }
}

/// Notifier for managing gamification logic
class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(const GamificationState()) {
    _initializeCounters();
  }

  void _initializeCounters() {
    state = state.copyWith(
      progressCounters: {
        'trips_created': 0,
        'packing_lists_completed': 0,
        'reviews_written': 0,
        'maps_used': 0,
        'weather_checked': 0,
        'places_visited': 0,
        'features_used': <String>{}.length,
      },
    );
  }

  /// Track when user creates a trip
  void trackTripCreated() {
    final newCount = (state.progressCounters['trips_created'] ?? 0) + 1;
    _updateCounter('trips_created', newCount);

    if (newCount == 1) {
      _unlockBadge(BadgeType.firstTrip);
    }
  }

  /// Track when user completes a packing list
  void trackPackingListCompleted() {
    final newCount =
        (state.progressCounters['packing_lists_completed'] ?? 0) + 1;
    _updateCounter('packing_lists_completed', newCount);

    if (newCount == 5) {
      _unlockBadge(BadgeType.packingMaster);
    }
  }

  /// Track when user writes a review
  void trackReviewWritten() {
    final newCount = (state.progressCounters['reviews_written'] ?? 0) + 1;
    _updateCounter('reviews_written', newCount);

    if (newCount == 10) {
      _unlockBadge(BadgeType.reviewer);
    }
  }

  /// Track when user uses maps feature
  void trackMapsUsed() {
    final newCount = (state.progressCounters['maps_used'] ?? 0) + 1;
    _updateCounter('maps_used', newCount);

    if (newCount == 50) {
      _unlockBadge(BadgeType.explorer);
    }
  }

  /// Track when user checks weather
  void trackWeatherChecked() {
    final newCount = (state.progressCounters['weather_checked'] ?? 0) + 1;
    _updateCounter('weather_checked', newCount);

    if (newCount == 25) {
      _unlockBadge(BadgeType.weatherWatcher);
    }
  }

  /// Track when user visits a place
  void trackPlaceVisited() {
    final newCount = (state.progressCounters['places_visited'] ?? 0) + 1;
    _updateCounter('places_visited', newCount);

    if (newCount == 10) {
      _unlockBadge(BadgeType.adventurer);
    }
  }

  /// Track early planning (30+ days in advance)
  void trackEarlyPlanning() {
    if (!isBadgeUnlocked(BadgeType.earlyBird)) {
      _unlockBadge(BadgeType.earlyBird);
    }
  }

  /// Track when user uses all features in one trip
  void trackFeatureUsed(String feature) {
    // This would be called when user uses different features
    // Implementation depends on your feature tracking needs
  }

  /// Check if all features have been used
  void checkSuperOrganizerBadge(Set<String> usedFeatures) {
    final requiredFeatures = {
      'packing',
      'weather',
      'maps',
      'reviews',
      'currency',
    };

    if (usedFeatures.containsAll(requiredFeatures) &&
        !isBadgeUnlocked(BadgeType.organizer)) {
      _unlockBadge(BadgeType.organizer);
    }
  }

  void _updateCounter(String key, int value) {
    final newCounters = Map<String, int>.from(state.progressCounters);
    newCounters[key] = value;
    state = state.copyWith(progressCounters: newCounters);
  }

  void _unlockBadge(BadgeType badgeType) {
    // Check if already unlocked
    if (isBadgeUnlocked(badgeType)) return;

    final newBadge = Badge.fromType(
      badgeType,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    final newBadges = List<Badge>.from(state.unlockedBadges)..add(newBadge);

    state = state.copyWith(
      unlockedBadges: newBadges,
      showCelebration: true,
      celebratingBadge: newBadge,
    );
  }

  /// Check if a specific badge is unlocked
  bool isBadgeUnlocked(BadgeType badgeType) {
    return state.unlockedBadges.any((badge) => badge.type == badgeType);
  }

  /// Get all available badges with their unlock status
  List<Badge> getAllBadges() {
    return BadgeType.values.map((type) {
      final unlockedBadge =
          state.unlockedBadges.where((badge) => badge.type == type).firstOrNull;

      if (unlockedBadge != null) {
        return unlockedBadge;
      }

      return Badge.fromType(type, isUnlocked: false);
    }).toList();
  }

  /// Get progress towards specific badge
  double getBadgeProgress(BadgeType badgeType) {
    switch (badgeType) {
      case BadgeType.firstTrip:
        return (state.progressCounters['trips_created'] ?? 0) / 1.0;
      case BadgeType.packingMaster:
        return (state.progressCounters['packing_lists_completed'] ?? 0) / 5.0;
      case BadgeType.reviewer:
        return (state.progressCounters['reviews_written'] ?? 0) / 10.0;
      case BadgeType.explorer:
        return (state.progressCounters['maps_used'] ?? 0) / 50.0;
      case BadgeType.weatherWatcher:
        return (state.progressCounters['weather_checked'] ?? 0) / 25.0;
      case BadgeType.adventurer:
        return (state.progressCounters['places_visited'] ?? 0) / 10.0;
      case BadgeType.earlyBird:
      case BadgeType.organizer:
        return isBadgeUnlocked(badgeType) ? 1.0 : 0.0;
    }
  }

  /// Clear celebration state
  void clearCelebration() {
    state = state.copyWith(
      showCelebration: false,
      celebratingBadge: null,
    );
  }

  /// Get user's total score based on achievements
  int getTotalScore() {
    int score = 0;
    for (final badge in state.unlockedBadges) {
      switch (badge.type) {
        case BadgeType.firstTrip:
          score += 10;
        case BadgeType.packingMaster:
          score += 50;
        case BadgeType.earlyBird:
          score += 30;
        case BadgeType.adventurer:
          score += 100;
        case BadgeType.reviewer:
          score += 60;
        case BadgeType.organizer:
          score += 80;
        case BadgeType.explorer:
          score += 70;
        case BadgeType.weatherWatcher:
          score += 40;
      }
    }

    // Add bonus points for progress
    score += (state.progressCounters['trips_created'] ?? 0) * 2;
    score += (state.progressCounters['packing_lists_completed'] ?? 0) * 5;
    score += (state.progressCounters['reviews_written'] ?? 0) * 3;

    return score;
  }

  /// Get user level based on score
  int getUserLevel() {
    final score = getTotalScore();
    if (score < 50) return 1;
    if (score < 150) return 2;
    if (score < 300) return 3;
    if (score < 500) return 4;
    return 5;
  }

  /// Get level progress (0.0 to 1.0)
  double getLevelProgress() {
    final score = getTotalScore();
    final level = getUserLevel();

    switch (level) {
      case 1:
        return (score / 50.0).clamp(0.0, 1.0);
      case 2:
        return ((score - 50) / 100.0).clamp(0.0, 1.0);
      case 3:
        return ((score - 150) / 150.0).clamp(0.0, 1.0);
      case 4:
        return ((score - 300) / 200.0).clamp(0.0, 1.0);
      case 5:
        return 1.0;
      default:
        return 0.0;
    }
  }

  /// Get level title
  String getLevelTitle() {
    switch (getUserLevel()) {
      case 1:
        return 'Travel Newbie 🌱';
      case 2:
        return 'Journey Explorer 🚀';
      case 3:
        return 'Adventure Seeker 🎒';
      case 4:
        return 'Travel Master ⭐';
      case 5:
        return 'Globe Trotter Legend 👑';
      default:
        return 'Traveler';
    }
  }
}

/// Provider for gamification state
final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier();
});

/// Provider for getting all badges
final allBadgesProvider = Provider<List<Badge>>((ref) {
  final gamification = ref.watch(gamificationProvider.notifier);
  return gamification.getAllBadges();
});

/// Provider for getting unlocked badges count
final unlockedBadgesCountProvider = Provider<int>((ref) {
  final state = ref.watch(gamificationProvider);
  return state.unlockedBadges.length;
});

/// Provider for getting user level info
final userLevelProvider = Provider<Map<String, dynamic>>((ref) {
  final gamification = ref.watch(gamificationProvider.notifier);
  return {
    'level': gamification.getUserLevel(),
    'title': gamification.getLevelTitle(),
    'score': gamification.getTotalScore(),
    'progress': gamification.getLevelProgress(),
  };
});

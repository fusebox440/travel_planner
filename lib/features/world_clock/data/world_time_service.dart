import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class WorldTimeService {
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  DateTime getTimeForZone(String timeZone) {
    final location = tz.getLocation(timeZone);
    return tz.TZDateTime.now(location);
  }

  Duration getOffset(String timeZone) {
    final location = tz.getLocation(timeZone);
    final offset = location.currentTimeZone.offset;
    return Duration(milliseconds: offset);
  }

  String formatOffset(Duration offset) {
    final hours = offset.inHours;
    final minutes = (offset.inMinutes % 60).abs();
    final sign = hours >= 0 ? '+' : '-';
    return '$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  List<String> getCommonTimeZones() {
    return [
      'America/New_York',
      'America/Los_Angeles',
      'Europe/London',
      'Europe/Paris',
      'Asia/Tokyo',
      'Asia/Dubai',
      'Australia/Sydney',
      'Pacific/Auckland',
    ];
  }

  bool isDaytime(DateTime time) {
    final hour = time.hour;
    return hour >= 6 && hour < 18;
  }
}

final worldTimeServiceProvider = Provider<WorldTimeService>((ref) {
  final service = WorldTimeService();
  service.init();
  return service;
});

class WorldTimeState {
  final Map<String, DateTime> times;
  final bool isLoading;
  final String? error;
  final List<String> selectedZones;

  const WorldTimeState({
    this.times = const {},
    this.isLoading = false,
    this.error,
    this.selectedZones = const [],
  });

  WorldTimeState copyWith({
    Map<String, DateTime>? times,
    bool? isLoading,
    String? error,
    List<String>? selectedZones,
  }) {
    return WorldTimeState(
      times: times ?? this.times,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedZones: selectedZones ?? this.selectedZones,
    );
  }
}

class WorldTimeNotifier extends StateNotifier<WorldTimeState> {
  final WorldTimeService _service;
  Timer? _timer;

  WorldTimeNotifier(this._service) : super(const WorldTimeState()) {
    _initializeDefaultZones();
    _startTimer();
  }

  void _initializeDefaultZones() {
    final defaultZones = _service.getCommonTimeZones().take(3).toList();
    addTimeZones(defaultZones);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimes();
    });
  }

  void _updateTimes() {
    if (state.selectedZones.isEmpty) return;

    final updatedTimes = <String, DateTime>{};
    for (final zone in state.selectedZones) {
      try {
        updatedTimes[zone] = _service.getTimeForZone(zone);
      } catch (e) {
        state = state.copyWith(error: 'Failed to update time for $zone');
      }
    }

    state = state.copyWith(times: updatedTimes);
  }

  void addTimeZone(String timeZone) {
    if (state.selectedZones.contains(timeZone)) return;

    try {
      final time = _service.getTimeForZone(timeZone);
      state = state.copyWith(
        selectedZones: [...state.selectedZones, timeZone],
        times: {...state.times, timeZone: time},
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to add timezone: $e');
    }
  }

  void addTimeZones(List<String> timeZones) {
    for (final zone in timeZones) {
      addTimeZone(zone);
    }
  }

  void removeTimeZone(String timeZone) {
    final updatedZones = [...state.selectedZones]..remove(timeZone);
    final updatedTimes = Map<String, DateTime>.from(state.times)
      ..remove(timeZone);

    state = state.copyWith(
      selectedZones: updatedZones,
      times: updatedTimes,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final worldTimeProvider =
    StateNotifierProvider<WorldTimeNotifier, WorldTimeState>((ref) {
  final service = ref.watch(worldTimeServiceProvider);
  return WorldTimeNotifier(service);
});

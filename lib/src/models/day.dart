import 'package:hive/hive.dart';
import 'package:travel_planner/src/models/activity.dart';

part 'day.g.dart';

@HiveType(typeId: 1)
class Day extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final HiveList<Activity> activities;

  Day({
    required this.id,
    required this.date,
    required this.activities,
  });

  Day copyWith({
    DateTime? date,
    HiveList<Activity>? activities,
  }) {
    return Day(
      id: id,
      date: date ?? this.date,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'activities': activities.map((activity) => activity.toJson()).toList(),
    };
  }

  factory Day.fromJson(Map<String, dynamic> json) {
    final activities = (json['activities'] as List)
        .map((activityJson) => Activity.fromJson(activityJson as Map<String, dynamic>))
        .toList();

    final activityBox = Hive.box<Activity>('activities');
    final hiveList = HiveList<Activity>(activityBox); // Explicitly typed
    hiveList.addAll(activities);

    return Day(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      activities: hiveList,
    );
  }
}
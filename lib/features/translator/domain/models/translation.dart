import 'package:hive/hive.dart';

part 'translation.g.dart';

@HiveType(typeId: 39)
class Translation extends HiveObject {
  @HiveField(0)
  final String sourceText;

  @HiveField(1)
  final String translatedText;

  @HiveField(2)
  final String fromLanguage;

  @HiveField(3)
  final String toLanguage;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isFavorite;

  Translation({
    required this.sourceText,
    required this.translatedText,
    required this.fromLanguage,
    required this.toLanguage,
    required this.timestamp,
    this.isFavorite = false,
  });

  Translation copyWith({
    String? sourceText,
    String? translatedText,
    String? fromLanguage,
    String? toLanguage,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return Translation(
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      fromLanguage: fromLanguage ?? this.fromLanguage,
      toLanguage: toLanguage ?? this.toLanguage,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'sourceText': sourceText,
        'translatedText': translatedText,
        'fromLanguage': fromLanguage,
        'toLanguage': toLanguage,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
        sourceText: json['sourceText'],
        translatedText: json['translatedText'],
        fromLanguage: json['fromLanguage'],
        toLanguage: json['toLanguage'],
        timestamp: DateTime.parse(json['timestamp']),
        isFavorite: json['isFavorite'] ?? false,
      );

  @override
  String toString() {
    return 'Translation(sourceText: $sourceText, translatedText: $translatedText, fromLanguage: $fromLanguage, toLanguage: $toLanguage, timestamp: $timestamp, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Translation &&
        other.sourceText == sourceText &&
        other.translatedText == translatedText &&
        other.fromLanguage == fromLanguage &&
        other.toLanguage == toLanguage &&
        other.timestamp == timestamp &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return sourceText.hashCode ^
        translatedText.hashCode ^
        fromLanguage.hashCode ^
        toLanguage.hashCode ^
        timestamp.hashCode ^
        isFavorite.hashCode;
  }
}

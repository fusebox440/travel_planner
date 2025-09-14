import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'packing_item.g.dart';

@HiveType(typeId: 3) // Core models range 0-9
class PackingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final bool isPacked;

  // Getters for screen compatibility
  String get name => title; // Alias for backward compatibility
  bool get isChecked => isPacked; // Alias for backward compatibility

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  PackingItem({
    required this.id,
    required this.title,
    required this.category,
    required this.quantity,
    required this.isPacked,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackingItem.create({
    required String title,
    required String category,
    required int quantity,
    bool isPacked = false,
    String? notes,
  }) {
    final now = DateTime.now();
    return PackingItem(
      id: const Uuid().v4(),
      title: title,
      category: category,
      quantity: quantity,
      isPacked: isPacked,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  PackingItem copyWith({
    String? title,
    String? category,
    int? quantity,
    bool? isPacked,
    String? notes,
  }) {
    return PackingItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isPacked: isPacked ?? this.isPacked,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'quantity': quantity,
      'isPacked': isPacked,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      quantity: json['quantity'],
      isPacked: json['isPacked'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

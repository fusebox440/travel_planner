import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

@HiveType(typeId: 24) // Enum range 20-29
enum ExpenseCategory {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  accommodation,
  @HiveField(3)
  entertainment,
  @HiveField(4)
  shopping,
  @HiveField(5)
  other,
}

@HiveType(typeId: 6) // Core models range 0-9
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tripId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String currency;

  @HiveField(4)
  final ExpenseCategory category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final String title;

  @HiveField(8)
  final String payerId;

  @HiveField(9)
  final List<String> splitWithIds;

  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    required this.payerId,
    required this.splitWithIds,
    this.note,
  });

  factory Expense.create({
    required String tripId,
    required String title,
    required double amount,
    required String currency,
    required ExpenseCategory category,
    required String payerId,
    required List<String> splitWithIds,
    String? note,
  }) {
    return Expense(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      amount: amount,
      currency: currency,
      category: category,
      payerId: payerId,
      splitWithIds: splitWithIds,
      date: DateTime.now(),
      note: note,
    );
  }

  Expense copyWith({
    String? tripId,
    String? title,
    double? amount,
    String? currency,
    ExpenseCategory? category,
    DateTime? date,
    String? payerId,
    List<String>? splitWithIds,
    String? note,
  }) {
    return Expense(
      id: id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      payerId: payerId ?? this.payerId,
      splitWithIds: splitWithIds ?? this.splitWithIds,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category.toString().split('.').last,
      'date': date.toIso8601String(),
      'payerId': payerId,
      'splitWithIds': splitWithIds,
      'note': note,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      category: ExpenseCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      date: DateTime.parse(json['date'] as String),
      payerId: json['payerId'] as String,
      splitWithIds: (json['splitWithIds'] as List).cast<String>(),
      note: json['note'] as String?,
    );
  }
}

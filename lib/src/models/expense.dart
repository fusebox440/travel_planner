import 'package:hive/hive.dart';

part 'expense.g.dart';

// We need to create an adapter for the enum as well.
@HiveType(typeId: 10) // Use a high typeId to avoid conflicts
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

@HiveType(typeId: 3)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  // This links the expense back to the trip.
  @HiveField(1)
  final String tripId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String currency; // e.g., "USD", "EUR"

  @HiveField(4)
  final ExpenseCategory category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? note; // Optional field

  Expense({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.note,
  });

  Expense copyWith({
    String? tripId,
    double? amount,
    String? currency,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id,
      tripId: tripId ?? this.tripId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'amount': amount,
      'currency': currency,
      'category': category.toString().split('.').last,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
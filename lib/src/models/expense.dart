import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

@HiveType(typeId: 26) // Enum range 20-29
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
  healthcare,
  @HiveField(6)
  education,
  @HiveField(7)
  business,
  @HiveField(8)
  utilities,
  @HiveField(9)
  insurance,
  @HiveField(10)
  communication,
  @HiveField(11)
  emergencies,
  @HiveField(12)
  gifts,
  @HiveField(13)
  fees,
  @HiveField(14)
  custom,
  @HiveField(15)
  other,
}

@HiveType(typeId: 35) // New enum for sub-categories
enum ExpenseSubCategory {
  // Food sub-categories
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snacks,
  @HiveField(4)
  drinks,
  @HiveField(5)
  groceries,
  @HiveField(6)
  fastFood,
  @HiveField(7)
  fineDining,

  // Transport sub-categories
  @HiveField(8)
  flights,
  @HiveField(9)
  trains,
  @HiveField(10)
  buses,
  @HiveField(11)
  taxis,
  @HiveField(12)
  rideshare,
  @HiveField(13)
  carRental,
  @HiveField(14)
  fuel,
  @HiveField(15)
  parking,
  @HiveField(16)
  tolls,

  // Accommodation sub-categories
  @HiveField(17)
  hotels,
  @HiveField(18)
  hostels,
  @HiveField(19)
  airbnb,
  @HiveField(20)
  camping,
  @HiveField(21)
  resorts,

  // Entertainment sub-categories
  @HiveField(22)
  movies,
  @HiveField(23)
  concerts,
  @HiveField(24)
  sports,
  @HiveField(25)
  nightlife,
  @HiveField(26)
  tours,
  @HiveField(27)
  activities,
  @HiveField(28)
  museums,
  @HiveField(29)
  amusementParks,

  // Shopping sub-categories
  @HiveField(30)
  clothing,
  @HiveField(31)
  electronics,
  @HiveField(32)
  souvenirs,
  @HiveField(33)
  books,
  @HiveField(34)
  personalCare,

  // Healthcare sub-categories
  @HiveField(35)
  pharmacy,
  @HiveField(36)
  doctorVisit,
  @HiveField(37)
  hospital,
  @HiveField(38)
  dental,
  @HiveField(39)
  emergency,

  // Business sub-categories
  @HiveField(40)
  meetings,
  @HiveField(41)
  supplies,
  @HiveField(42)
  networking,
  @HiveField(43)
  conferences,

  // General
  @HiveField(44)
  none,
  @HiveField(45)
  customSubCategory,
}

@HiveType(typeId: 38) // Payment method enum
enum PaymentMethod {
  @HiveField(0)
  cash,
  @HiveField(1)
  creditCard,
  @HiveField(2)
  debitCard,
  @HiveField(3)
  digitalWallet,
  @HiveField(4)
  bankTransfer,
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

  @HiveField(10)
  final ExpenseSubCategory? subCategory;

  @HiveField(11)
  final String? merchant;

  @HiveField(12)
  final String? geolocation;

  @HiveField(13)
  final List<String>? receiptIds;

  @HiveField(14)
  final List<String>? tags;

  @HiveField(15)
  final Map<String, dynamic>? metadata;

  @HiveField(16)
  final bool isRecurring;

  @HiveField(17)
  final String? recurringPattern;

  @HiveField(18)
  final DateTime? recurringEndDate;

  @HiveField(19)
  final double? taxAmount;

  @HiveField(20)
  final double? tipAmount;

  @HiveField(21)
  final PaymentMethod? paymentMethod;

  @HiveField(22)
  final String? voiceNoteId;

  @HiveField(23)
  final String? description;

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
    this.subCategory,
    this.merchant,
    this.geolocation,
    this.receiptIds,
    this.tags,
    this.metadata,
    this.isRecurring = false,
    this.recurringPattern,
    this.recurringEndDate,
    this.taxAmount,
    this.tipAmount,
    this.paymentMethod,
    this.voiceNoteId,
    this.description,
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
    ExpenseSubCategory? subCategory,
    String? merchant,
    String? geolocation,
    List<String>? receiptIds,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool isRecurring = false,
    String? recurringPattern,
    DateTime? recurringEndDate,
    double? taxAmount,
    double? tipAmount,
    PaymentMethod? paymentMethod,
    String? voiceNoteId,
    String? description,
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
      subCategory: subCategory,
      merchant: merchant,
      geolocation: geolocation,
      receiptIds: receiptIds,
      tags: tags,
      metadata: metadata,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
      recurringEndDate: recurringEndDate,
      taxAmount: taxAmount,
      tipAmount: tipAmount,
      paymentMethod: paymentMethod,
      voiceNoteId: voiceNoteId,
      description: description,
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
    ExpenseSubCategory? subCategory,
    String? merchant,
    String? geolocation,
    List<String>? receiptIds,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isRecurring,
    String? recurringPattern,
    DateTime? recurringEndDate,
    double? taxAmount,
    double? tipAmount,
    PaymentMethod? paymentMethod,
    String? voiceNoteId,
    String? description,
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
      subCategory: subCategory ?? this.subCategory,
      merchant: merchant ?? this.merchant,
      geolocation: geolocation ?? this.geolocation,
      receiptIds: receiptIds ?? this.receiptIds,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      taxAmount: taxAmount ?? this.taxAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      voiceNoteId: voiceNoteId ?? this.voiceNoteId,
      description: description ?? this.description,
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

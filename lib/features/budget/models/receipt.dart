import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'receipt.g.dart';

@HiveType(typeId: 36) // Receipt model
class Receipt extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String expenseId;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final String? extractedText;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final Map<String, dynamic>? ocrData;

  @HiveField(6)
  final String? merchant;

  @HiveField(7)
  final double? extractedAmount;

  @HiveField(8)
  final DateTime? extractedDate;

  @HiveField(9)
  final String? extractedCurrency;

  @HiveField(10)
  final ReceiptStatus status;

  @HiveField(11)
  final double? confidence;

  @HiveField(12)
  final String? geolocation;

  Receipt({
    required this.id,
    required this.expenseId,
    required this.imagePath,
    required this.createdAt,
    required this.status,
    this.extractedText,
    this.ocrData,
    this.merchant,
    this.extractedAmount,
    this.extractedDate,
    this.extractedCurrency,
    this.confidence,
    this.geolocation,
  });

  factory Receipt.create({
    required String expenseId,
    required String imagePath,
    String? geolocation,
  }) {
    return Receipt(
      id: const Uuid().v4(),
      expenseId: expenseId,
      imagePath: imagePath,
      createdAt: DateTime.now(),
      status: ReceiptStatus.processing,
      geolocation: geolocation,
    );
  }

  Receipt copyWith({
    String? extractedText,
    Map<String, dynamic>? ocrData,
    String? merchant,
    double? extractedAmount,
    DateTime? extractedDate,
    String? extractedCurrency,
    ReceiptStatus? status,
    double? confidence,
    String? geolocation,
  }) {
    return Receipt(
      id: id,
      expenseId: expenseId,
      imagePath: imagePath,
      createdAt: createdAt,
      extractedText: extractedText ?? this.extractedText,
      ocrData: ocrData ?? this.ocrData,
      merchant: merchant ?? this.merchant,
      extractedAmount: extractedAmount ?? this.extractedAmount,
      extractedDate: extractedDate ?? this.extractedDate,
      extractedCurrency: extractedCurrency ?? this.extractedCurrency,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      geolocation: geolocation ?? this.geolocation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseId': expenseId,
      'imagePath': imagePath,
      'extractedText': extractedText,
      'createdAt': createdAt.toIso8601String(),
      'ocrData': ocrData,
      'merchant': merchant,
      'extractedAmount': extractedAmount,
      'extractedDate': extractedDate?.toIso8601String(),
      'extractedCurrency': extractedCurrency,
      'status': status.toString().split('.').last,
      'confidence': confidence,
      'geolocation': geolocation,
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      expenseId: json['expenseId'] as String,
      imagePath: json['imagePath'] as String,
      extractedText: json['extractedText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      ocrData: json['ocrData'] as Map<String, dynamic>?,
      merchant: json['merchant'] as String?,
      extractedAmount: (json['extractedAmount'] as num?)?.toDouble(),
      extractedDate: json['extractedDate'] != null
          ? DateTime.parse(json['extractedDate'] as String)
          : null,
      extractedCurrency: json['extractedCurrency'] as String?,
      status: ReceiptStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      confidence: (json['confidence'] as num?)?.toDouble(),
      geolocation: json['geolocation'] as String?,
    );
  }
}

@HiveType(typeId: 37) // Receipt status enum
enum ReceiptStatus {
  @HiveField(0)
  processing,
  @HiveField(1)
  completed,
  @HiveField(2)
  failed,
  @HiveField(3)
  manual,
}

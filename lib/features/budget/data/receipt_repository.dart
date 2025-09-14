import 'package:hive/hive.dart';
import '../models/receipt.dart';
import '../services/ocr_service.dart';

abstract class ReceiptRepository {
  Future<Receipt> createReceipt({
    required String expenseId,
    required String imagePath,
    String? geolocation,
  });

  Future<Receipt?> getReceiptById(String id);
  Future<List<Receipt>> getReceiptsByExpenseId(String expenseId);
  Future<List<Receipt>> getAllReceipts();

  Future<Receipt> updateReceipt(Receipt receipt);
  Future<bool> deleteReceipt(String id);

  Future<Receipt> processReceiptOCR(Receipt receipt);

  Future<void> clearAll();
}

class HiveReceiptRepository implements ReceiptRepository {
  static const String _boxName = 'receipts';
  late final Box<Receipt> _box;
  final OCRService _ocrService;

  HiveReceiptRepository({OCRService? ocrService})
      : _ocrService = ocrService ?? OCRService();

  Future<void> initialize() async {
    _box = await Hive.openBox<Receipt>(_boxName);
  }

  @override
  Future<Receipt> createReceipt({
    required String expenseId,
    required String imagePath,
    String? geolocation,
  }) async {
    final receipt = Receipt.create(
      expenseId: expenseId,
      imagePath: imagePath,
      geolocation: geolocation,
    );

    await _box.put(receipt.id, receipt);
    return receipt;
  }

  @override
  Future<Receipt?> getReceiptById(String id) async {
    return _box.get(id);
  }

  @override
  Future<List<Receipt>> getReceiptsByExpenseId(String expenseId) async {
    return _box.values
        .where((receipt) => receipt.expenseId == expenseId)
        .toList();
  }

  @override
  Future<List<Receipt>> getAllReceipts() async {
    return _box.values.toList();
  }

  @override
  Future<Receipt> updateReceipt(Receipt receipt) async {
    await _box.put(receipt.id, receipt);
    return receipt;
  }

  @override
  Future<bool> deleteReceipt(String id) async {
    try {
      await _box.delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Receipt> processReceiptOCR(Receipt receipt) async {
    try {
      // Update status to processing
      final processingReceipt = receipt.copyWith(
        status: ReceiptStatus.processing,
      );
      await updateReceipt(processingReceipt);

      // Process OCR
      final ocrResult = await _ocrService.processReceipt(receipt.imagePath);

      // Update receipt with OCR results
      final updatedReceipt = processingReceipt.copyWith(
        status:
            ocrResult.success ? ReceiptStatus.completed : ReceiptStatus.failed,
        extractedText: ocrResult.extractedText,
        merchant: ocrResult.merchant,
        extractedAmount: ocrResult.totalAmount,
        extractedDate: ocrResult.date,
        extractedCurrency: 'USD', // Default currency
        confidence: ocrResult.confidence,
        ocrData: ocrResult.rawData,
      );

      await updateReceipt(updatedReceipt);
      return updatedReceipt;
    } catch (e) {
      // Update status to failed on error
      final failedReceipt = receipt.copyWith(
        status: ReceiptStatus.failed,
        extractedText: 'OCR processing failed: $e',
        confidence: 0.0,
      );

      await updateReceipt(failedReceipt);
      return failedReceipt;
    }
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }

  // Additional helper methods

  Future<List<Receipt>> getReceiptsByStatus(ReceiptStatus status) async {
    return _box.values.where((receipt) => receipt.status == status).toList();
  }

  Future<List<Receipt>> getReceiptsByDateRange(
      DateTime start, DateTime end) async {
    return _box.values
        .where((receipt) =>
            receipt.createdAt.isAfter(start) && receipt.createdAt.isBefore(end))
        .toList();
  }

  Future<List<Receipt>> searchReceipts({
    String? merchant,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
    ReceiptStatus? status,
  }) async {
    return _box.values.where((receipt) {
      // Merchant filter
      if (merchant != null && merchant.isNotEmpty) {
        if (receipt.merchant == null ||
            !receipt.merchant!.toLowerCase().contains(merchant.toLowerCase())) {
          return false;
        }
      }

      // Amount filter
      if (minAmount != null && receipt.extractedAmount != null) {
        if (receipt.extractedAmount! < minAmount) return false;
      }
      if (maxAmount != null && receipt.extractedAmount != null) {
        if (receipt.extractedAmount! > maxAmount) return false;
      }

      // Date filter
      if (startDate != null && receipt.createdAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && receipt.createdAt.isAfter(endDate)) {
        return false;
      }

      // Status filter
      if (status != null && receipt.status != status) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<Map<ReceiptStatus, int>> getReceiptStatusCounts() async {
    final counts = <ReceiptStatus, int>{};

    for (final status in ReceiptStatus.values) {
      counts[status] = 0;
    }

    for (final receipt in _box.values) {
      counts[receipt.status] = (counts[receipt.status] ?? 0) + 1;
    }

    return counts;
  }

  Future<double> getTotalExtractedAmount() async {
    double total = 0.0;

    for (final receipt in _box.values) {
      if (receipt.extractedAmount != null) {
        total += receipt.extractedAmount!;
      }
    }

    return total;
  }

  Future<List<String>> getUniqueMerchants() async {
    final merchants = <String>{};

    for (final receipt in _box.values) {
      if (receipt.merchant != null && receipt.merchant!.isNotEmpty) {
        merchants.add(receipt.merchant!);
      }
    }

    return merchants.toList()..sort();
  }
}

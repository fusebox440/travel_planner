import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  late final TextRecognizer _textRecognizer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _textRecognizer = TextRecognizer();
      _isInitialized = true;
    }
  }

  Future<OCRResult> processReceipt(String imagePath) async {
    try {
      await initialize();

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return _parseReceiptText(recognizedText.text, recognizedText);
    } catch (e) {
      return OCRResult(
        success: false,
        error: 'OCR processing failed: $e',
        confidence: 0.0,
      );
    }
  }

  Future<OCRResult> processReceiptFromBytes(Uint8List imageBytes) async {
    try {
      await initialize();

      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(0, 0), // Will be determined from image
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 0,
        ),
      );

      final recognizedText = await _textRecognizer.processImage(inputImage);

      return _parseReceiptText(recognizedText.text, recognizedText);
    } catch (e) {
      return OCRResult(
        success: false,
        error: 'OCR processing failed: $e',
        confidence: 0.0,
      );
    }
  }

  OCRResult _parseReceiptText(String fullText, RecognizedText recognizedText) {
    try {
      final lines =
          fullText.split('\n').where((line) => line.trim().isNotEmpty).toList();

      // Extract merchant name (usually first few lines)
      String? merchant = _extractMerchant(lines);

      // Extract total amount
      double? amount = _extractAmount(lines);

      // Extract date
      DateTime? date = _extractDate(lines);

      // Extract items
      List<ReceiptItem> items = _extractItems(lines);

      // Calculate confidence based on successful extractions
      double confidence = _calculateConfidence(merchant, amount, date, items);

      return OCRResult(
        success: true,
        extractedText: fullText,
        merchant: merchant,
        totalAmount: amount,
        date: date,
        items: items,
        confidence: confidence,
        rawData: {
          'full_text': fullText,
          'lines_count': lines.length,
          'blocks_count': recognizedText.blocks.length,
        },
      );
    } catch (e) {
      return OCRResult(
        success: false,
        error: 'Text parsing failed: $e',
        extractedText: fullText,
        confidence: 0.0,
      );
    }
  }

  String? _extractMerchant(List<String> lines) {
    // Look for merchant name in first few lines, excluding common receipt headers
    final commonHeaders = ['receipt', 'invoice', 'bill', 'order', 'ticket'];

    for (int i = 0; i < (lines.length < 5 ? lines.length : 5); i++) {
      final line = lines[i].trim().toLowerCase();

      // Skip lines that look like addresses, phone numbers, or common headers
      if (line.isEmpty ||
          line.contains(RegExp(r'\d{3}[-\s]?\d{3}[-\s]?\d{4}')) || // phone
          line.contains(RegExp(
              r'\d+\s+\w+\s+(st|ave|rd|blvd|street|avenue|road|boulevard)',
              caseSensitive: false)) || // address
          commonHeaders.any((header) => line.contains(header))) {
        continue;
      }

      // If line has reasonable length and isn't all caps/numbers, likely merchant
      if (line.length >= 3 &&
          line.length <= 50 &&
          !RegExp(r'^[\d\s\-\.\,]+$').hasMatch(line)) {
        return lines[i].trim();
      }
    }

    return null;
  }

  double? _extractAmount(List<String> lines) {
    // Look for total amount patterns
    final totalPatterns = [
      RegExp(r'total[:\s]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'amount[:\s]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'subtotal[:\s]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'\$(\d+\.?\d+)$'),
      RegExp(r'(\d+\.\d{2})$'), // Decimal amount at end of line
    ];

    for (final line in lines.reversed) {
      // Start from bottom
      for (final pattern in totalPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final amountStr = match.group(1) ?? match.group(0);
          final amount = double.tryParse(amountStr?.replaceAll('\$', '') ?? '');
          if (amount != null && amount > 0 && amount < 10000) {
            // Reasonable range
            return amount;
          }
        }
      }
    }

    return null;
  }

  DateTime? _extractDate(List<String> lines) {
    final datePatterns = [
      RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'),
      RegExp(r'(\d{4}[-/]\d{1,2}[-/]\d{1,2})'),
      RegExp(
          r'(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{1,2}),?\s+(\d{4})',
          caseSensitive: false),
    ];

    for (final line in lines.take(10)) {
      // Look in first 10 lines
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(line.toLowerCase());
        if (match != null) {
          try {
            final dateStr = match.group(0) ?? '';
            // Try multiple date parsing strategies
            DateTime? date = _parseDate(dateStr);
            if (date != null) {
              return date;
            }
          } catch (e) {
            // Continue to next pattern
          }
        }
      }
    }

    return null;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Remove extra spaces and normalize
      dateStr = dateStr.trim().toLowerCase();

      // Handle different date formats
      if (dateStr.contains('/') || dateStr.contains('-')) {
        final parts = dateStr.split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          int year, month, day;

          // Determine format based on which part is likely the year
          if (parts[2].length == 4) {
            // MM/DD/YYYY or DD/MM/YYYY
            month = int.parse(parts[0]);
            day = int.parse(parts[1]);
            year = int.parse(parts[2]);
          } else if (parts[0].length == 4) {
            // YYYY/MM/DD
            year = int.parse(parts[0]);
            month = int.parse(parts[1]);
            day = int.parse(parts[2]);
          } else {
            // Assume MM/DD/YY
            month = int.parse(parts[0]);
            day = int.parse(parts[1]);
            year = int.parse(parts[2]) + 2000; // Assume 20xx
          }

          if (month > 12) {
            // Swap month and day if month > 12
            int temp = month;
            month = day;
            day = temp;
          }

          return DateTime(year, month, day);
        }
      }

      // Handle month name formats
      final monthNames = {
        'jan': 1,
        'january': 1,
        'feb': 2,
        'february': 2,
        'mar': 3,
        'march': 3,
        'apr': 4,
        'april': 4,
        'may': 5,
        'jun': 6,
        'june': 6,
        'jul': 7,
        'july': 7,
        'aug': 8,
        'august': 8,
        'sep': 9,
        'september': 9,
        'oct': 10,
        'october': 10,
        'nov': 11,
        'november': 11,
        'dec': 12,
        'december': 12,
      };

      for (final monthName in monthNames.keys) {
        if (dateStr.contains(monthName)) {
          final pattern = RegExp(r'(\w+)\s+(\d{1,2}),?\s+(\d{4})');
          final match = pattern.firstMatch(dateStr);
          if (match != null) {
            final month = monthNames[match.group(1)!.toLowerCase()];
            final day = int.parse(match.group(2)!);
            final year = int.parse(match.group(3)!);

            if (month != null) {
              return DateTime(year, month, day);
            }
          }
        }
      }
    } catch (e) {
      // Return null if parsing fails
    }

    return null;
  }

  List<ReceiptItem> _extractItems(List<String> lines) {
    final items = <ReceiptItem>[];

    for (final line in lines) {
      // Look for lines with item name and price
      final itemPattern = RegExp(r'^(.+?)\s+\$?(\d+\.?\d*)$');
      final match = itemPattern.firstMatch(line.trim());

      if (match != null) {
        final itemName = match.group(1)?.trim();
        final priceStr = match.group(2);
        final price = double.tryParse(priceStr ?? '');

        if (itemName != null && price != null && price > 0 && price < 1000) {
          // Filter out lines that look like totals, taxes, etc.
          final lowerName = itemName.toLowerCase();
          if (!lowerName.contains('total') &&
              !lowerName.contains('tax') &&
              !lowerName.contains('subtotal') &&
              !lowerName.contains('change') &&
              itemName.length >= 2) {
            items.add(ReceiptItem(
              name: itemName,
              price: price,
              quantity: 1, // Default quantity
            ));
          }
        }
      }
    }

    return items;
  }

  double _calculateConfidence(String? merchant, double? amount, DateTime? date,
      List<ReceiptItem> items) {
    double confidence = 0.0;

    if (merchant != null && merchant.isNotEmpty) confidence += 0.3;
    if (amount != null && amount > 0) confidence += 0.4;
    if (date != null) confidence += 0.2;
    if (items.isNotEmpty) confidence += 0.1;

    return confidence;
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _textRecognizer.close();
      _isInitialized = false;
    }
  }
}

class OCRResult {
  final bool success;
  final String? error;
  final String? extractedText;
  final String? merchant;
  final double? totalAmount;
  final DateTime? date;
  final List<ReceiptItem> items;
  final double confidence;
  final Map<String, dynamic>? rawData;

  OCRResult({
    required this.success,
    this.error,
    this.extractedText,
    this.merchant,
    this.totalAmount,
    this.date,
    this.items = const [],
    required this.confidence,
    this.rawData,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
      'extractedText': extractedText,
      'merchant': merchant,
      'totalAmount': totalAmount,
      'date': date?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'confidence': confidence,
      'rawData': rawData,
    };
  }
}

class ReceiptItem {
  final String name;
  final double price;
  final int quantity;

  ReceiptItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

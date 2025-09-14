import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../../../src/models/expense.dart';
import '../data/expense_repository.dart';
import '../data/receipt_repository.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;

  late final ExpenseRepository _expenseRepository;

  ExportService._internal() {
    _expenseRepository = HiveExpenseRepository(
      receiptRepository: HiveReceiptRepository(),
    );
  }
  Future<ExportResult> exportToCSV({
    DateTime? startDate,
    DateTime? endDate,
    List<ExpenseCategory>? categories,
    String? tripId,
    String? fileName,
  }) async {
    try {
      final expenses = await _expenseRepository.getExpensesForExport(
        startDate: startDate,
        endDate: endDate,
        categories: categories,
        tripId: tripId,
      );

      if (expenses.isEmpty) {
        return ExportResult(
          success: false,
          error: 'No expenses found for the selected criteria',
        );
      }

      // Create CSV headers
      final headers = [
        'Date',
        'Title',
        'Amount',
        'Currency',
        'Category',
        'Sub Category',
        'Merchant',
        'Payment Method',
        'Notes',
        'Tags',
        'Trip ID',
        'Is Recurring',
        'Tax Amount',
        'Tip Amount',
      ];

      // Create CSV data
      final List<List<dynamic>> csvData = [headers];

      for (final expense in expenses) {
        csvData.add([
          expense['dateFormatted'] ?? '',
          expense['title'] ?? '',
          expense['amount']?.toString() ?? '',
          expense['currency'] ?? '',
          expense['categoryName'] ?? '',
          expense['subCategoryName'] ?? '',
          expense['merchant'] ?? '',
          expense['paymentMethodName'] ?? '',
          expense['note'] ?? '',
          expense['tags']?.join(', ') ?? '',
          expense['tripId'] ?? '',
          expense['isRecurring']?.toString() ?? 'false',
          expense['taxAmount']?.toString() ?? '',
          expense['tipAmount']?.toString() ?? '',
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/${fileName ?? _generateFileName("expenses", "csv")}');
      await file.writeAsString(csvString);

      // Calculate totals
      final totalAmount = expenses.fold<double>(
          0.0,
          (sum, expense) =>
              sum + ((expense['amount'] as num?)?.toDouble() ?? 0.0));

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: file.path.split('/').last,
        format: ExportFormat.csv,
        recordCount: expenses.length,
        totalAmount: totalAmount,
        fileSize: await file.length(),
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Failed to export CSV: $e',
      );
    }
  }

  Future<ExportResult> exportToPDF({
    DateTime? startDate,
    DateTime? endDate,
    List<ExpenseCategory>? categories,
    String? tripId,
    String? fileName,
    bool includeCharts = false,
  }) async {
    try {
      final expenses = await _expenseRepository.getExpensesForExport(
        startDate: startDate,
        endDate: endDate,
        categories: categories,
        tripId: tripId,
      );

      if (expenses.isEmpty) {
        return ExportResult(
          success: false,
          error: 'No expenses found for the selected criteria',
        );
      }

      final pdf = pw.Document();

      // Calculate summary data
      final totalAmount = expenses.fold<double>(
          0.0,
          (sum, expense) =>
              sum + ((expense['amount'] as num?)?.toDouble() ?? 0.0));

      final categoryTotals = <String, double>{};
      for (final expense in expenses) {
        final category = expense['categoryName'] as String? ?? 'Other';
        final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
      }

      // Add summary page
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Expense Report'),
              ),
              pw.SizedBox(height: 20),

              // Summary section
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Summary',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text('Total Expenses: ${expenses.length}'),
                    pw.Text(
                        'Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
                    pw.Text(
                        'Date Range: ${_formatDateRange(startDate, endDate)}'),
                    if (categories?.isNotEmpty == true)
                      pw.Text(
                          'Categories: ${categories!.map((c) => c.toString().split('.').last).join(', ')}'),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Category breakdown
              pw.Text('Category Breakdown',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              ...categoryTotals.entries.map(
                (entry) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(entry.key),
                      pw.Text('\$${entry.value.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Add expense details page(s)
      final itemsPerPage = 25;
      final pageCount = (expenses.length / itemsPerPage).ceil();

      for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
        final startIndex = pageIndex * itemsPerPage;
        final endIndex =
            ((pageIndex + 1) * itemsPerPage).clamp(0, expenses.length);
        final pageExpenses = expenses.sublist(startIndex, endIndex);

        pdf.addPage(
          pw.Page(
            build: (context) => pw.Column(
              children: [
                pw.Header(
                  level: 1,
                  child: pw.Text('Expense Details - Page ${pageIndex + 1}'),
                ),
                pw.SizedBox(height: 20),

                // Table header
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2), // Date
                    1: pw.FlexColumnWidth(3), // Title
                    2: pw.FlexColumnWidth(1.5), // Amount
                    3: pw.FlexColumnWidth(2), // Category
                    4: pw.FlexColumnWidth(2), // Merchant
                  },
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Date',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Title',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Amount',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Category',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Merchant',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),

                    // Table rows
                    ...pageExpenses.map(
                      (expense) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(expense['dateFormatted'] ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(expense['title'] ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                                '\$${expense['amount']?.toStringAsFixed(2) ?? '0.00'}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(expense['categoryName'] ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(expense['merchant'] ?? ''),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/${fileName ?? _generateFileName("expenses_report", "pdf")}');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: file.path.split('/').last,
        format: ExportFormat.pdf,
        recordCount: expenses.length,
        totalAmount: totalAmount,
        fileSize: await file.length(),
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Failed to export PDF: $e',
      );
    }
  }

  Future<ExportResult> exportExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
    String? tripId,
    String? fileName,
  }) async {
    try {
      // Get all expenses for the period
      final allExpenses = await _expenseRepository.getExpensesForExport(
        startDate: startDate,
        endDate: endDate,
        tripId: tripId,
      );

      if (allExpenses.isEmpty) {
        return ExportResult(
          success: false,
          error: 'No expenses found for the selected criteria',
        );
      }

      // Calculate category totals
      final categoryTotals =
          await _expenseRepository.getTotalsByCategory(tripId: tripId);
      final merchantTotals =
          await _expenseRepository.getTotalsByMerchant(tripId: tripId);

      final totalAmount = allExpenses.fold<double>(
          0.0,
          (sum, expense) =>
              sum + ((expense['amount'] as num?)?.toDouble() ?? 0.0));

      // Create summary CSV
      final List<List<dynamic>> csvData = [
        ['Expense Summary Report'],
        ['Generated on:', DateTime.now().toString()],
        ['Date Range:', _formatDateRange(startDate, endDate)],
        ['Total Expenses:', allExpenses.length.toString()],
        ['Total Amount:', totalAmount.toStringAsFixed(2)],
        [],

        // Category breakdown
        ['Category Breakdown'],
        ['Category', 'Amount', 'Percentage'],
        ...categoryTotals.entries
            .where((entry) => entry.value > 0)
            .map((entry) => [
                  entry.key.toString().split('.').last,
                  entry.value.toStringAsFixed(2),
                  '${(entry.value / totalAmount * 100).toStringAsFixed(1)}%',
                ]),
        [],

        // Top merchants
        ['Top Merchants'],
        ['Merchant', 'Amount', 'Count'],
      ];

      // Add top merchants data
      final topMerchants = merchantTotals.entries
          .where((entry) => entry.value > 0)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in topMerchants.take(10)) {
        csvData.add([
          entry.key,
          entry.value.toStringAsFixed(2),
          allExpenses
              .where((exp) => exp['merchant'] == entry.key)
              .length
              .toString(),
        ]);
      }

      // Convert to CSV and save
      final csvString = const ListToCsvConverter().convert(csvData);
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/${fileName ?? _generateFileName("expense_summary", "csv")}');
      await file.writeAsString(csvString);

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: file.path.split('/').last,
        format: ExportFormat.csv,
        recordCount: allExpenses.length,
        totalAmount: totalAmount,
        fileSize: await file.length(),
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Failed to export summary: $e',
      );
    }
  }

  String _generateFileName(String prefix, String extension) {
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    return '${prefix}_$timestamp.$extension';
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      return 'All time';
    } else if (start == null) {
      return 'Up to ${end!.toIso8601String().split('T')[0]}';
    } else if (end == null) {
      return 'From ${start.toIso8601String().split('T')[0]}';
    } else {
      return '${start.toIso8601String().split('T')[0]} to ${end.toIso8601String().split('T')[0]}';
    }
  }
}

enum ExportFormat {
  csv,
  pdf,
}

class ExportResult {
  final bool success;
  final String? error;
  final String? filePath;
  final String? fileName;
  final ExportFormat? format;
  final int? recordCount;
  final double? totalAmount;
  final int? fileSize;

  ExportResult({
    required this.success,
    this.error,
    this.filePath,
    this.fileName,
    this.format,
    this.recordCount,
    this.totalAmount,
    this.fileSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
      'filePath': filePath,
      'fileName': fileName,
      'format': format?.toString().split('.').last,
      'recordCount': recordCount,
      'totalAmount': totalAmount,
      'fileSize': fileSize,
    };
  }
}

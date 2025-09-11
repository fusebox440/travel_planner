import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../booking/models/booking.dart';
import '../../booking/providers/booking_provider.dart';

enum ImportType {
  bookings,
  email,
}

class ImportResult {
  final ImportType type;
  final List<Booking>? bookings;
  final String? emailContent;

  ImportResult.bookings(this.bookings)
      : type = ImportType.bookings,
        emailContent = null;

  ImportResult.email(this.emailContent)
      : type = ImportType.email,
        bookings = null;
}

class ImportDialog extends ConsumerStatefulWidget {
  const ImportDialog({super.key});

  @override
  ConsumerState<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<ImportDialog> {
  ImportType _selectedType = ImportType.bookings;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Items'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('From Bookings'),
            leading: Radio<ImportType>(
              value: ImportType.bookings,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('From Email'),
            leading: Radio<ImportType>(
              value: ImportType.email,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ),
          if (_selectedType == ImportType.email) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Paste email content here',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleImport,
          child: const Text('Import'),
        ),
      ],
    );
  }

  void _handleImport() {
    switch (_selectedType) {
      case ImportType.bookings:
        final bookings = ref.read(savedBookingsProvider);
        Navigator.pop(
          context,
          ImportResult.bookings(bookings),
        );
        break;
      case ImportType.email:
        if (_emailController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please paste the email content'),
            ),
          );
          return;
        }
        Navigator.pop(
          context,
          ImportResult.email(_emailController.text),
        );
        break;
    }
  }
}

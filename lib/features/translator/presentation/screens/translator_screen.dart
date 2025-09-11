import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_planner/features/translator/data/translation_service.dart';
import 'package:travel_planner/features/translator/presentation/providers/translation_provider.dart';
import 'package:travel_planner/src/models/trip.dart';

class TranslatorScreen extends ConsumerStatefulWidget {
  const TranslatorScreen({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  ConsumerState<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends ConsumerState<TranslatorScreen> {
  final _inputController = TextEditingController();
  bool _isListening = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _onTranslate() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      ref.read(inputTextProvider.notifier).state = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supportedLanguages = ref.watch(supportedLanguagesProvider);
    final sourceLanguage = ref.watch(sourceLanguageProvider);
    final targetLanguage = ref.watch(targetLanguageProvider);
    final inputText = ref.watch(inputTextProvider);
    final translation = ref.watch(translationProvider(inputText));
    final detectedLanguage = ref.watch(detectedLanguageProvider(inputText));
    final isOnline = ref.watch(translationServiceStatusProvider).value ?? false;
    final recentLanguages = ref.watch(recentLanguagesProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translator'),
        actions: [
          // Offline indicator
          if (!isOnline)
            const Tooltip(
              message: 'Offline mode - Using cached translations',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.cloud_off),
              ),
            ),
          // History action
          IconButton(
            icon: badges.Badge(
              showBadge: favorites.isNotEmpty,
              badgeContent: Text(
                favorites.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              child: const Icon(Icons.favorite_border),
            ),
            tooltip: 'Saved Phrases',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/trip/${widget.trip.id}/translator/saved',
                  extra: widget.trip);
            },
          ),
          // More options menu
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'clear_history':
                  final shouldClear = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History?'),
                      content: const Text(
                        'This will remove all translation history and cached results. '
                        'Saved phrases will not be affected.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (shouldClear ?? false) {
                    final service = ref.read(translationServiceProvider);
                    await service.clearHistory();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('History cleared')),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_history',
                child: Text('Clear History'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Language Selection
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: sourceLanguage,
                        items: supportedLanguages.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            HapticFeedback.lightImpact();
                            ref.read(sourceLanguageProvider.notifier).state =
                                value;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'From',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor:
                              theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () {
                        if (sourceLanguage != 'auto') {
                          HapticFeedback.lightImpact();
                          final current = ref.read(sourceLanguageProvider);
                          ref.read(sourceLanguageProvider.notifier).state =
                              ref.read(targetLanguageProvider);
                          ref.read(targetLanguageProvider.notifier).state =
                              current;
                        }
                      },
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: targetLanguage,
                        items: supportedLanguages.entries
                            .where((e) => e.key != 'auto')
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            HapticFeedback.lightImpact();
                            ref.read(targetLanguageProvider.notifier).state =
                                value;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'To',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor:
                              theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
                if (recentLanguages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text('Recent: ', style: TextStyle(fontSize: 12)),
                        ...recentLanguages.map((code) {
                          final name = supportedLanguages[code] ?? code;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(name),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                if (sourceLanguage == 'auto') {
                                  ref
                                      .read(targetLanguageProvider.notifier)
                                      .state = code;
                                } else {
                                  ref
                                      .read(sourceLanguageProvider.notifier)
                                      .state = code;
                                }
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // Input Field
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _inputController,
                      maxLines: 4,
                      maxLength: 500, // Reasonable limit for API calls
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Enter text to translate',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_inputController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _inputController.clear();
                                  ref.read(inputTextProvider.notifier).state =
                                      '';
                                },
                              ),
                            IconButton(
                              icon: Icon(
                                  _isListening ? Icons.mic_off : Icons.mic),
                              tooltip: 'Voice input (coming soon)',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Voice input coming soon!'),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              tooltip: 'Camera input (coming soon)',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('OCR translation coming soon!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          ref.read(inputTextProvider.notifier).state = '';
                        }
                      },
                      onSubmitted: (_) => _onTranslate(),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: FilledButton.icon(
                        onPressed:
                            _inputController.text.isEmpty ? null : _onTranslate,
                        icon: const Icon(Icons.translate),
                        label: const Text('Translate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Translation Result
            if (inputText.isNotEmpty)
              translation.when(
                data: (translatedText) => Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (sourceLanguage == 'auto')
                              detectedLanguage.when(
                                data: (detected) => Text(
                                  'Detected language: ${supportedLanguages[detected] ?? detected}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            const SizedBox(height: 8),
                            SelectableText(
                              inputText,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Translation',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'Copy translation',
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Clipboard.setData(
                                      ClipboardData(text: translatedText),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Copied to clipboard'),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  tooltip: 'Share translation',
                                  onPressed: () {
                                    // TODO: Implement sharing
                                    HapticFeedback.lightImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Sharing coming soon!'),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.favorite_outline),
                                  tooltip: 'Save to favorites',
                                  onPressed: () async {
                                    HapticFeedback.lightImpact();
                                    final service =
                                        ref.read(translationServiceProvider);
                                    await service.saveFavorite(Translation(
                                      sourceText: inputText,
                                      translatedText: translatedText,
                                      fromLanguage: sourceLanguage,
                                      toLanguage: targetLanguage,
                                      timestamp: DateTime.now(),
                                      isFavorite: true,
                                    ));
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to favorites'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              translatedText,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) {
                  debugPrint('Translation error: $error\n$stackTrace');
                  return Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Translation failed',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _onTranslate,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          if (!isOnline) ...[
                            const SizedBox(height: 16),
                            Text(
                              'You are currently offline. Only saved translations are available.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

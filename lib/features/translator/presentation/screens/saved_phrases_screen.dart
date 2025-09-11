import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/translator/presentation/providers/translation_provider.dart';

class SavedPhrasesScreen extends ConsumerWidget {
  const SavedPhrasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final supportedLanguages = ref.watch(supportedLanguagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Phrases'),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved phrases yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your favorite translations will appear here',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final translation = favorites[index];
                return Dismissible(
                  key: ValueKey(translation.key),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Theme.of(context).colorScheme.error,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) async {
                    HapticFeedback.mediumImpact();
                    final service = ref.read(translationServiceProvider);
                    await service.removeFavorite(translation);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${supportedLanguages[translation.fromLanguage]} → ${supportedLanguages[translation.toLanguage]}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Clipboard.setData(
                                    ClipboardData(
                                        text: translation.translatedText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            translation.sourceText,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Divider(),
                          Text(
                            translation.translatedText,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

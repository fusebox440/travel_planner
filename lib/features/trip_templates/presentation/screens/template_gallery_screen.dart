import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trip_template_providers.dart';
import '../widgets/template_card.dart';
import '../widgets/template_filters.dart';

class TemplateGalleryScreen extends ConsumerStatefulWidget {
  const TemplateGalleryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TemplateGalleryScreen> createState() =>
      _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends ConsumerState<TemplateGalleryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Templates'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'Featured'),
            Tab(icon: Icon(Icons.verified), text: 'Official'),
            Tab(icon: Icon(Icons.trending_up), text: 'Popular'),
            Tab(icon: Icon(Icons.apps), text: 'All'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/templates/create');
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Template',
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeaturedTab(),
          _buildOfficialTab(),
          _buildPopularTab(),
          _buildAllTab(),
        ],
      ),
    );
  }

  Widget _buildFeaturedTab() {
    return Consumer(
      builder: (context, ref, child) {
        final featuredTemplatesAsync = ref.watch(featuredTemplatesProvider);

        return featuredTemplatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No featured templates yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(featuredTemplatesProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TemplateCard(
                      template: templates[index],
                      onTap: () =>
                          _navigateToTemplateDetail(templates[index].id),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(featuredTemplatesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfficialTab() {
    return Consumer(
      builder: (context, ref, child) {
        final officialTemplatesAsync = ref.watch(officialTemplatesProvider);

        return officialTemplatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No official templates available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(officialTemplatesProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TemplateCard(
                      template: templates[index],
                      onTap: () =>
                          _navigateToTemplateDetail(templates[index].id),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(officialTemplatesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularTab() {
    return Consumer(
      builder: (context, ref, child) {
        final popularTemplatesAsync = ref.watch(popularTemplatesProvider);

        return popularTemplatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No popular templates yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(popularTemplatesProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TemplateCard(
                      template: templates[index],
                      onTap: () =>
                          _navigateToTemplateDetail(templates[index].id),
                      showUsageStats: true,
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(popularTemplatesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllTab() {
    return Column(
      children: [
        const TemplateFiltersWidget(),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final filteredTemplatesAsync =
                  ref.watch(filteredTemplatesProvider);

              return filteredTemplatesAsync.when(
                data: (templates) {
                  if (templates.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No templates found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(filteredTemplatesProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TemplateCard(
                            template: templates[index],
                            onTap: () =>
                                _navigateToTemplateDetail(templates[index].id),
                            showFullDetails: true,
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(filteredTemplatesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToTemplateDetail(String templateId) {
    Navigator.of(context).pushNamed(
      '/templates/detail',
      arguments: {'templateId': templateId},
    );
  }
}

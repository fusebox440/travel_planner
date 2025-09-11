import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_planner/features/weather/domain/models/weather.dart';
import 'package:travel_planner/features/weather/domain/models/forecast.dart';
import 'package:travel_planner/features/weather/presentation/providers/weather_provider.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  final String? initialCity;

  const WeatherScreen({this.initialCity, super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  late final TextEditingController _searchController;
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialCity);

    // If initial city is provided, fetch its weather
    if (widget.initialCity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(weatherStateProvider.notifier)
            .fetchWeather(widget.initialCity!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherStateProvider);
    final notifier = ref.read(weatherStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            icon: Icon(state.useFahrenheit ? Icons.thermostat : Icons.ac_unit),
            onPressed: notifier.toggleTemperatureUnit,
            tooltip: 'Toggle temperature unit',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refreshWeather,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter city name',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.requestFocus();
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          notifier.fetchWeather(value);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Error Message
                    if (state.errorMessage != null)
                      Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (state.isLoading)
                      const Center(child: CircularProgressIndicator()),

                    if (!state.isLoading && state.currentWeather != null) ...[
                      // Current Weather Card
                      _CurrentWeatherCard(
                        weather: state.currentWeather!,
                        useFahrenheit: state.useFahrenheit,
                      ),

                      const SizedBox(height: 16),

                      // Forecast Title
                      if (state.forecast != null)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '7-Day Forecast',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Forecast List
            if (!state.isLoading && state.forecast != null)
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _ForecastCard(
                        forecast: state.forecast![index],
                        useFahrenheit: state.useFahrenheit,
                      );
                    },
                    childCount: state.forecast!.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final Weather weather;
  final bool useFahrenheit;

  const _CurrentWeatherCard({
    required this.weather,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      weather.condition,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                CachedNetworkImage(
                  imageUrl: weather.iconUrl,
                  width: 64,
                  height: 64,
                  placeholder: (context, url) => const SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weather.formatTemperature(useFahrenheit: useFahrenheit),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Humidity: ${weather.humidity.round()}%'),
                    Text('Wind: ${weather.windSpeed.round()} m/s'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final Forecast forecast;
  final bool useFahrenheit;

  const _ForecastCard({
    required this.forecast,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(forecast.date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            CachedNetworkImage(
              imageUrl: forecast.iconUrl,
              width: 48,
              height: 48,
              placeholder: (context, url) => const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Text(
                forecast.formatTemperatureRange(useFahrenheit: useFahrenheit),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return 'Tomorrow';
    }
    return '${date.month}/${date.day}';
  }
}

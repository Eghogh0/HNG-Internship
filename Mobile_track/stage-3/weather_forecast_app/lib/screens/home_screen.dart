import 'dart:convert'; // <-- Add this
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:page_transition/page_transition.dart'; // <-- Add this
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/cache_service.dart';
import '../utils/constants.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast_tile.dart';
import '../widgets/error_display.dart';
import '../widgets/shimmer_loading.dart';
import 'city_search_screen.dart';
import 'forecast_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final LocationService _loc = LocationService();
  final CacheService _cache = CacheService();

  WeatherModel? _currentWeather;
  List<WeatherModel>? _forecast;
  bool _isLoading = true;
  String? _error;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _initWeather();
  }

  Future<void> _initWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOffline = connectivityResult == ConnectivityResult.none;

      if (_isOffline) {
        await _loadCachedData();
        return;
      }

      // Try current location
      final position = await _loc.getCurrentPosition();
      final city = await _loc.getCityFromPosition(position);
      await _fetchWeatherByCity(city);
    } catch (e) {
      // Fallback to default city or cached data
      try {
        if (await _cache.isCacheValid()) {
          await _loadCachedData();
          return;
        }
      } catch (_) {}
      // Final fallback: load default city
      try {
        await _fetchWeatherByCity(Constants.defaultCity);
      } catch (ex) {
        setState(() {
          _error = 'Could not fetch weather. Check connection.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchWeatherByCity(String city) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final weather = await _api.fetchCurrentWeatherByCity(city);
      final forecast = await _api.fetchForecastByCity(city);

      // Cache data
      await _cache.cacheWeatherData(jsonEncode(weather.toJson()));
      await _cache.cacheForecastData(jsonEncode(forecast.map((e) => e.toJson()).toList()));

      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      // Attempt to load cached data if fetch fails
      if (await _cache.isCacheValid()) {
        await _loadCachedData();
      }
    }
  }

  Future<void> _loadCachedData() async {
    setState(() => _isLoading = true);
    try {
      final weatherString = await _cache.getCachedWeather();
      final forecastString = await _cache.getCachedForecast();
      if (weatherString != null) {
        final Map<String, dynamic> weatherJson = jsonDecode(weatherString);
        _currentWeather = WeatherModel.fromJson(weatherJson);
      }
      if (forecastString != null) {
        final List<dynamic> list = jsonDecode(forecastString);
        _forecast = list.map((e) => WeatherModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (_currentWeather != null || _forecast != null) {
        setState(() {
          _isLoading = false;
          _error = _isOffline ? 'Offline mode. Showing cached data.' : null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'No cached data available.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load cached data.';
      });
    }
  }

  void _navigateToSearch() async {
    final city = await Navigator.push(context,
        PageTransition(child: const CitySearchScreen(), type: PageTransitionType.rightToLeft));
    if (city != null && city is String) {
      _fetchWeatherByCity(city);
    }
  }

  void _navigateToForecastDetails() {
    if (_forecast != null && _forecast!.isNotEmpty) {
      Navigator.push(
          context,
          PageTransition(
              child: ForecastDetailsScreen(forecast: _forecast!),
              type: PageTransitionType.bottomToTop));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherNow'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _navigateToSearch),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _initWeather(),
        child: _isLoading
            ? const ShimmerLoading()
            : _error != null && _currentWeather == null
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          MediaQuery.of(context).padding.top,
                      child: ErrorDisplay(message: _error!, onRetry: _initWeather),
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 500),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            if (_currentWeather != null) CurrentWeatherCard(weather: _currentWeather!),
            const SizedBox(height: 24),
            if (_forecast != null && _forecast!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Next Days', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: _navigateToForecastDetails,
                    child: const Text('See All'),
                  ),
                ],
              ),
              ...List.generate(
                _forecast!.length > 5 ? 5 : _forecast!.length,
                (index) => DailyForecastTile(
                  weather: _forecast![index],
                  dayLabel: 'Day ${index + 1}',
                ),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.orange)),
              ),
          ],
        ),
      ),
    );
  }
}
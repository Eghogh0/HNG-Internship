import 'dart:convert';
import 'dart:io' show exit;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:page_transition/page_transition.dart';
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initWeather();
  }

  // ---------- Data Loading ----------
  Future<void> _initWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOffline = connectivityResult == ConnectivityResult.none;
      if (_isOffline) {
        await _loadCachedData();
        return;
      }

      final position = await _loc.getCurrentPosition();
      final city = await _loc.getCityFromPosition(position);
      await _fetchWeatherByCity(city);
    } catch (e) {
      try {
        if (await _cache.isCacheValid()) {
          await _loadCachedData();
          return;
        }
      } catch (_) {}
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
      await _cache.cacheWeatherData(jsonEncode(weather.toJson()));
      await _cache
          .cacheForecastData(jsonEncode(forecast.map((e) => e.toJson()).toList()));
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
        _forecast = list
            .map((e) => WeatherModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      setState(() {
        _isLoading = false;
        _error = (_currentWeather == null && _forecast == null)
            ? 'No cached data available.'
            : (_isOffline ? 'Offline mode. Showing cached data.' : null);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load cached data.';
      });
    }
  }

  // ---------- Navigation ----------
  void _navigateToSearch() async {
    final city = await Navigator.push(
      context,
      PageTransition(
          child: const CitySearchScreen(),
          type: PageTransitionType.rightToLeft),
    );
    if (city != null && city is String) _fetchWeatherByCity(city);
  }

  void _navigateToForecastDetails() {
    if (_forecast != null && _forecast!.isNotEmpty) {
      Navigator.push(
        context,
        PageTransition(
            child: ForecastDetailsScreen(forecast: _forecast!),
            type: PageTransitionType.bottomToTop),
      );
    }
  }

  // ---------- About Dialog ----------
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WeatherNow'),
        content: const Text(
            'A cross‑platform weather app built for HNG Stage 4.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  // ---------- Keyboard Shortcuts ----------
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final keys = HardwareKeyboard.instance.logicalKeysPressed;
      if (keys.contains(LogicalKeyboardKey.controlLeft) ||
          keys.contains(LogicalKeyboardKey.controlRight) ||
          keys.contains(LogicalKeyboardKey.meta)) {
        if (event.logicalKey == LogicalKeyboardKey.keyR) {
          _initWeather();
        } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
          _navigateToSearch();
        } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
          _initWeather();
        } else if (event.logicalKey == LogicalKeyboardKey.keyQ) {
          if (!kIsWeb) exit(0);
        } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
          _navigateToForecastDetails();
        }
      }
    }
  }

  // ---------- Right‑click Context Menu ----------
  void _showContextMenu(Offset position, String item) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx + 1, position.dy + 1),
      items: [
        if (item == 'weather')
          const PopupMenuItem(value: 'refresh', child: Text('Refresh'))
        else ...[
          const PopupMenuItem(value: 'details', child: Text('View Details')),
          const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
        ],
      ],
    ).then((value) {
      if (value == 'refresh') _initWeather();
      if (value == 'details') _navigateToForecastDetails();
    });
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: isDesktop
            ? null
            : AppBar(
                title: const Text('WeatherNow'),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _navigateToSearch),
                ],
              ),
        drawer: isDesktop
            ? null
            : Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                        child: Text('WeatherNow',
                            style:
                                Theme.of(context).textTheme.headlineSmall)),
                    ListTile(
                        title: const Text('Home'),
                        onTap: () {
                          Navigator.pop(context);
                          _initWeather();
                        }),
                    ListTile(
                        title: const Text('Search City'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToSearch();
                        }),
                    if (_forecast != null)
                      ListTile(
                          title: const Text('5‑Day Forecast'),
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToForecastDetails();
                          }),
                  ],
                ),
              ),
        body: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _initWeather(),
      child: _isLoading
          ? const ShimmerLoading()
          : _error != null && _currentWeather == null
              ? ErrorDisplay(message: _error!, onRetry: _initWeather)
              : _buildContent(),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildDesktopMenuBar(),
        Expanded(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: 0,
                onDestinationSelected: (index) {
                  if (index == 0) _initWeather();
                  else if (index == 1) _navigateToSearch();
                  else if (index == 2) _navigateToForecastDetails();
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.home), label: Text('Home')),
                  NavigationRailDestination(
                      icon: Icon(Icons.search), label: Text('Search')),
                  NavigationRailDestination(
                      icon: Icon(Icons.calendar_today),
                      label: Text('Forecast')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _initWeather(),
                  child: _isLoading
                      ? const ShimmerLoading()
                      : _error != null && _currentWeather == null
                          ? ErrorDisplay(
                              message: _error!, onRetry: _initWeather)
                          : _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopMenuBar() {
    return Container(
      height: 30,
      color: Colors.grey[200],
      child: Row(
        children: [
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'refresh', child: Text('Refresh (Ctrl+R)')),
              const PopupMenuItem(value: 'quit', child: Text('Quit (Ctrl+Q)')),
            ],
            onSelected: (val) {
              if (val == 'refresh') _initWeather();
              else if (val == 'quit') {
                if (!kIsWeb) exit(0);
              }
            },
            child: const Text('File'),
          ),
          PopupMenuButton<String>(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'search', child: Text('Search (Ctrl+F)')),
              const PopupMenuItem(value: 'home', child: Text('Home (Ctrl+H)')),
            ],
            onSelected: (val) {
              if (val == 'search') _navigateToSearch();
              else if (val == 'home') _initWeather();
            },
            child: const Text('Edit'),
          ),
          PopupMenuButton<String>(
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'forecast', child: Text('Forecast (Ctrl+D)')),
            ],
            onSelected: (val) {
              if (val == 'forecast') _navigateToForecastDetails();
            },
            child: const Text('View'),
          ),
          PopupMenuButton<String>(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'about', child: Text('About')),
            ],
            onSelected: (val) {
              if (val == 'about') _showAboutDialog();
            },
            child: const Text('Help'),
          ),
        ],
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
            child: FadeInAnimation(child: widget),
          ),
          children: [
            if (_currentWeather != null)
              GestureDetector(
                onSecondaryTapUp: (details) =>
                    _showContextMenu(details.globalPosition, 'weather'),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: CurrentWeatherCard(weather: _currentWeather!),
                ),
              ),
            const SizedBox(height: 24),
            if (_forecast != null && _forecast!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Next Days',
                      style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: _navigateToForecastDetails,
                    child: const Text('See All'),
                  ),
                ],
              ),
              ...List.generate(
                _forecast!.length > 5 ? 5 : _forecast!.length,
                (index) => GestureDetector(
                  onSecondaryTapUp: (details) =>
                      _showContextMenu(details.globalPosition, 'forecast$index'),
                  child: DailyForecastTile(
                    weather: _forecast![index],
                    dayLabel: 'Day ${index + 1}',
                  ),
                ),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child:
                    Text(_error!, style: const TextStyle(color: Colors.orange)),
              ),
          ],
        ),
      ),
    );
  }
}
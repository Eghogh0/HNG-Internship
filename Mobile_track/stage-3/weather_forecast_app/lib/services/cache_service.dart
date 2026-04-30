import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class CacheService {
  static const String _weatherKey = 'cached_weather';
  static const String _forecastKey = 'cached_forecast';
  static const String _timestampKey = 'cache_timestamp';

  Future<void> cacheWeatherData(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherKey, jsonData);
    await prefs.setString(_timestampKey, DateTime.now().toIso8601String());
  }

  Future<String?> getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_weatherKey);
  }

  Future<void> cacheForecastData(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_forecastKey, jsonData);
  }

  Future<String?> getCachedForecast() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_forecastKey);
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_timestampKey);
    if (timestampStr == null) return false;
    final cacheTime = DateTime.tryParse(timestampStr);
    if (cacheTime == null) return false;
    final now = DateTime.now();
    return now.difference(cacheTime).inMinutes < 30; // 30 minutes expiry
  }
}
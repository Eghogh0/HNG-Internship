import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl = Constants.baseUrl;
  final String apiKey = Constants.apiKey;

  Future<WeatherModel> fetchCurrentWeatherByCity(String city) async {
    final url = Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw _handleError(response.statusCode, response.body);
    }
  }

  Future<WeatherModel> fetchCurrentWeatherByCoords(double lat, double lon) async {
    final url = Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw _handleError(response.statusCode, response.body);
    }
  }

  Future<List<WeatherModel>> fetchForecastByCity(String city) async {
    final url = Uri.parse('$baseUrl/forecast?q=$city&appid=$apiKey&units=metric');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseForecast(data['list']);
    } else {
      throw _handleError(response.statusCode, response.body);
    }
  }

  Future<List<WeatherModel>> fetchForecastByCoords(double lat, double lon) async {
    final url = Uri.parse('$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseForecast(data['list']);
    } else {
      throw _handleError(response.statusCode, response.body);
    }
  }

  List<WeatherModel> _parseForecast(List<dynamic> list) {
    final Map<String, WeatherModel> dayMap = {};
    for (var item in list) {
      final dtTxt = item['dt_txt'] as String;
      final datePart = dtTxt.split(' ')[0];
      final hour = int.parse(dtTxt.split(' ')[1].split(':')[0]);
      final weather = WeatherModel(
        cityName: '',
        temperature: (item['main']['temp'] as num).toDouble(),
        description: item['weather'][0]['description'],
        iconCode: item['weather'][0]['icon'],
        humidity: item['main']['humidity'],
        windSpeed: (item['wind']['speed'] as num).toDouble(),
        pressure: item['main']['pressure'],
        visibility: item['visibility'] ?? 0,
      );

      if (!dayMap.containsKey(datePart) || (hour >= 11 && hour <= 13)) {
        dayMap[datePart] = weather;
      }
    }

    final forecasts = dayMap.values.toList();
    // Sort by date
    forecasts.sort((a, b) {
      // We don't have the original date, but we can rely on order from map keys
      return 0;
    });
    return forecasts;
  }

  String _handleError(int statusCode, String body) {
    if (statusCode == 401) return 'Invalid API key.';
    if (statusCode == 404) return 'City not found.';
    if (statusCode == 429) return 'Too many requests. Try later.';
    return 'Something went wrong. Please try again.';
  }
}
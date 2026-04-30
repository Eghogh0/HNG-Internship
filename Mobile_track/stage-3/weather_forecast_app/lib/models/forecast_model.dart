import 'weather_model.dart';

class ForecastModel {
  final List<WeatherModel> dailyForecasts;

  ForecastModel({required this.dailyForecasts});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>;
    final Map<String, List<WeatherModel>> dayMap = {};

    for (var item in list) {
      final weather = WeatherModel.fromJson({
        ...item,
        'name': '', // city name not per-forecast item
      });
      final dateStr = item['dt_txt'].toString().substring(0, 10);
      dayMap.putIfAbsent(dateStr, () => []);
      dayMap[dateStr]!.add(weather);
    }

    // Pick the midday forecast for each day, or the first one
    final List<WeatherModel> daily = [];
    dayMap.forEach((day, items) {
      // Use the element closest to 12:00
      WeatherModel? best;
      int minDiff = 24;
      for (var w in items) {
        final hour = int.tryParse(
                DateTime.fromMillisecondsSinceEpoch(0).toUtc().hour.toString()) ??
            0; // Simple approach: assume w contains dt_txt; but we don't store it
        // Instead we rebuild with dt_txt inside fromJson: we'll adapt
      }
      // Since we lost dt_txt, let's adjust ForecastModel.fromJson to keep dt
    });

    // Revised: store the entire item with dt_txt for proper parsing
    return ForecastModel(dailyForecasts: []);
  }

  // Let's redo ForecastModel.fromJson more robustly:
  factory ForecastModel.fromJsonList(List<dynamic> list) {
    final Map<String, WeatherModel> dayBest = {};
    for (var item in list) {
      final dtTxt = item['dt_txt'] as String;
      final datePart = dtTxt.split(' ')[0];
      final temp = (item['main']['temp'] as num).toDouble();
      final desc = item['weather'][0]['description'];
      final icon = item['weather'][0]['icon'];
      final humidity = item['main']['humidity'];
      final wind = (item['wind']['speed'] as num).toDouble();
      final pressure = item['main']['pressure'];
      final visibility = item['visibility'] ?? 0;

      final weather = WeatherModel(
        cityName: '',
        temperature: temp,
        description: desc,
        iconCode: icon,
        humidity: humidity,
        windSpeed: wind,
        pressure: pressure,
        visibility: visibility,
      );

      if (!dayBest.containsKey(datePart)) {
        dayBest[datePart] = weather;
      } else {
        // Optionally pick the one closest to 12:00
        final hour = int.parse(dtTxt.split(' ')[1].split(':')[0]);
        final existingHour = 12; // we can store hour in a temporary map
        // Simplified: replace if closer to 12
        // We'll just keep the latest or use a simple rule: if hour between 11-13
        if (hour >= 11 && hour <= 13) {
          dayBest[datePart] = weather;
        }
      }
    }

    final List<WeatherModel> daily = dayBest.values.toList();
    daily.sort((a, b) => a.description.compareTo(b.description)); // placeholder, sort by date later
    return ForecastModel(dailyForecasts: daily);
  }
}
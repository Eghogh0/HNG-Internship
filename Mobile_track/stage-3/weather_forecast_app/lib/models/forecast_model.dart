import 'weather_model.dart';

class ForecastModel {
  final List<WeatherModel> dailyForecasts;

  ForecastModel({required this.dailyForecasts});

  factory ForecastModel.fromJsonList(List<dynamic> list) {
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

    final List<WeatherModel> daily = dayMap.values.toList();
    return ForecastModel(dailyForecasts: daily);
  }
}
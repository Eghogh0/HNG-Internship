import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/helpers.dart';

class DailyForecastTile extends StatelessWidget {
  final WeatherModel weather;
  final String dayLabel;
  const DailyForecastTile({super.key, required this.weather, required this.dayLabel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(weather.iconUrl, width: 40),
      title: Text(dayLabel),
      subtitle: Text(Helpers.capitalize(weather.description)),
      trailing: Text('${weather.temperature.round()}°C',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
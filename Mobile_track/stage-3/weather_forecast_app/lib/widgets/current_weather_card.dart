import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/helpers.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;
  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,   // show pointer on desktop
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(weather.cityName, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Image.network(weather.iconUrl, scale: 0.8),
              Text('${weather.temperature.round()}°C', style: Theme.of(context).textTheme.displayMedium),
              Text(Helpers.capitalize(weather.description), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoColumn(Icons.water_drop, '${weather.humidity}%', 'Humidity'),
                  _buildInfoColumn(Icons.air, '${weather.windSpeed} m/s', 'Wind'),
                  _buildInfoColumn(Icons.speed, '${weather.pressure} hPa', 'Pressure'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
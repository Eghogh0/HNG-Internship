import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/weather_model.dart';
import '../widgets/daily_forecast_tile.dart';

class ForecastDetailsScreen extends StatelessWidget {
  final List<WeatherModel> forecast;
  const ForecastDetailsScreen({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5-Day Forecast')),
      body: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: forecast.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: DailyForecastTile(
                    weather: forecast[index],
                    dayLabel: 'Day ${index + 1}',
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
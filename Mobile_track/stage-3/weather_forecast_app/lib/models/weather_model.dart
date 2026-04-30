class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': cityName,
        'main': {
          'temp': temperature,
          'humidity': humidity,
          'pressure': pressure,
        },
        'weather': [
          {'description': description, 'icon': iconCode}
        ],
        'wind': {'speed': windSpeed},
        'visibility': visibility,
      };

  String get iconUrl =>
      '${'https://openweathermap.org/img/wn/'}$iconCode@2x.png';
}
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../services/api_service.dart';
import '../models/weather_model.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _api = ApiService();
  WeatherModel? _searchResult;
  bool _isSearching = false;
  String? _error;

  Future<void> _searchCity() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() { _isSearching = true; _error = null; _searchResult = null; });
    try {
      final weather = await _api.fetchCurrentWeatherByCity(query);
      setState(() { _searchResult = weather; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isSearching = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search City')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'City name',
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _searchCity),
              ),
              onSubmitted: (_) => _searchCity(),
            ),
            const SizedBox(height: 20),
            if (_isSearching) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_searchResult != null)
              Card(
                child: ListTile(
                  leading: Image.network(_searchResult!.iconUrl),
                  title: Text(_searchResult!.cityName),
                  subtitle: Text('${_searchResult!.temperature.round()}°C, ${_searchResult!.description}'),
                  onTap: () => Navigator.pop(context, _searchResult!.cityName),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
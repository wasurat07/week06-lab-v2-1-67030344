import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../services/demo_post_service.dart';

class WeatherSearchPage extends StatefulWidget {
  const WeatherSearchPage({super.key});

  @override
  State<WeatherSearchPage> createState() => _WeatherSearchPageState();
}

class _WeatherSearchPageState extends State<WeatherSearchPage> {
  final _cityController = TextEditingController();
  final _weatherService = WeatherService();

  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null;
    });

    try {
      final result = await _weatherService.fetchWeather(city);
      setState(() {
        _weather = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาสภาพอากาศ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อเมือง (เช่น Bangkok, Tokyo)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchWeather(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isLoading ? null : _searchWeather,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => updateDemoPost(),
              child: const Text('ทดลอง PUT (ขั้นตอนที่ 3.2)'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_weather != null) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _weather!.cityName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${_weather!.temperature.toStringAsFixed(1)} °C',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(
                _weather!.description,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'รู้สึกเหมือน ${_weather!.feelsLike.toStringAsFixed(1)} °C',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return const Text('พิมพ์ชื่อเมืองเพื่อเริ่มต้นค้นหา');
  }
}
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final TextEditingController _cityController = TextEditingController(text: 'Cairo');
  
  Map<String, dynamic> _weatherData = {};
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _selectedForecastDay = 0;
  
  // Weather icons mapping
  final Map<String, IconData> _weatherIcons = {
    'clear': Icons.wb_sunny,
    'clouds': Icons.wb_cloudy,
    'rain': Icons.beach_access,
    'snow': Icons.ac_unit,
    'thunderstorm': Icons.flash_on,
    'drizzle': Icons.grain,
    'mist': Icons.cloud,
  };
  
  Future<void> _fetchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    
    try {
      // Using OpenWeatherMap API (free tier - simulation for now)
      // In production, use actual API with your API key
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulated weather data
      final simulatedData = {
        'city': city,
        'country': 'EG',
        'temperature': 28 - (city.length % 10),
        'feels_like': 26 - (city.length % 8),
        'humidity': 45 + (city.length % 30),
        'wind_speed': 12 + (city.length % 15),
        'pressure': 1012 + (city.length % 10),
        'description': 'Partly Cloudy',
        'main': 'Clouds',
        'icon': '02d',
        'forecast': List.generate(7, (index) => {
          'day': _getDayName(index),
          'temp_high': 28 - (index * 1) + (city.length % 5),
          'temp_low': 20 - (index * 1) + (city.length % 5),
          'main': ['Clear', 'Clouds', 'Rain', 'Clouds', 'Clear', 'Sunny', 'Partly'][index],
        }),
      };
      
      setState(() {
        _weatherData = simulatedData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to fetch weather data';
        _isLoading = false;
      });
    }
  }
  
  String _getDayName(int index) {
    final now = DateTime.now();
    final date = now.add(Duration(days: index));
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }
  
  IconData _getWeatherIcon(String main) {
    return _weatherIcons[main.toLowerCase()] ?? Icons.wb_sunny;
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Weather', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)))
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text(_errorMessage, style: const TextStyle(color: Colors.white38)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchWeather,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _cityController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter city name',
                                  hintStyle: const TextStyle(color: Colors.white38),
                                  prefixIcon: const Icon(Icons.location_city, color: Color(0xFF00BCD4)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.05),
                                ),
                                onSubmitted: (_) => _fetchWeather(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _fetchWeather,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00BCD4),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                              child: const Icon(Icons.search),
                            ),
                          ],
                        ),
                      ),
                      
                      // Current Weather
                      if (_weatherData.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00BCD4), Color(0xFF006064)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${_weatherData['city']}, ${_weatherData['country']}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Icon(
                                _getWeatherIcon(_weatherData['main']),
                                size: 80,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_weatherData['temperature'].toStringAsFixed(0)}°C',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _weatherData['description'],
                                style: const TextStyle(fontSize: 18, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        
                        // Weather Details
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDetailItem(Icons.thermostat, 'Feels like', '${_weatherData['feels_like'].toStringAsFixed(0)}°C'),
                              _buildDetailItem(Icons.water_drop, 'Humidity', '${_weatherData['humidity']}%'),
                              _buildDetailItem(Icons.air, 'Wind', '${_weatherData['wind_speed']} km/h'),
                              _buildDetailItem(Icons.speed, 'Pressure', '${_weatherData['pressure']} hPa'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // 7-Day Forecast
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Color(0xFF00BCD4), size: 18),
                              SizedBox(width: 8),
                              Text('7-Day Forecast', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _weatherData['forecast'].length,
                            itemBuilder: (context, index) {
                              final forecast = _weatherData['forecast'][index];
                              return Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _selectedForecastDay == index
                                      ? const Color(0xFF00BCD4).withOpacity(0.2)
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedForecastDay == index
                                        ? const Color(0xFF00BCD4)
                                        : Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedForecastDay = index),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        forecast['day'],
                                        style: TextStyle(
                                          color: _selectedForecastDay == index
                                              ? const Color(0xFF00BCD4)
                                              : Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Icon(
                                        _getWeatherIcon(forecast['main']),
                                        size: 24,
                                        color: _selectedForecastDay == index
                                            ? const Color(0xFF00BCD4)
                                            : Colors.white54,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${forecast['temp_high'].toStringAsFixed(0)}°',
                                        style: TextStyle(
                                          color: _selectedForecastDay == index
                                              ? const Color(0xFF00BCD4)
                                              : Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${forecast['temp_low'].toStringAsFixed(0)}°',
                                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00BCD4), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

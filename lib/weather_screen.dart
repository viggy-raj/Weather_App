import 'dart:convert';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

late Position position;
double humidity = 0.0, pressure = 0.0, wind_speed = 0.0, temp = 0.0;
//late double humidity, pressure, wind_speed, temp;
Future<void> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied');
  }

  position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  print("LAT: ${position.latitude}, LON: ${position.longitude}");
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      await getCurrentLocation();

      final String apiKey = dotenv.get('Weather_API_Key');

      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&APPID=$apiKey',
        ),
      );
      print('Weather data retrived');
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw "Failed to fetch weather data";
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {});
            },
            child: const Icon(Icons.refresh),
          ),
        ],
        actionsPadding: EdgeInsets.all(10),
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final data = snapshot.data!;
          humidity = (data['list'][0]['main']['humidity'] as num).toDouble();
          pressure = (data['list'][0]['main']['pressure'] as num).toDouble();
          wind_speed = (data['list'][0]['wind']['speed'] as num).toDouble();
          temp =
              (((data['list'][0]['main']['temp'] as num).toDouble()) - 273.15)
                  .roundToDouble();
          final currentSky = data['list'][0]['weather'][0]['main'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(16),
                    ),
                    elevation: 10,

                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Center(
                              child: Text(
                                "$temp\u00B0c",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              size: 50,
                            ),
                            Text('$currentSky', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Weather Forecast",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    itemCount: 39,
                    itemBuilder: (context, index) {
                      final hourlyTime = DateTime.parse(
                        data['list'][index + 1]['dt_txt'],
                      );
                      final hourlyTemp =
                          (((data['list'][index + 1]['main']['temp'] as num)
                                      .toDouble()) -
                                  273.15)
                              .roundToDouble();
                      final hourlyCurrentSky =
                          data['list'][index + 1]['weather'][0]['main'];

                      return HourlyForcastItem(
                        time: index == 0
                            ? "Now"
                            : DateFormat.j().format(hourlyTime),
                        icon:
                            hourlyCurrentSky == 'Clouds' || currentSky == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        val: '$hourlyTemp',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfoItem(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        val: '$humidity',
                      ),
                      AdditionalInfoItem(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        val: '$wind_speed',
                      ),
                      AdditionalInfoItem(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        val: '$pressure',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String val;
  const AdditionalInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.val,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 42),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ],
    );
  }
}

class HourlyForcastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String val;
  const HourlyForcastItem({
    super.key,
    required this.time,
    required this.icon,
    required this.val,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(val),
            ],
          ),
        ),
      ),
    );
  }
}

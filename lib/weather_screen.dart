import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:weather_app/Additional_info.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/secerts.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0;
  String location = "Delhi"; // Default location

  final border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Color.fromARGB(118, 125, 129, 129),
      style: BorderStyle.solid,
      width: 1,
      strokeAlign: BorderSide.strokeAlignCenter,
    ),
    borderRadius: BorderRadius.all(Radius.circular(40)),
  );

  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = location; // Set initial text
    getWeatherUpdate();
  }

  Future getWeatherUpdate() async {
    try {
      // Use the current location value
      final res = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?q=$location&APPID=$openWeatherAPIKey",
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw "An error occurred";
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  void _searchWeather() {
    if (textEditingController.text.isNotEmpty) {
      setState(() {
        location = textEditingController.text; // Update location
      });
    }
  }

  double kelvinToCelsius(double kelvin) {
    double celsius = kelvin - 273.15;
    return double.parse(celsius.toStringAsFixed(2));
  }

  String formatTime(String dtTxt) {
    return dtTxt.split(' ')[1].substring(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Weather App",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800,color: const Color.fromARGB(255, 230, 232, 234)),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                // Refresh with current location
                getWeatherUpdate();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      //Body
      body: Column(
        children: [
          // Search bar - outside FutureBuilder so it's always visible
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: TextField(
              controller: textEditingController, // Use the declared controller
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Color.fromARGB(255, 248, 249, 249)),
                prefixIcon: Icon(
                  Icons.search_sharp,
                  color: Color.fromARGB(255, 50, 51, 50),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchWeather, // Add search button
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 65, 64, 64),
                focusedBorder: border,
                enabledBorder: border,
              ),
              onSubmitted: (value) => _searchWeather(), // Search on enter
            ),
          ),
          Expanded(
            // Use Expanded to take remaining space
            child: FutureBuilder(
              future: getWeatherUpdate(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final data = snapshot.data;
                double currTemp = kelvinToCelsius(
                  data['list'][0]['main']['temp'],
                );
                String currSky = data['list'][0]['weather'][0]['main'];

                double humidity = data['list'][0]['main']['humidity'];
                double windSpeed = data['list'][0]['wind']['speed'];
                double pressure = data['list'][0]['main']['pressure'];

                return SingleChildScrollView(
                  // SingleChildScrollView for the weather content
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Weather information
                        SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: Card(
                            surfaceTintColor: Colors.grey,
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20),
                                      Text(
                                        "$currTemp °C",
                                        style: TextStyle(fontSize: 32),
                                      ),
                                      SizedBox(height: 15),
                                      currSky == 'Clouds' || currSky == 'Rain'
                                          ? Icon(
                                              Icons.cloud,
                                              size: 55,
                                              color: const Color.fromARGB(
                                                255,
                                                129,
                                                124,
                                                124,
                                              ),
                                            )
                                          : Icon(
                                              Icons.sunny,
                                              size: 55,
                                              color: Colors.yellowAccent,
                                            ),
                                      SizedBox(height: 15),
                                      Text(
                                        currSky,
                                        style: TextStyle(fontSize: 32),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        //weather cards
                        Text(
                          "Hourly Forecast",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            itemCount: 10,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return HourlyShownCard(
                                time: formatTime(
                                  data['list'][index + 1]['dt_txt'],
                                ),
                                icon:
                                    data['list'][index +
                                                1]['weather'][0]['main'] ==
                                            'Clouds' ||
                                        data['list'][index +
                                                1]['weather'][0]['main'] ==
                                            'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                value:
                                    "${kelvinToCelsius(data['list'][index + 1]['main']['temp'])}°C",
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 30),
                        // Additional Information
                        Text(
                          "Additional Information",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AdditionalInfoItems(
                              icon: Icons.water_drop,
                              label: "Humidity",
                              value: "$humidity",
                            ),
                            AdditionalInfoItems(
                              icon: Icons.wind_power_sharp,
                              label: "Windspeed",
                              value: "$windSpeed",
                            ),
                            AdditionalInfoItems(
                              icon: Icons.umbrella,
                              label: "pressure",
                              value: "$pressure",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

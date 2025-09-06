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
  @override
  void initState() {
    super.initState();
    getWeatherUpdate();
  }

  Future getWeatherUpdate() async {
    try {
      String location = "Delhi";
      final res = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?q=$location&APPID=$openWeatherAPIKey",
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw "An error occured";
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  double kelvinToCelsius(double kelvin) {
    double celsius = kelvin - 273.15;
    return double.parse(celsius.toStringAsFixed(2));
  }

  String formatTime(String dtTxt) {
    // Extract time from "2023-10-15 15:00:00" format
    return dtTxt.split(' ')[1].substring(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Weather App",
            style: TextStyle(fontSize: 25, color: Colors.blue),
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              
            });
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      //Body
      body: FutureBuilder(
        future: getWeatherUpdate(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data;
          double currTemp = kelvinToCelsius(data['list'][0]['main']['temp']);
          String currSky = data['list'][0]['weather'][0]['main'];

          double humidity = data['list'][0]['main']['humidity'];
          double windSpeed = data['list'][0]['wind']['speed'];
          double pressure = data['list'][0]['main']['pressure'];
      
          return SingleChildScrollView(
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
                                currSky == 'Clouds' || currSky == 'Rain' ?
                                Icon(Icons.cloud, size: 55,color: const Color.fromARGB(255, 129, 124, 124),) : Icon(Icons.sunny,size: 55,color: Colors.yellowAccent,),
                                SizedBox(height: 15),
                                Text(currSky, style: TextStyle(fontSize: 32)),
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
                    "Weather Forecast",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     spacing: 5,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       for( int i=0;i<5;i++)
                  //       HourlyShownCard(
                  //         time: formatTime(data['list'][i+1]['dt_txt']),
                  //         icon: data['list'][i+1]['weather'][0]['main'] == 'Clouds' || data['list'][i+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
                  //         value: "${kelvinToCelsius(data['list'][i+1]['main']['temp'])}°C",
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  //To improve the performance we used list view
                  SizedBox(
                    height: 120,
                    // width: 80,
                    child: ListView.builder(
                      itemCount: 10,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return HourlyShownCard(time: formatTime(data['list'][index+1]['dt_txt']),
                           icon: data['list'][index+1]['weather'][0]['main'] == 'Clouds' || data['list'][index+1]['weather'][0]['main'] == 'Rain' ? 
                           Icons.cloud : Icons.sunny,
                            value: "${kelvinToCelsius(data['list'][index+1]['main']['temp'])}°C",);
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  // Additional Information
                  Text(
                    "Additional Information",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
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
    );
  }
}

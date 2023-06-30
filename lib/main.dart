import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:meteo/class/position.dart';
import 'package:meteo/class/weather.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Météo'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dioPosition = Dio();
  final dioWheather = Dio();

  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future<Position?> getPositonHttp(String city) async {
    dioPosition.options.headers["X-Api-Key"] = dotenv.env['CITY_API_KEY'];
    dioPosition.options.headers['content-Type'] = 'application/json';

    try {
      final response = await dioPosition
          .get('https://api.api-ninjas.com/v1/city?name=$city');

      if (response.statusCode == 200) {
        return Position.fromJson(response.data![0]);
      }
    } catch (e) {
      print(e);

      rethrow;
    }
  }

  Future<Weather?> getWeatherHttp(double long, double lat) async {
    final response = await dioWheather.get(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=${dotenv.env['METEO_API_KEY']}');

    return Weather.fromJson(response.data!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Entrer le nom d'une ville"),
          TextField(
            controller: myController,
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  children: [
                    Text(
                      myController.text,
                      style: const TextStyle(fontSize: 20),
                    ),
                    FutureBuilder(
                        future: getPositonHttp(myController.text),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                FutureBuilder(
                                  future: getWeatherHttp(
                                      snapshot.data!.longitude,
                                      snapshot.data!.latitude),
                                  builder: (contextWeather, snapshotWeather) {
                                    if (snapshot.isDefinedAndNotNull) {
                                      double resTemperature =
                                          snapshotWeather.data!.temperature -
                                              273.15;
                                      return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                                'https://openweathermap.org/img/wn/${snapshotWeather.data!.icon}@2x.png',
                                                width: 150),
                                            Text("${resTemperature.round()} °")
                                          ]);
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                )
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return const Text("Error API");
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),
                  ],
                ),
              );
            },
          );
        },
        tooltip: 'Show me the value!',
        child: const Icon(Icons.text_fields),
      ),
    );
  }
}

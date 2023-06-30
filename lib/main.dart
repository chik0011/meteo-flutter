import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:meteo/class/position.dart';

Future main() async {
  // To load the .env file contents into dotenv.
  // NOTE: fileName defaults to .env and can be omitted in this case.
  // Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

/*void main() {
  runApp(const MyApp());
}*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  final dio = Dio();
  late Future<Position> futurePosition;
  late Position _position;

  @override
  void initState() {
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<Position?> getPositonHttp() async {
    dio.options.headers["X-Api-Key"] = dotenv.env['CITY_API_KEY'];
    dio.options.headers['content-Type'] = 'application/json';

    try {
      final response =
          await dio.get('https://api.api-ninjas.com/v1/city?name=Metz');

      if (response.statusCode == 200) {
        return Position.fromJson(response.data![0]);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  void getWeatherHttp() async {
    final response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather?lat=44.34&lon=10.99&appid=${dotenv.env['METEO_API_KEY']}');
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
            future: getPositonHttp(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.name);
              } else if (snapshot.hasError) {
                return const Text("Error API");
              } else {
                return const CircularProgressIndicator();
              }
            }),
      ),
    );
  }
}

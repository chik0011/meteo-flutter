class Weather {
  final String icon;
  final double temperature;

  const Weather({
    required this.icon,
    required this.temperature,
  });

  factory Weather.fromJson(json) {
    Weather res = Weather(
        icon: json['weather'][0]['icon'], temperature: json['main']['temp']);
    return res;
  }
}

class Position {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final int population;
  final bool isCapital;

  const Position({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.population,
    required this.isCapital,
  });

  factory Position.fromJson(json) {
    return Position(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      country: json['country'],
      population: json['population'],
      isCapital: json['is_capital'],
    );
  }
}

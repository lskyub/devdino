class LocationData {
  final double latitude;
  final double longitude;
  final String location;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': latitude,
      'lon': longitude,
      'location': location,
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['lat'],
      longitude: map['lon'],
      location: map['location'],
    );
  }

  @override
  String toString() {
    return 'LocationData(latitude: $latitude, longitude: $longitude, location: $location)';
  }
} 
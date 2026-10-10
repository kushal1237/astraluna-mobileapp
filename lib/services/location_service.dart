class CityLocation {
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final String flagEmoji;

  const CityLocation({
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.flagEmoji,
  });
}

class LocationService {
  static const List<CityLocation> presetCities = [
    // Nepal Locations (including Chitwan!)
    CityLocation(cityName: 'Chitwan', country: 'Nepal', latitude: 27.5291, longitude: 84.3542, flagEmoji: '🇳🇵'),
    CityLocation(cityName: 'Kathmandu', country: 'Nepal', latitude: 27.7172, longitude: 85.3240, flagEmoji: '🇳🇵'),
    CityLocation(cityName: 'Pokhara', country: 'Nepal', latitude: 28.2096, longitude: 83.9856, flagEmoji: '🇳🇵'),
    CityLocation(cityName: 'Lalitpur', country: 'Nepal', latitude: 27.6644, longitude: 85.3188, flagEmoji: '🇳🇵'),
    CityLocation(cityName: 'Bhaktapur', country: 'Nepal', latitude: 27.6710, longitude: 85.4298, flagEmoji: '🇳🇵'),
    CityLocation(cityName: 'Biratnagar', country: 'Nepal', latitude: 26.4525, longitude: 87.2718, flagEmoji: '🇳🇵'),
    CityLocation(cityName: 'Lumbini', country: 'Nepal', latitude: 27.4795, longitude: 83.2758, flagEmoji: '🇳🇵'),
    CityLocation(cityName: 'Dharan', country: 'Nepal', latitude: 26.8124, longitude: 87.2834, flagEmoji: '🇳🇵'),
    CityLocation(cityName: 'Butwal', country: 'Nepal', latitude: 27.7006, longitude: 83.4484, flagEmoji: '🇳🇵'),

    // India & South Asia
    CityLocation(cityName: 'New Delhi', country: 'India', latitude: 28.6139, longitude: 77.2090, flagEmoji: '🇮🇳'),
    CityLocation(cityName: 'Mumbai', country: 'India', latitude: 19.0760, longitude: 72.8777, flagEmoji: '🇮🇳'),
    CityLocation(cityName: 'Bengaluru', country: 'India', latitude: 12.9716, longitude: 77.5946, flagEmoji: '🇮🇳'),
    CityLocation(cityName: 'Kolkata', country: 'India', latitude: 22.5726, longitude: 88.3639, flagEmoji: '🇮🇳'),
    CityLocation(cityName: 'Dhaka', country: 'Bangladesh', latitude: 23.8103, longitude: 90.4125, flagEmoji: '🇧🇩'),
    CityLocation(cityName: 'Colombo', country: 'Sri Lanka', latitude: 6.9271, longitude: 79.8612, flagEmoji: '🇱🇰'),

    // East & Southeast Asia
    CityLocation(cityName: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503, flagEmoji: '🇯🇵'),
    CityLocation(cityName: 'Kyoto', country: 'Japan', latitude: 35.0116, longitude: 135.7681, flagEmoji: '🇯🇵'),
    CityLocation(cityName: 'Beijing', country: 'China', latitude: 39.9042, longitude: 116.4074, flagEmoji: '🇨🇳'),
    CityLocation(cityName: 'Shanghai', country: 'China', latitude: 31.2304, longitude: 121.4737, flagEmoji: '🇨🇳'),
    CityLocation(cityName: 'Seoul', country: 'South Korea', latitude: 37.5665, longitude: 126.9780, flagEmoji: '🇰🇷'),
    CityLocation(cityName: 'Singapore', country: 'Singapore', latitude: 1.3521, longitude: 103.8198, flagEmoji: '🇸🇬'),
    CityLocation(cityName: 'Bangkok', country: 'Thailand', latitude: 13.7563, longitude: 100.5018, flagEmoji: '🇹🇭'),

    // Middle East
    CityLocation(cityName: 'Dubai', country: 'UAE', latitude: 25.2048, longitude: 55.2708, flagEmoji: '🇦🇪'),

    // Europe
    CityLocation(cityName: 'London', country: 'UK', latitude: 51.5074, longitude: -0.1278, flagEmoji: '🇬🇧'),
    CityLocation(cityName: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522, flagEmoji: '🇫🇷'),
    CityLocation(cityName: 'Berlin', country: 'Germany', latitude: 52.5200, longitude: 13.4050, flagEmoji: '🇩🇪'),

    // Americas & Oceania
    CityLocation(cityName: 'New York', country: 'USA', latitude: 40.7128, longitude: -74.0060, flagEmoji: '🇺🇸'),
    CityLocation(cityName: 'Los Angeles', country: 'USA', latitude: 34.0522, longitude: -118.2437, flagEmoji: '🇺🇸'),
    CityLocation(cityName: 'São Paulo', country: 'Brazil', latitude: -23.5505, longitude: -46.6333, flagEmoji: '🇧🇷'),
    CityLocation(cityName: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093, flagEmoji: '🇦🇺'),
  ];

  static CityLocation defaultLocation = presetCities[0]; // Chitwan, Nepal
}

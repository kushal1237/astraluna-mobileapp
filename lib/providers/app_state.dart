import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import '../services/community_chat_service.dart';
import '../models/nasa_photo.dart';

class AppState extends ChangeNotifier {
  CityLocation _currentLocation = LocationService.defaultLocation;
  bool _isAstroRedMode = false;
  int _selectedBottomNavIndex = 0;

  final Set<String> _bookmarkedPhotoIds = {};
  final Set<String> _favoriteObjectIds = {};

  final CommunityChatService chatService = CommunityChatService();

  CityLocation get currentLocation => _currentLocation;
  bool get isAstroRedMode => _isAstroRedMode;
  int get selectedBottomNavIndex => _selectedBottomNavIndex;

  Set<String> get bookmarkedPhotoIds => _bookmarkedPhotoIds;
  Set<String> get favoriteObjectIds => _favoriteObjectIds;

  AppState() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isAstroRedMode = prefs.getBool('astraluna_red_mode') ?? false;

    final savedCity = prefs.getString('astraluna_saved_city');
    if (savedCity != null) {
      final found = LocationService.presetCities.firstWhere(
        (c) => c.cityName == savedCity,
        orElse: () => LocationService.defaultLocation,
      );
      _currentLocation = found;
    }

    await chatService.init();
    notifyListeners();
  }

  void setCityLocation(CityLocation city) async {
    _currentLocation = city;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('astraluna_saved_city', city.cityName);
  }

  void toggleAstroRedMode(bool value) async {
    _isAstroRedMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('astraluna_red_mode', value);
  }

  void setBottomNavIndex(int index) {
    _selectedBottomNavIndex = index;
    notifyListeners();
  }

  void togglePhotoBookmark(NasaPhoto photo) {
    if (_bookmarkedPhotoIds.contains(photo.id)) {
      _bookmarkedPhotoIds.remove(photo.id);
    } else {
      _bookmarkedPhotoIds.add(photo.id);
    }
    notifyListeners();
  }

  bool isPhotoBookmarked(String photoId) => _bookmarkedPhotoIds.contains(photoId);

  void toggleFavoriteObject(String objectId) {
    if (_favoriteObjectIds.contains(objectId)) {
      _favoriteObjectIds.remove(objectId);
    } else {
      _favoriteObjectIds.add(objectId);
    }
    notifyListeners();
  }

  bool isObjectFavorite(String objectId) => _favoriteObjectIds.contains(objectId);
}

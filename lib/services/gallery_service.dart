import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nasa_photo.dart';

class GalleryService {
  static const String _apodUrl = 'https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY';

  /// Fetches today's NASA APOD image with fallback
  Future<NasaPhoto> fetchApod() async {
    try {
      final response = await http.get(Uri.parse(_apodUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NasaPhoto.fromApodJson(data);
      }
    } catch (_) {}
    return _getFallbackApod();
  }

  /// Fetches NASA Public Domain Photo Gallery
  Future<List<NasaPhoto>> fetchNasaLibrary(String query) async {
    try {
      final url = 'https://images-api.nasa.gov/search?q=${Uri.encodeComponent(query)}&media_type=image';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['collection']?['items'] as List? ?? [];
        if (items.isNotEmpty) {
          final list = items.take(12).map((item) => NasaPhoto.fromLibraryJson(item)).toList();
          return list;
        }
      }
    } catch (_) {}
    return _getFallbackGallery();
  }

  NasaPhoto _getFallbackApod() {
    return const NasaPhoto(
      id: 'apod_today',
      title: 'Carina Nebula: Pillars of Cosmic Creation',
      explanation: 'Captured by NASA’s James Webb Space Telescope in infrared light, this dramatic image reveals emerging stellar nurseries and individual stars that were previously hidden in visible light.',
      url: 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564',
      hdUrl: 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564',
      credit: 'Credit: NASA / ESA / CSA / STScI / Webb Team',
      date: 'Today',
      isApod: true,
    );
  }

  List<NasaPhoto> _getFallbackGallery() {
    return const [
      NasaPhoto(
        id: 'gal_1',
        title: 'Andromeda Galaxy (M31) Spiral Arms',
        explanation: 'Our nearest major galactic neighbor containing over one trillion stars located 2.5 million light-years away.',
        url: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86',
        hdUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86',
        credit: 'Credit: NASA / JPL-Caltech / Subaru Observatory',
        date: '2026-08-15',
      ),
      NasaPhoto(
        id: 'gal_2',
        title: 'Saturn Rings in High Contrast',
        explanation: 'Intricate structure of Saturn ring system photographed by Cassini orbiter during grand finale orbits.',
        url: 'https://images.unsplash.com/photo-1614728894747-a83421e2b9c9',
        hdUrl: 'https://images.unsplash.com/photo-1614728894747-a83421e2b9c9',
        credit: 'Credit: NASA / Cassini Imaging Team',
        date: '2026-07-20',
      ),
      NasaPhoto(
        id: 'gal_3',
        title: 'Orion Nebula Star Birth Region',
        explanation: 'The closest massive star-forming region to Earth, located in the constellation of Orion.',
        url: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa',
        hdUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa',
        credit: 'Credit: NASA / Hubble Heritage Team',
        date: '2026-06-11',
      ),
      NasaPhoto(
        id: 'gal_4',
        title: 'Earthrise from Lunar Orbit',
        explanation: 'Iconic view of Earth rising over lunar horizon captured during orbital recon mission.',
        url: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa',
        hdUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa',
        credit: 'Credit: NASA / LRO Science Team',
        date: '2026-05-04',
      ),
      NasaPhoto(
        id: 'gal_5',
        title: 'James Webb Southern Ring Nebula (NGC 3132)',
        explanation: 'Expanding cloud of gas surrounding a dying star, captured in unprecedented infrared detail by JWST.',
        url: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
        hdUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
        credit: 'Credit: NASA / ESA / CSA / STScI',
        date: '2026-04-18',
      ),
      NasaPhoto(
        id: 'gal_6',
        title: 'Jupiter Great Red Spot & Cloud Belts',
        explanation: 'High-resolution composite of Jupiter’s turbulent atmosphere showing the centuries-old anticyclonic storm.',
        url: 'https://images.unsplash.com/photo-1614732414444-096e5f1122d5',
        hdUrl: 'https://images.unsplash.com/photo-1614732414444-096e5f1122d5',
        credit: 'Credit: NASA / JPL-Caltech / SwRI / Juno',
        date: '2026-03-29',
      ),
    ];
  }
}

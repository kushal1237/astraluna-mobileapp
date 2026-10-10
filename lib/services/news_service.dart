import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/space_news.dart';

class NewsService {
  static const String _snapiUrl = 'https://api.spaceflightnewsapi.net/v4/articles/?limit=12';

  /// Fetches spaceflight news from SNAPI v4 with fallback
  Future<List<SpaceNewsArticle>> fetchNewsArticles() async {
    try {
      final response = await http.get(Uri.parse(_snapiUrl)).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        if (results.isNotEmpty) {
          final articles = results.map((item) => SpaceNewsArticle.fromJson(item)).toList();
          // Inject an admin announcement post at top
          articles.insert(0, _getAdminAnnouncement());
          return articles;
        }
      }
    } catch (_) {
      // Network fallback
    }
    final fallbackList = _getFallbackNews();
    fallbackList.insert(0, _getAdminAnnouncement());
    return fallbackList;
  }

  SpaceNewsArticle _getAdminAnnouncement() {
    return SpaceNewsArticle(
      id: 'admin_announcement_1',
      title: '📢 Astraluna Announcement: Stargazing Gathering in Pokhara & Kathmandu',
      summary: 'Astraluna Nepal Community is hosting a clear-sky rooftop star party this weekend! Bring your telescopes or binoculars.',
      newsSite: 'Astraluna Team',
      articleUrl: 'https://astraluna.com.np',
      imageUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86',
      publishedAt: DateTime.now(),
      isAdminPost: true,
    );
  }

  List<SpaceNewsArticle> _getFallbackNews() {
    final now = DateTime.now();
    return [
      SpaceNewsArticle(
        id: 'news_1',
        title: 'James Webb Telescope Detects Atmospheric Water Vapor on Rocky Exoplanet',
        summary: 'Astronomers using NASA’s James Webb Space Telescope have discovered signatures of water vapor surrounding a warm super-Earth. The observation marks a major step forward in analyzing habitable zones beyond our solar system.',
        newsSite: 'Space.com',
        articleUrl: 'https://www.space.com',
        imageUrl: 'https://images.unsplash.com/photo-1614728894747-a83421e2b9c9',
        publishedAt: now.subtract(const Duration(hours: 3)),
      ),
      SpaceNewsArticle(
        id: 'news_2',
        title: 'ISRO Announces Next Gaganyaan Uncrewed Test Flight Target Date',
        summary: 'The Indian Space Research Organisation has finalized prep for its second uncrewed orbital mission. The flight will validate human-rated launch escape thrusters and capsule recovery systems.',
        newsSite: 'Spaceflight Now',
        articleUrl: 'https://spaceflightnow.com',
        imageUrl: 'https://images.unsplash.com/photo-1541185933-ef5d8ed016c2',
        publishedAt: now.subtract(const Duration(hours: 9)),
      ),
      SpaceNewsArticle(
        id: 'news_3',
        title: 'Giant Sunspot Region Facing Earth Triggers Strong Solar Flares and Auroras',
        summary: 'A massive active solar region has emitted multiple X-class solar flares over the past 24 hours. Geomagnetic storms could produce visible aurora lights in high and mid-latitude regions.',
        newsSite: 'Universe Today',
        articleUrl: 'https://universetoday.com',
        imageUrl: 'https://images.unsplash.com/photo-1532635241-17e820acc59f',
        publishedAt: now.subtract(const Duration(hours: 18)),
      ),
    ];
  }
}

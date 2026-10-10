import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../services/news_service.dart';
import '../services/gallery_service.dart';
import '../models/space_news.dart';
import '../models/nasa_photo.dart';

class ExploreScreen extends StatefulWidget {
  final AppState appState;

  const ExploreScreen({super.key, required this.appState});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NewsService _newsService = NewsService();
  final GalleryService _galleryService = GalleryService();

  List<SpaceNewsArticle> _newsArticles = [];
  NasaPhoto? _apodPhoto;
  List<NasaPhoto> _galleryPhotos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final newsFuture = _newsService.fetchNewsArticles();
    final apodFuture = _galleryService.fetchApod();
    final galleryFuture = _galleryService.fetchNasaLibrary('nebula');

    final results = await Future.wait([newsFuture, apodFuture, galleryFuture]);

    if (mounted) {
      setState(() {
        _newsArticles = results[0] as List<SpaceNewsArticle>;
        _apodPhoto = results[1] as NasaPhoto;
        _galleryPhotos = results[2] as List<NasaPhoto>;
        _isLoading = false;
      });
    }
  }

  void _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAstro = widget.appState.isAstroRedMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore & Discover'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isAstro ? Colors.redAccent : theme.colorScheme.primary,
          labelColor: isAstro ? Colors.redAccent : theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Space News', icon: Icon(Icons.newspaper, size: 18)),
            Tab(text: 'Photo Gallery', icon: Icon(Icons.photo_library, size: 18)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Space News Feed Tab
                _buildNewsTab(theme, isAstro),

                // Photo Gallery Tab
                _buildGalleryTab(theme, isAstro),
              ],
            ),
    );
  }

  Widget _buildNewsTab(ThemeData theme, bool isAstro) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _newsArticles.length,
      itemBuilder: (context, index) {
        final article = _newsArticles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  article.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[900]!, Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 36, color: Colors.amber),
                          SizedBox(height: 6),
                          Text(
                            'Astraluna Space News Feed',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: article.isAdminPost
                                ? Colors.amber.withOpacity(0.2)
                                : (isAstro ? Colors.redAccent : theme.colorScheme.primary).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.newsSite,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: article.isAdminPost
                                  ? Colors.amber
                                  : (isAstro ? Colors.redAccent : theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        Text(
                          article.publishedAt.toString().split(' ').first,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.summary,
                      style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAstro ? Colors.redAccent : theme.colorScheme.primary,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.open_in_browser, size: 18),
                        label: Text('Read Full Article on ${article.newsSite}'),
                        onPressed: () => _openUrl(article.articleUrl),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGalleryTab(ThemeData theme, bool isAstro) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // APOD Hero Section
          if (_apodPhoto != null) ...[
            Text(
              "NASA ASTRONOMY PICTURE OF THE DAY",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isAstro ? Colors.redAccent : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildPhotoCard(_apodPhoto!, theme, isAstro, isApod: true),
            const SizedBox(height: 24),
          ],

          Text(
            "NASA DEEP SPACE IMAGE GALLERY",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isAstro ? Colors.redAccent : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _galleryPhotos.length,
            itemBuilder: (context, index) {
              final photo = _galleryPhotos[index];
              return _buildPhotoCard(photo, theme, isAstro);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(NasaPhoto photo, ThemeData theme, bool isAstro, {bool isApod = false}) {
    final isBookmarked = widget.appState.isPhotoBookmarked(photo.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              photo.url,
              height: isApod ? 240 : 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 180,
                color: Colors.grey[800],
                child: const Center(child: Icon(Icons.image, size: 50)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // Copyright Metadata & Photographer Credit Line
                Text(
                  photo.credit,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.amber),
                ),
                const SizedBox(height: 8),
                Text(
                  photo.explanation,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Action Buttons: Save/Bookmark & Share
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: isBookmarked ? 'Remove Bookmark' : 'Bookmark Image',
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        widget.appState.togglePhotoBookmark(photo);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isBookmarked ? 'Bookmark removed' : 'Saved to favorites!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Share Image',
                      icon: const Icon(Icons.share, color: Colors.grey),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sharing "${photo.title}" link...')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

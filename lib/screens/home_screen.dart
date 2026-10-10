import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../services/astronomy_engine.dart';
import '../services/launch_service.dart';
import '../services/news_service.dart';
import '../models/rocket_launch.dart';
import '../models/iss_pass.dart';
import '../models/space_news.dart';
import '../widgets/location_picker_dialog.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LaunchService _launchService = LaunchService();
  final NewsService _newsService = NewsService();

  RocketLaunch? _nextLaunch;
  IssPass? _nextIssPass;
  SpaceNewsArticle? _topArticle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final city = widget.appState.currentLocation;

    final launchesFuture = _launchService.fetchUpcomingLaunches();
    final passesFuture = _launchService.fetchIssPasses(city.latitude, city.longitude);
    final newsFuture = _newsService.fetchNewsArticles();

    final results = await Future.wait([launchesFuture, passesFuture, newsFuture]);

    if (mounted) {
      final launches = results[0] as List<RocketLaunch>;
      final passes = results[1] as List<IssPass>;
      final news = results[2] as List<SpaceNewsArticle>;

      setState(() {
        _nextLaunch = launches.isNotEmpty ? launches.first : null;
        _nextIssPass = passes.isNotEmpty ? passes.first : null;
        _topArticle = news.isNotEmpty ? news.first : null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final city = widget.appState.currentLocation;
    final isAstro = widget.appState.isAstroRedMode;

    final moonData = AstronomyEngine.calculateMoonData(
      DateTime.now(),
      city.latitude,
      city.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'ASTRALUNA',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: isAstro ? Colors.redAccent : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isAstro ? Colors.redAccent : theme.colorScheme.primary).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Red Night-Vision Mode',
            icon: Icon(
              Icons.remove_red_eye,
              color: isAstro ? Colors.redAccent : Colors.grey,
            ),
            onPressed: () {
              widget.appState.toggleAstroRedMode(!isAstro);
            },
          ),
          IconButton(
            tooltip: 'Select Location',
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(city.flagEmoji, style: const TextStyle(fontSize: 18)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => LocationPickerDialog(appState: widget.appState),
              ).then((_) => _loadDashboardData());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: LinearProgressIndicator(),
                ),
              // Tagline Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stars for everyone',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: isAstro ? Colors.red[300] : Colors.amber,
                    ),
                  ),
                  Text(
                    '${city.cityName}, ${city.country}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hero Celestial Highlight Banner
              _buildHeroBanner(theme, isAstro),

              const SizedBox(height: 20),

              // Moon Tracker Card
              _buildMoonCard(moonData, theme, isAstro),

              const SizedBox(height: 20),

              // ISS Pass Countdown Card
              _buildIssCard(theme, isAstro),

              const SizedBox(height: 20),

              // Next Launch Card
              _buildNextLaunchCard(theme, isAstro),

              const SizedBox(height: 20),

              // Space News Highlights Card
              _buildTopNewsCard(theme, isAstro),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(ThemeData theme, bool isAstro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAstro
              ? [const Color(0xFF330000), const Color(0xFF1F0000)]
              : [const Color(0xFF1E1B4B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAstro ? Colors.redAccent : theme.colorScheme.primary.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAstro ? Colors.red : theme.colorScheme.primary).withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                "TONIGHT'S SKY HIGHLIGHT",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isAstro ? Colors.redAccent : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Jupiter & Moon Conjunction',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Jupiter shines brightly right beside the Waxing Gibbous Moon high in the East-Southeast sky after sunset!',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAstro ? Colors.redAccent : theme.colorScheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.explore, size: 18),
            label: const Text('Open Local Sky Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              widget.appState.setBottomNavIndex(1); // Navigate to Sky Screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoonCard(MoonData moon, ThemeData theme, bool isAstro) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(moon.phaseIcon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moon.phaseName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Age: ${moon.ageDays} days',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAstro ? Colors.red.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isAstro ? Colors.redAccent : Colors.amber),
                  ),
                  child: Text(
                    '${moon.illuminationPercent}% Lit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAstro ? Colors.redAccent : Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeDetail('Moonrise', moon.moonriseTime, Icons.wb_twilight),
                _buildTimeDetail('Moonset', moon.moonsetTime, Icons.nightlight_round),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDetail(String label, String time, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildIssCard(ThemeData theme, bool isAstro) {
    if (_nextIssPass == null) {
      return const SizedBox.shrink();
    }

    final pass = _nextIssPass!;
    final diffMinutes = pass.startTime.difference(DateTime.now()).inMinutes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('🛰️', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text(
                      'ISS Pass Predictor',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'in ${diffMinutes ~/ 60}h ${diffMinutes % 60}m',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Space Station passes at Max Altitude ${pass.maxAltitudeDegrees.toInt()}° (${pass.startDirection} → ${pass.endDirection}).',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Duration: ${pass.durationFormatted}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Brightness: Mag ${pass.brightnessMagnitude}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextLaunchCard(ThemeData theme, bool isAstro) {
    if (_nextLaunch == null) return const SizedBox.shrink();

    final launch = _nextLaunch!;
    final diff = launch.launchTime.difference(DateTime.now());
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🚀', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    launch.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(launch.provider, style: TextStyle(fontSize: 13, color: isAstro ? Colors.redAccent : theme.colorScheme.primary)),
                Text('T-minus ${hours}h ${mins}m', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
            if (launch.plumeVisibleInLocation) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wb_twilight, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        launch.plumeAlertReason,
                        style: const TextStyle(fontSize: 11, color: Colors.amberAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopNewsCard(ThemeData theme, bool isAstro) {
    if (_topArticle == null) return const SizedBox.shrink();

    final article = _topArticle!;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                article.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 120,
                  color: Colors.grey[800],
                  child: const Center(child: Icon(Icons.newspaper, size: 40)),
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
                    Text(
                      article.newsSite,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAstro ? Colors.redAccent : theme.colorScheme.primary,
                      ),
                    ),
                    const Text('Space News', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  article.summary,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

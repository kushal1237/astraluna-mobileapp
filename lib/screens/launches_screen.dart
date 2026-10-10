import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../services/launch_service.dart';
import '../models/rocket_launch.dart';
import '../models/iss_pass.dart';

class LaunchesScreen extends StatefulWidget {
  final AppState appState;

  const LaunchesScreen({super.key, required this.appState});

  @override
  State<LaunchesScreen> createState() => _LaunchesScreenState();
}

class _LaunchesScreenState extends State<LaunchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LaunchService _launchService = LaunchService();

  List<RocketLaunch> _upcomingLaunches = [];
  List<RocketLaunch> _recentLaunches = [];
  List<IssPass> _issPasses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final city = widget.appState.currentLocation;

    final upcoming = await _launchService.fetchUpcomingLaunches();
    final recent = await _launchService.fetchRecentLaunches();
    final passes = await _launchService.fetchIssPasses(city.latitude, city.longitude);

    if (mounted) {
      setState(() {
        _upcomingLaunches = upcoming;
        _recentLaunches = recent;
        _issPasses = passes;
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
        title: const Text('Launches & Satellites'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isAstro ? Colors.redAccent : theme.colorScheme.primary,
          labelColor: isAstro ? Colors.redAccent : theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Upcoming', icon: Icon(Icons.rocket_launch, size: 18)),
            Tab(text: 'Recent', icon: Icon(Icons.history, size: 18)),
            Tab(text: 'ISS Passes', icon: Icon(Icons.satellite_alt, size: 18)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLaunchList(_upcomingLaunches, theme, isAstro, isUpcoming: true),
                _buildLaunchList(_recentLaunches, theme, isAstro, isUpcoming: false),
                _buildIssPassList(_issPasses, theme, isAstro),
              ],
            ),
    );
  }

  Widget _buildLaunchList(List<RocketLaunch> launches, ThemeData theme, bool isAstro, {required bool isUpcoming}) {
    if (launches.isEmpty) {
      return const Center(child: Text('No launch data available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: launches.length,
      itemBuilder: (context, index) {
        final launch = launches[index];
        final diff = launch.launchTime.difference(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (launch.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    launch.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      height: 120,
                      color: Colors.grey[800],
                      child: const Center(child: Icon(Icons.rocket, size: 40)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isAstro ? Colors.redAccent : theme.colorScheme.primary).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            launch.provider,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isAstro ? Colors.redAccent : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Text(
                          isUpcoming
                              ? (diff.isNegative
                                  ? 'Launching Soon'
                                  : 'T-${diff.inHours}h ${diff.inMinutes % 60}m')
                              : 'Completed',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isUpcoming ? Colors.amber : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      launch.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rocket: ${launch.rocketModel} • Pad: ${launch.padName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Location: ${launch.padLocation}',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),

                    const SizedBox(height: 12),
                    // Enriched Technical Launch Specifications
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color?.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTechDetail('Target Orbit', launch.targetOrbit, Icons.public),
                          const SizedBox(height: 6),
                          _buildTechDetail('Payload Mass', launch.payloadMass, Icons.scale),
                          const SizedBox(height: 6),
                          _buildTechDetail('Booster Reuse', launch.boosterStatus, Icons.autorenew),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      launch.missionDescription,
                      style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                    ),

                    // Trajectory Plume Visibility Alert
                    if (launch.plumeVisibleInLocation) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.withOpacity(0.6)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wb_twilight, color: Colors.amber, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                launch.plumeAlertReason,
                                style: const TextStyle(fontSize: 12, color: Colors.amberAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.live_tv, size: 18),
                        label: const Text('Watch Live Stream / Broadcast'),
                        onPressed: () => _openUrl(launch.webstreamUrl),
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

  Widget _buildTechDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.cyan),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildIssPassList(List<IssPass> passes, ThemeData theme, bool isAstro) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: passes.length,
      itemBuilder: (context, index) {
        final pass = passes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
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
                        const Text('🛰️', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          'Pass #${index + 1}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (pass.isBrightPass)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SUPER BRIGHT PASS',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Date & Time: ${pass.startTime.toString().split('.').first}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPassDetail('Max Altitude', '${pass.maxAltitudeDegrees.toInt()}°'),
                    _buildPassDetail('Duration', pass.durationFormatted),
                    _buildPassDetail('Trajectory', '${pass.startDirection} → ${pass.endDirection}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPassDetail(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

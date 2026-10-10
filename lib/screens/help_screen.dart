import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../widgets/location_picker_dialog.dart';

class HelpScreen extends StatelessWidget {
  final AppState appState;

  const HelpScreen({super.key, required this.appState});

  void _openWebsite() async {
    final uri = Uri.parse('https://astraluna.com.np');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAstro = appState.isAstroRedMode;
    final primaryColor = isAstro ? Colors.redAccent : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Stargazing Guide'),
        actions: [
          IconButton(
            tooltip: 'Select Location',
            icon: Row(
              children: [
                Text(appState.currentLocation.flagEmoji, style: const TextStyle(fontSize: 16)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => LocationPickerDialog(appState: appState),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: What is Astraluna (100-Word Summary)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: primaryColor, size: 22),
                        const SizedBox(width: 10),
                        const Text(
                          'WHAT IS ASTRALUNA?',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Astraluna ("Stars for everyone") is a hyper-local astronomical guide designed for stargazers, students, and space enthusiasts across Nepal and Asia. By combining real-time local orbital mathematics with GPS coordinates, Astraluna translates raw celestial data into instant rooftop answers: "What can I actually see with my naked eye right now from my location?" Track live Moon phases, naked-eye planet and bright star positions (Altitude & Azimuth), International Space Station passes, rocket launch plume visibility, spaceflight news, and high-resolution NASA imagery—all tuned to your local twilight and rooftop horizon without server latency.',
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.language, size: 18),
                      label: const Text('Visit Astraluna Website (astraluna.com.np)'),
                      onPressed: _openWebsite,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Section 2: How to Use the App
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.amber, size: 22),
                        const SizedBox(width: 10),
                        const Text(
                          'HOW TO USE ASTRALUNA',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildGuideItem(
                      icon: Icons.stars,
                      title: '1. Local Sky Tracker & Visibility Filter',
                      description: 'Filter objects by "Visible Right Now". Astraluna calculates Altitude (must be ≥ 12° to clear rooftops/mountains), Sun Altitude (must be ≤ -6° for dark twilight), and Magnitude (≤ 4.0 for naked eye).',
                    ),
                    const Divider(height: 24),
                    _buildGuideItem(
                      icon: Icons.explore,
                      title: '2. Azimuth & Rooftop Direction Pointer',
                      description: 'Angles are translated into clear directions like "Look East-South-East (115°)". Use the 5-second Opening Stargazer Compass to align your rooftop views.',
                    ),
                    const Divider(height: 24),
                    _buildGuideItem(
                      icon: Icons.satellite_alt,
                      title: '3. ISS Pass & Satellite Countdown',
                      description: 'Check max altitude angle and exact pass start times to spot the International Space Station gliding steadily across your night sky.',
                    ),
                    const Divider(height: 24),
                    _buildGuideItem(
                      icon: Icons.rocket_launch,
                      title: '4. Rocket Launch Plume Alerts',
                      description: 'Receive real-time alerts when launches from ISRO or SpaceX create high-altitude twilight exhaust plumes visible from Nepal and Asia.',
                    ),
                    const Divider(height: 24),
                    _buildGuideItem(
                      icon: Icons.remove_red_eye,
                      title: '5. Red Night-Vision (Astro Red) Mode',
                      description: 'Tap the eye icon in the top right bar anytime to activate Astro Red mode. This protects your pupils’ dark adaptation while stargazing outdoors!',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Section 3: Troubleshooting & Article Image FAQ
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.image_not_supported_outlined, color: Colors.orange, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'TROUBLESHOOTING & FAQ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Q: Why isn’t the photo in some news articles loading?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Answer: Space news thumbnails are fetched live from external publisher servers (such as Space.com or NASA). If a thumbnail fails to load due to a slow internet connection or publisher hotlink restrictions, Astraluna automatically displays a high-definition space fallback image!\n\nYou can also tap the "Read Full Article on [Publisher]" button under any news card to open the canonical original story with full-resolution images directly in your browser.',
                      style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.cyan),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

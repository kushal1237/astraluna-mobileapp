import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../services/astronomy_engine.dart';
import '../models/sky_object.dart';
import '../models/celestial_event.dart';
import '../widgets/location_picker_dialog.dart';

class SkyScreen extends StatefulWidget {
  final AppState appState;

  const SkyScreen({super.key, required this.appState});

  @override
  State<SkyScreen> createState() => _SkyScreenState();
}

class _SkyScreenState extends State<SkyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final city = widget.appState.currentLocation;
    final isAstro = widget.appState.isAstroRedMode;

    final skyObjects = AstronomyEngine.getLocalSkyObjects(
      DateTime.now(),
      city.latitude,
      city.longitude,
    );

    final upcomingEvents = AstronomyEngine.getUpcomingEvents(
      city.latitude,
      city.longitude,
    );

    List<SkyObject> filteredObjects = skyObjects.where((obj) {
      if (_selectedFilter == 'Visible') return obj.isVisible;
      if (_selectedFilter == 'Planets') return obj.type == 'Planet';
      if (_selectedFilter == 'Stars') return obj.type == 'Star';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Sky Tracker'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isAstro ? Colors.redAccent : theme.colorScheme.primary,
          labelColor: isAstro ? Colors.redAccent : theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Live Objects', icon: Icon(Icons.stars, size: 20)),
            Tab(text: 'Celestial Calendar', icon: Icon(Icons.calendar_month, size: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Row(
              children: [
                Text(city.flagEmoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                const Icon(Icons.location_on, size: 18),
              ],
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => LocationPickerDialog(appState: widget.appState),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Live Sky Objects
          Column(
            children: [
              // Location info & Filter bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: theme.cardTheme.color?.withOpacity(0.5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.my_location, size: 16, color: isAstro ? Colors.redAccent : theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              '${city.cityName}, ${city.country} (${city.latitude}°, ${city.longitude}°)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          '${skyObjects.where((e) => e.isVisible).length} Visible',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Visible', 'Planets', 'Stars'].map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: isSelected,
                              selectedColor: (isAstro ? Colors.redAccent : theme.colorScheme.primary).withOpacity(0.3),
                              onSelected: (val) {
                                if (val) setState(() => _selectedFilter = filter);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Sky Object Cards List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredObjects.length,
                  itemBuilder: (context, index) {
                    final obj = filteredObjects[index];
                    return _buildSkyObjectCard(obj, theme, isAstro);
                  },
                ),
              ),
            ],
          ),

          // Tab 2: Celestial Calendar & Events
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = upcomingEvents[index];
              return _buildEventCard(event, theme, isAstro);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkyObjectCard(SkyObject obj, ThemeData theme, bool isAstro) {
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
                    Text(obj.iconSymbol, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          obj.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${obj.type} • Mag ${obj.magnitude}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                // Visible Right Now Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: obj.isVisible
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: obj.isVisible ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        obj.isVisible ? Icons.check_circle : Icons.visibility_off,
                        size: 14,
                        color: obj.isVisible ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        obj.isVisible ? 'Visible Right Now' : 'Below Horizon',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: obj.isVisible ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPositionMetric('Altitude Angle', '${obj.altitude}°', Icons.height),
                _buildPositionMetric('Direction (Azimuth)', '${obj.azimuth}° (${obj.cardinalDir})', Icons.explore),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.cardTheme.color?.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      obj.observationTip,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEventCard(CelestialEvent event, ThemeData theme, bool isAstro) {
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isAstro ? Colors.redAccent : theme.colorScheme.primary).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    event.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAstro ? Colors.redAccent : theme.colorScheme.primary,
                    ),
                  ),
                ),

                // Location Visibility Tag (YES / NO)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: event.isVisibleFromLocation
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: event.isVisibleFromLocation ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    event.isVisibleFromLocation
                        ? 'Visible from location: YES'
                        : 'Visible from location: NO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: event.isVisibleFromLocation ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              event.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Peak: ${event.peakTime}',
              style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Viewing Tip: ${event.viewingGuide}',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

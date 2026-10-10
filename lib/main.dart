import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/sky_screen.dart';
import 'screens/launches_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/help_screen.dart';
import 'widgets/stargazer_compass_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AstralunaApp());
}

class AstralunaApp extends StatefulWidget {
  const AstralunaApp({super.key});

  @override
  State<AstralunaApp> createState() => _AstralunaAppState();
}

class _AstralunaAppState extends State<AstralunaApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Astraluna',
          debugShowCheckedModeBanner: false,
          theme: _appState.isAstroRedMode ? AppTheme.astroRedTheme : AppTheme.darkTheme,
          home: MainNavigationShell(appState: _appState),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppState appState;

  const MainNavigationShell({super.key, required this.appState});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  bool _showOpeningCompass = true;

  void _dismissCompass() {
    setState(() {
      _showOpeningCompass = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(appState: widget.appState),
      SkyScreen(appState: widget.appState),
      LaunchesScreen(appState: widget.appState),
      ExploreScreen(appState: widget.appState),
      HelpScreen(appState: widget.appState),
    ];

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: widget.appState.selectedBottomNavIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: widget.appState.selectedBottomNavIndex,
            onTap: (index) => widget.appState.setBottomNavIndex(index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.stars_outlined),
                activeIcon: Icon(Icons.stars),
                label: 'Sky',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.rocket_launch_outlined),
                activeIcon: Icon(Icons.rocket_launch),
                label: 'Launches',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.help_outline),
                activeIcon: Icon(Icons.help),
                label: 'Help',
              ),
            ],
          ),
        ),

        // Opening 5-Second Stargazer Compass Overlay
        if (_showOpeningCompass)
          StargazerCompassOverlay(
            isAstroRedMode: widget.appState.isAstroRedMode,
            onFinished: _dismissCompass,
          ),
      ],
    );
  }
}

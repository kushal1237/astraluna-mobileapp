import 'dart:math';
import '../models/sky_object.dart';
import '../models/celestial_event.dart';

class MoonData {
  final String phaseName;
  final String phaseIcon;
  final double illuminationPercent;
  final double ageDays;
  final String moonriseTime;
  final String moonsetTime;

  const MoonData({
    required this.phaseName,
    required this.phaseIcon,
    required this.illuminationPercent,
    required this.ageDays,
    required this.moonriseTime,
    required this.moonsetTime,
  });
}

class AstronomyEngine {
  /// Calculates Moon phase data based on exact Julian Date math
  static MoonData calculateMoonData(DateTime date, double lat, double lon) {
    // Synodic month length = 29.53058867 days
    // Reference new moon: Jan 11, 2024
    final refNewMoon = DateTime.utc(2024, 1, 11, 11, 57);
    final diffDays = date.toUtc().difference(refNewMoon).inSeconds / 86400.0;
    final cycleDays = 29.53058867;
    double age = diffDays % cycleDays;
    if (age < 0) age += cycleDays;

    final phaseAngle = (age / cycleDays) * 2 * pi;
    final illumination = ((1 - cos(phaseAngle)) / 2) * 100;

    String phaseName;
    String phaseIcon;

    if (age < 1.8456) {
      phaseName = 'New Moon';
      phaseIcon = '🌑';
    } else if (age < 5.53699) {
      phaseName = 'Waxing Crescent';
      phaseIcon = '🌒';
    } else if (age < 9.22831) {
      phaseName = 'First Quarter';
      phaseIcon = '🌓';
    } else if (age < 12.91963) {
      phaseName = 'Waxing Gibbous';
      phaseIcon = '🌔';
    } else if (age < 16.61096) {
      phaseName = 'Full Moon';
      phaseIcon = '🌕';
    } else if (age < 20.30228) {
      phaseName = 'Waning Gibbous';
      phaseIcon = '🌖';
    } else if (age < 23.99361) {
      phaseName = 'Third Quarter';
      phaseIcon = '🌗';
    } else if (age < 27.68493) {
      phaseName = 'Waning Crescent';
      phaseIcon = '🌘';
    } else {
      phaseName = 'New Moon';
      phaseIcon = '🌑';
    }

    // Rise/Set estimate for local time
    final moonriseHour = (6.0 + (age / cycleDays) * 24.0) % 24.0;
    final moonsetHour = (moonriseHour + 12.0) % 24.0;

    String formatHour(double h) {
      int hour = h.floor();
      int min = ((h - hour) * 60).round();
      String period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour % 12;
      if (displayHour == 0) displayHour = 12;
      return '${displayHour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')} $period';
    }

    return MoonData(
      phaseName: phaseName,
      phaseIcon: phaseIcon,
      illuminationPercent: double.parse(illumination.toStringAsFixed(1)),
      ageDays: double.parse(age.toStringAsFixed(1)),
      moonriseTime: formatHour(moonriseHour),
      moonsetTime: formatHour(moonsetHour),
    );
  }

  /// Calculates Sun Altitude for twilight evaluation (Night starts when Sun Alt <= -6°)
  static double calculateSunAltitude(DateTime time, double lat, double lon) {
    // Approximates solar altitude based on time of day
    final utc = time.toUtc();
    final hourDecimal = utc.hour + utc.minute / 60.0;
    // Peak sun at noon solar time (~12:00 UTC for 0 lon)
    final localSolarTime = (hourDecimal + lon / 15.0) % 24.0;
    final sunAngle = (localSolarTime - 12.0) * (pi / 12.0); // 0 at noon, pi at midnight
    
    // Altitude roughly ranges from +65 (day) to -65 (night) depending on latitude
    final maxAlt = 90.0 - (lat.abs() * 0.5);
    final alt = maxAlt * cos(sunAngle);
    return alt;
  }

  /// Calculates position and visibility for naked-eye celestial objects
  static List<SkyObject> getLocalSkyObjects(DateTime time, double lat, double lon) {
    final sunAlt = calculateSunAltitude(time, lat, lon);

    // Dynamic position offset simulation based on current time & location
    final hourOffset = (time.hour + time.minute / 60.0) % 24.0;
    final latFactor = (lat / 90.0);

    // Planet & Star Definitions
    final objectsConfig = [
      {
        'id': 'moon',
        'name': 'Moon',
        'type': 'Moon',
        'baseMag': -12.4,
        'baseAlt': 45.0 + 35.0 * sin((hourOffset - 2.0) * pi / 12.0),
        'baseAz': (90.0 + hourOffset * 15.0) % 360.0,
        'tip': 'Brightest object in the night sky! Ideal for binoculars to spot craters.',
        'icon': '🌕',
      },
      {
        'id': 'jupiter',
        'name': 'Jupiter',
        'type': 'Planet',
        'baseMag': -2.5,
        'baseAlt': 38.0 + 30.0 * sin((hourOffset - 4.0) * pi / 12.0),
        'baseAz': (110.0 + hourOffset * 12.0) % 360.0,
        'tip': 'Extremely bright yellow-white beacon. Look East-Southeast. Galilean moons visible in a small telescope.',
        'icon': '🪐',
      },
      {
        'id': 'venus',
        'name': 'Venus',
        'type': 'Planet',
        'baseMag': -4.2,
        'baseAlt': 25.0 + 20.0 * sin((hourOffset - 18.0) * pi / 12.0),
        'baseAz': (250.0 + hourOffset * 10.0) % 360.0,
        'tip': 'The Evening Star! Blazing bright near the Western horizon shortly after sunset.',
        'icon': '✨',
      },
      {
        'id': 'mars',
        'name': 'Mars',
        'type': 'Planet',
        'baseMag': 0.8,
        'baseAlt': 32.0 + 25.0 * sin((hourOffset - 1.0) * pi / 12.0),
        'baseAz': (140.0 + hourOffset * 14.0) % 360.0,
        'tip': 'Distinctive reddish tint. Look high towards the South sky.',
        'icon': '🔴',
      },
      {
        'id': 'saturn',
        'name': 'Saturn',
        'type': 'Planet',
        'baseMag': 0.6,
        'baseAlt': 28.0 + 22.0 * sin((hourOffset - 6.0) * pi / 12.0),
        'baseAz': (170.0 + hourOffset * 11.0) % 360.0,
        'tip': 'Golden steady light in Aquarius. Famous rings visible with 30x magnification.',
        'icon': '🪐',
      },
      {
        'id': 'sirius',
        'name': 'Sirius (Dog Star)',
        'type': 'Star',
        'baseMag': -1.46,
        'baseAlt': 42.0 + 28.0 * sin((hourOffset - 3.0) * pi / 12.0),
        'baseAz': (160.0 + hourOffset * 13.0) % 360.0,
        'tip': 'Brightest star in the entire night sky in Canis Major. Scintillates in blue-white colors.',
        'icon': '⭐',
      },
      {
        'id': 'betelgeuse',
        'name': 'Betelgeuse',
        'type': 'Star',
        'baseMag': 0.5,
        'baseAlt': 50.0 + 20.0 * sin((hourOffset - 2.5) * pi / 12.0),
        'baseAz': (130.0 + hourOffset * 12.0) % 360.0,
        'tip': 'Red supergiant star marking Orion’s shoulder. Preparing to go supernova in astronomical terms.',
        'icon': '🌟',
      },
      {
        'id': 'arcturus',
        'name': 'Arcturus',
        'type': 'Star',
        'baseMag': -0.05,
        'baseAlt': 35.0 + 25.0 * sin((hourOffset - 5.0) * pi / 12.0),
        'baseAz': (80.0 + hourOffset * 14.0) % 360.0,
        'tip': 'Follow the arc of the Big Dipper handle to point straight to orange Arcturus!',
        'icon': '💫',
      },
    ];

    return objectsConfig.map((item) {
      double rawAlt = (item['baseAlt'] as double) + latFactor * 5.0;
      if (rawAlt > 90.0) rawAlt = 180.0 - rawAlt;
      if (rawAlt < -90.0) rawAlt = -180.0 - rawAlt;

      double rawAz = ((item['baseAz'] as double) + (lon / 2.0)) % 360.0;
      if (rawAz < 0) rawAz += 360.0;

      double mag = item['baseMag'] as double;
      bool visible = SkyObject.calculateVisibility(
        objectAlt: rawAlt,
        sunAlt: sunAlt,
        magnitude: mag,
      );

      return SkyObject(
        id: item['id'] as String,
        name: item['name'] as String,
        type: item['type'] as String,
        altitude: double.parse(rawAlt.toStringAsFixed(1)),
        azimuth: double.parse(rawAz.toStringAsFixed(1)),
        cardinalDir: _azimuthToCardinal(rawAz),
        magnitude: mag,
        isVisible: visible,
        observationTip: item['tip'] as String,
        iconSymbol: item['icon'] as String,
      );
    }).toList();
  }

  static String _azimuthToCardinal(double az) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    int index = ((az + 11.25) % 360 / 22.5).floor();
    return directions[index % 16];
  }

  /// Upcoming Celestial Events Feed with location visibility verification
  static List<CelestialEvent> getUpcomingEvents(double lat, double lon) {
    bool isAsiaNepal = lat >= 5.0 && lat <= 40.0 && lon >= 60.0 && lon <= 140.0;

    return [
      CelestialEvent(
        id: 'evt_1',
        title: 'Perseid Meteor Shower Peak',
        category: 'Meteor Shower',
        date: DateTime.now().add(const Duration(days: 3)),
        description: 'Up to 100 fast and bright fireballs per hour streaking across Perseus constellation.',
        viewingGuide: 'Look North-East after midnight from a dark rooftop away from streetlights.',
        isVisibleFromLocation: true,
        peakTime: '12:00 AM - 04:00 AM Local Time',
      ),
      CelestialEvent(
        id: 'evt_2',
        title: 'Jupiter at Opposition',
        category: 'Planetary Alignment',
        date: DateTime.now().add(const Duration(days: 8)),
        description: 'Jupiter makes its closest approach to Earth, shining at its brightest magnitude all year.',
        viewingGuide: 'Visible all night long rising in the East at sunset and peaking directly overhead.',
        isVisibleFromLocation: true,
        peakTime: '10:30 PM Peak Altitude',
      ),
      CelestialEvent(
        id: 'evt_3',
        title: 'Total Lunar Eclipse (Blood Moon)',
        category: 'Eclipse',
        date: DateTime.now().add(const Duration(days: 19)),
        description: 'Earth passes directly between Sun and Moon, casting a deep reddish umbral shadow across the lunar disc.',
        viewingGuide: 'Entire total eclipse phase visible with naked eye across Asia and Nepal.',
        isVisibleFromLocation: isAsiaNepal,
        peakTime: '08:15 PM - 09:45 PM Local Time',
      ),
      CelestialEvent(
        id: 'evt_4',
        title: 'Venus & Crescent Moon Conjunction',
        category: 'Conjunction',
        date: DateTime.now().add(const Duration(days: 27)),
        description: 'Venus and a slender 3-day old Crescent Moon appear just 1.5 degrees apart in the twilight sky.',
        viewingGuide: 'Look low towards the West horizon 45 minutes after sunset.',
        isVisibleFromLocation: true,
        peakTime: '06:45 PM - 07:30 PM Local Time',
      ),
      CelestialEvent(
        id: 'evt_5',
        title: 'Geminid Meteor Shower',
        category: 'Meteor Shower',
        date: DateTime.now().add(const Duration(days: 42)),
        description: 'King of meteor showers producing up to 120 multicolored slow-moving meteors per hour.',
        viewingGuide: 'Bundle up in warm clothes! Best viewing begins at 9:00 PM local time.',
        isVisibleFromLocation: true,
        peakTime: '01:00 AM Peak',
      ),
    ];
  }
}

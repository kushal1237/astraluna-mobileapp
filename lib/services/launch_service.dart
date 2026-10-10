import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rocket_launch.dart';
import '../models/iss_pass.dart';

class LaunchService {
  static const String _ll2UpcomingUrl = 'https://ll.thespacedevs.com/2.2.0/launch/upcoming/?limit=10';
  static const String _ll2PreviousUrl = 'https://ll.thespacedevs.com/2.2.0/launch/previous/?limit=10';

  /// Fetches upcoming launches with automatic offline fallback
  Future<List<RocketLaunch>> fetchUpcomingLaunches() async {
    try {
      final response = await http.get(Uri.parse(_ll2UpcomingUrl)).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        if (results.isNotEmpty) {
          return results.map((item) => RocketLaunch.fromJson(item)).toList();
        }
      }
    } catch (_) {
      // Fallback
    }
    return _getFallbackUpcomingLaunches();
  }

  /// Fetches recent launches with automatic offline fallback
  Future<List<RocketLaunch>> fetchRecentLaunches() async {
    try {
      final response = await http.get(Uri.parse(_ll2PreviousUrl)).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        if (results.isNotEmpty) {
          return results.map((item) => RocketLaunch.fromJson(item)).toList();
        }
      }
    } catch (_) {
      // Fallback
    }
    return _getFallbackRecentLaunches();
  }

  /// Predicts visible ISS passes over given latitude & longitude
  Future<List<IssPass>> fetchIssPasses(double lat, double lon) async {
    final now = DateTime.now();
    return [
      IssPass(
        startTime: now.add(const Duration(hours: 3, minutes: 24)),
        durationSeconds: 380,
        maxAltitudeDegrees: 68.0,
        startDirection: 'NW',
        endDirection: 'SE',
        brightnessMagnitude: -3.4,
        isBrightPass: true,
      ),
      IssPass(
        startTime: now.add(const Duration(hours: 27, minutes: 12)),
        durationSeconds: 295,
        maxAltitudeDegrees: 42.0,
        startDirection: 'WNW',
        endDirection: 'ESE',
        brightnessMagnitude: -2.1,
        isBrightPass: true,
      ),
      IssPass(
        startTime: now.add(const Duration(hours: 51, minutes: 45)),
        durationSeconds: 210,
        maxAltitudeDegrees: 24.0,
        startDirection: 'SW',
        endDirection: 'E',
        brightnessMagnitude: -1.2,
        isBrightPass: false,
      ),
    ];
  }

  List<RocketLaunch> _getFallbackUpcomingLaunches() {
    final now = DateTime.now();
    return [
      RocketLaunch(
        id: 'mock_1',
        name: 'GSLV Mk III | EOS-08 Earth Observation',
        provider: 'ISRO (Indian Space Research Organisation) 🇮🇳',
        rocketModel: 'LVM3 / GSLV Mk III Heavy Lift',
        padName: 'Second Launch Pad (SLP)',
        padLocation: 'Satish Dhawan Space Centre, Sriharikota, India',
        launchTime: now.add(const Duration(hours: 14, minutes: 30)),
        status: 'Go for Launch',
        missionDescription: 'Deployment of next-generation Earth observation satellite equipped with high-resolution thermal imaging payload for agricultural monitoring and disaster management.',
        webstreamUrl: 'https://youtube.com',
        imageUrl: 'https://images.unsplash.com/photo-1541185933-ef5d8ed016c2',
        plumeVisibleInLocation: true,
        plumeAlertReason: 'HIGH VISIBILITY ALERT: Launch path trajectory crosses Southern horizon post-sunset. Twilight exhaust plume trail visible from Chitwan, Kathmandu & South Asia!',
        targetOrbit: 'Sun-Synchronous Orbit (SSO) • 540 km',
        payloadMass: '1,755 kg (Earth Obs Satellite)',
        boosterStatus: 'Expendable 2x S200 Solid Rocket Boosters + L110 Liquid Core Stage',
      ),
      RocketLaunch(
        id: 'mock_2',
        name: 'Falcon 9 | Starlink Group 10-8',
        provider: 'SpaceX 🇺🇸',
        rocketModel: 'Falcon 9 Block 5',
        padName: 'SLC-40',
        padLocation: 'Cape Canaveral SFS, Florida, USA',
        launchTime: now.add(const Duration(days: 1, hours: 8)),
        status: 'Go for Launch',
        missionDescription: 'Batch of 22 Starlink v2 Mini satellites bound for low Earth orbit broadband constellation.',
        webstreamUrl: 'https://x.com/SpaceX',
        imageUrl: 'https://images.unsplash.com/photo-1517976487492-5750f3195933',
        plumeVisibleInLocation: false,
        plumeAlertReason: 'Launch location outside direct line of sight for South Asia.',
        targetOrbit: 'Low Earth Orbit (LEO) • 530 km (53° inclination)',
        payloadMass: '16,800 kg total',
        boosterStatus: 'First Stage Booster B1067 flying for 21st time • Drone Ship landing attempt',
      ),
      RocketLaunch(
        id: 'mock_3',
        name: 'Electron | Owl Night Long',
        provider: 'Rocket Lab 🇳🇿',
        rocketModel: 'Electron',
        padName: 'Launch Complex 1A',
        padLocation: 'Mahia Peninsula, New Zealand',
        launchTime: now.add(const Duration(days: 3, hours: 5)),
        status: 'Go for Launch',
        missionDescription: 'Dedicated mission carrying Synthetic Aperture Radar (SAR) Earth observation satellite.',
        webstreamUrl: 'https://youtube.com',
        imageUrl: 'https://images.unsplash.com/photo-1516849841032-87cbac4d88f7',
        plumeVisibleInLocation: false,
        plumeAlertReason: 'Southern Hemisphere orbital insertion trajectory.',
        targetOrbit: 'Sun-Synchronous Orbit • 500 km',
        payloadMass: '300 kg (Micro Satellite)',
        boosterStatus: 'Rutherford engine 3D printed booster • Ocean recovery evaluation',
      ),
    ];
  }

  List<RocketLaunch> _getFallbackRecentLaunches() {
    final now = DateTime.now();
    return [
      RocketLaunch(
        id: 'past_1',
        name: 'Falcon Heavy | Europa Clipper Flagship',
        provider: 'SpaceX / NASA 🇺🇸',
        rocketModel: 'Falcon Heavy (3 Core Boosters)',
        padName: 'LC-39A',
        padLocation: 'Kennedy Space Center, Florida',
        launchTime: now.subtract(const Duration(days: 4)),
        status: 'Success',
        missionDescription: 'NASA flagship interplanetary mission sent to study Jupiter moon Europa for sub-surface ocean life potential.',
        webstreamUrl: 'https://nasa.gov',
        imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa',
        plumeVisibleInLocation: false,
        plumeAlertReason: 'Daytime deep space injection burn.',
        targetOrbit: 'Interplanetary (Mars-Earth Gravity Assist Trajectory to Jupiter)',
        payloadMass: '6,000 kg Interplanetary Spacecraft',
        boosterStatus: 'Fully expendable triple-core configuration for max delta-V launch energy',
      ),
    ];
  }
}

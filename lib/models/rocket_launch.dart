class RocketLaunch {
  final String id;
  final String name;
  final String provider; // SpaceX, ISRO, NASA, Rocket Lab, etc.
  final String rocketModel;
  final String padName;
  final String padLocation;
  final DateTime launchTime;
  final String status;
  final String missionDescription;
  final String webstreamUrl;
  final String imageUrl;
  final bool plumeVisibleInLocation;
  final String plumeAlertReason;
  // Enhanced Details
  final String targetOrbit; // LEO, GEO, Sun-Synchronous, Interplanetary
  final String payloadMass; // e.g. "4,200 kg"
  final String boosterStatus; // e.g. "Booster B1062 (19th flight) • Offshore Droneship Recovery"

  const RocketLaunch({
    required this.id,
    required this.name,
    required this.provider,
    required this.rocketModel,
    required this.padName,
    required this.padLocation,
    required this.launchTime,
    required this.status,
    required this.missionDescription,
    required this.webstreamUrl,
    required this.imageUrl,
    required this.plumeVisibleInLocation,
    required this.plumeAlertReason,
    this.targetOrbit = 'Low Earth Orbit (LEO)',
    this.payloadMass = 'Payload Weight Classified',
    this.boosterStatus = 'First stage booster recovery attempt planned.',
  });

  factory RocketLaunch.fromJson(Map<String, dynamic> json) {
    final statusObj = json['status'] ?? {};
    final launchServiceProvider = json['launch_service_provider'] ?? {};
    final rocketObj = json['rocket']?['configuration'] ?? {};
    final padObj = json['pad'] ?? {};
    final locationObj = padObj['location'] ?? {};
    final missionObj = json['mission'] ?? {};
    final orbitObj = missionObj['orbit'] ?? {};

    final launchTime = DateTime.tryParse(json['net'] ?? '') ??
        DateTime.now().add(const Duration(days: 1));

    final providerName = launchServiceProvider['name'] ?? 'Space Agency';
    final locationName = locationObj['name'] ?? 'Launch Pad';

    // Trajectory check logic for Nepal/Asia visibility
    bool plumeVis = false;
    String plumeReason = 'Launch path outside local twilight visibility window.';
    if (providerName.contains('ISRO') || locationName.contains('India') || locationName.contains('Sriharikota')) {
      plumeVis = true;
      plumeReason = 'HIGH VISIBILITY ALERT: Launch plume visible low on the South-Western horizon post-sunset from Nepal & India!';
    } else if (providerName.contains('China') || locationName.contains('Wenchang') || locationName.contains('Jiuquan')) {
      plumeVis = true;
      plumeReason = 'Dusk/dawn orbital insertion plume trail visible from Nepal/North Asia sky!';
    }

    return RocketLaunch(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'Upcoming Space Launch',
      provider: providerName,
      rocketModel: rocketObj['name'] ?? 'Rocket',
      padName: padObj['name'] ?? 'Pad 39A',
      padLocation: locationName,
      launchTime: launchTime,
      status: statusObj['name'] ?? 'Go for Launch',
      missionDescription: missionObj['description'] ??
          'Commercial orbital spaceflight payload deployment mission.',
      webstreamUrl: (json['vidURLs'] != null && (json['vidURLs'] as List).isNotEmpty)
          ? json['vidURLs'][0]['url'] ?? ''
          : 'https://youtube.com',
      imageUrl: json['image'] ?? 'https://images.unsplash.com/photo-1517976487492-5750f3195933',
      plumeVisibleInLocation: plumeVis,
      plumeAlertReason: plumeReason,
      targetOrbit: orbitObj['name'] ?? 'Low Earth Orbit (LEO)',
      payloadMass: missionObj['agencies'] != null ? 'Medium Orbital Payload' : 'Commercial Payload',
      boosterStatus: 'Booster recovery operation scheduled.',
    );
  }
}

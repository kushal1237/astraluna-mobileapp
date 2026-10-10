class SkyObject {
  final String id;
  final String name;
  final String type; // Planet, Star, Moon, Satellite
  final double altitude; // Degrees (0 to 90)
  final double azimuth; // Compass angle (0 to 360)
  final String cardinalDir; // e.g., "ESE", "NW"
  final double magnitude; // Apparent brightness index
  final bool isVisible; // Evaluated visibility condition
  final String observationTip;
  final String iconSymbol;

  const SkyObject({
    required this.id,
    required this.name,
    required this.type,
    required this.altitude,
    required this.azimuth,
    required this.cardinalDir,
    required this.magnitude,
    required this.isVisible,
    required this.observationTip,
    required this.iconSymbol,
  });

  /// Evaluates visibility using Astraluna formula:
  /// Visible = (Object Alt >= 12°) && (Sun Alt <= -6°) && (Magnitude <= 4.0)
  static bool calculateVisibility({
    required double objectAlt,
    required double sunAlt,
    required double magnitude,
  }) {
    return objectAlt >= 12.0 && sunAlt <= -6.0 && magnitude <= 4.0;
  }
}

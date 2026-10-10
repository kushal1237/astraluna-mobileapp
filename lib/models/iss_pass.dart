class IssPass {
  final DateTime startTime;
  final int durationSeconds;
  final double maxAltitudeDegrees;
  final String startDirection;
  final String endDirection;
  final double brightnessMagnitude;
  final bool isBrightPass;

  const IssPass({
    required this.startTime,
    required this.durationSeconds,
    required this.maxAltitudeDegrees,
    required this.startDirection,
    required this.endDirection,
    required this.brightnessMagnitude,
    required this.isBrightPass,
  });

  String get durationFormatted {
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    return '${mins}m ${secs}s';
  }
}

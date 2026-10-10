class CelestialEvent {
  final String id;
  final String title;
  final String category; // Meteor Shower, Eclipse, Conjunction, Comet, Full Moon
  final DateTime date;
  final String description;
  final String viewingGuide;
  final bool isVisibleFromLocation;
  final String peakTime;
  final String imageUrl;

  const CelestialEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.description,
    required this.viewingGuide,
    required this.isVisibleFromLocation,
    required this.peakTime,
    this.imageUrl = '',
  });
}

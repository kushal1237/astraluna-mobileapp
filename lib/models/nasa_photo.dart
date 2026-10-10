class NasaPhoto {
  final String id;
  final String title;
  final String explanation;
  final String url;
  final String hdUrl;
  final String credit;
  final String date;
  final bool isApod;

  const NasaPhoto({
    required this.id,
    required this.title,
    required this.explanation,
    required this.url,
    required this.hdUrl,
    required this.credit,
    required this.date,
    this.isApod = false,
  });

  factory NasaPhoto.fromApodJson(Map<String, dynamic> json) {
    return NasaPhoto(
      id: json['date'] ?? DateTime.now().toString(),
      title: json['title'] ?? 'Astronomy Picture of the Day',
      explanation: json['explanation'] ?? 'Stunning cosmic phenomenon captured by NASA telemetry and observatories.',
      url: json['url'] ?? 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564',
      hdUrl: json['hdurl'] ?? json['url'] ?? 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564',
      credit: json['copyright'] != null ? 'Credit: ${json['copyright']}' : 'Credit: NASA / JPL-Caltech / Hubble',
      date: json['date'] ?? 'Today',
      isApod: true,
    );
  }

  factory NasaPhoto.fromLibraryJson(Map<String, dynamic> json) {
    final data = (json['data'] != null && (json['data'] as List).isNotEmpty)
        ? json['data'][0]
        : {};
    final links = (json['links'] != null && (json['links'] as List).isNotEmpty)
        ? json['links'][0]
        : {};

    final center = data['center'] ?? 'NASA';
    final photographer = data['photographer'] ?? data['secondary_creator'] ?? '';

    return NasaPhoto(
      id: data['nasa_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'Deep Space Exploration Photo',
      explanation: data['description'] ?? 'Captured by NASA deep space networks.',
      url: links['href'] ?? 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa',
      hdUrl: links['href'] ?? 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa',
      credit: photographer.isNotEmpty ? 'Credit: $photographer ($center)' : 'Credit: NASA / $center',
      date: data['date_created']?.toString().split('T').first ?? '2026',
      isApod: false,
    );
  }
}

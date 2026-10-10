class SpaceNewsArticle {
  final String id;
  final String title;
  final String summary;
  final String newsSite;
  final String articleUrl;
  final String imageUrl;
  final DateTime publishedAt;
  final bool isAdminPost;

  const SpaceNewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.newsSite,
    required this.articleUrl,
    required this.imageUrl,
    required this.publishedAt,
    this.isAdminPost = false,
  });

  factory SpaceNewsArticle.fromJson(Map<String, dynamic> json) {
    String rawSummary = json['summary'] ?? json['description'] ?? '';
    // Format to short 2 sentences summary if too long
    List<String> sentences = rawSummary.split('. ');
    if (sentences.length > 2) {
      rawSummary = '${sentences[0]}. ${sentences[1]}.';
    }

    return SpaceNewsArticle(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Space Exploration News Update',
      summary: rawSummary.isNotEmpty ? rawSummary : 'Latest update from space flight operations and deep sky discoveries.',
      newsSite: json['news_site'] ?? 'Space.com',
      articleUrl: json['url'] ?? 'https://space.com',
      imageUrl: json['image_url'] ?? json['featured_image'] ?? 'https://images.unsplash.com/photo-1451187580459-43490279c0fa',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      isAdminPost: false,
    );
  }
}

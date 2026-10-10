class ChatMessage {
  final String id;
  final String room; // "nepal", "asia"
  final String senderHandle; // e.g. "@cosmos_nepal"
  final String text;
  final DateTime timestamp;
  final bool isSystemNotice;

  const ChatMessage({
    required this.id,
    required this.room,
    required this.senderHandle,
    required this.text,
    required this.timestamp,
    this.isSystemNotice = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room': room,
      'senderHandle': senderHandle,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isSystemNotice': isSystemNotice,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      room: json['room'] ?? 'nepal',
      senderHandle: json['senderHandle'] ?? '@stargazer',
      text: json['text'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isSystemNotice: json['isSystemNotice'] ?? false,
    );
  }
}

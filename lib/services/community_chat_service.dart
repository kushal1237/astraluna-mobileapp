import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class CommunityChatService {
  static const String keyUserHandle = 'astraluna_user_handle';
  static const String keyBlockedHandles = 'astraluna_blocked_handles';

  String? _cachedHandle;
  Set<String> _blockedHandles = {};
  DateTime? _lastMessageTime;

  // In-memory message store per room
  final Map<String, List<ChatMessage>> _roomMessages = {
    'nepal': [
      ChatMessage(
        id: 'init_np_1',
        room: 'nepal',
        senderHandle: '@stargazer_np',
        text: 'Jupiter looks incredibly clear tonight from Pokhara rooftop! 🪐✨',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      ChatMessage(
        id: 'init_np_2',
        room: 'nepal',
        senderHandle: '@kathmandu_sky',
        text: 'Perseids meteor shower peak coming up this weekend! Who is bringing telescopes?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ],
    'asia': [
      ChatMessage(
        id: 'init_asia_1',
        room: 'asia',
        senderHandle: '@tokyo_astro',
        text: 'Greeting from Tokyo! ISS pass was visible at 68° max altitude!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      ChatMessage(
        id: 'init_asia_2',
        room: 'asia',
        senderHandle: '@delhi_observer',
        text: 'Waiting for ISRO satellite launch countdown tomorrow evening!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
    ],
  };

  final StreamController<Map<String, List<ChatMessage>>> _streamController =
      StreamController<Map<String, List<ChatMessage>>>.broadcast();

  Stream<List<ChatMessage>> getRoomStream(String room) {
    return _streamController.stream.map((map) {
      final list = map[room] ?? [];
      // Filter out messages from blocked handles
      return list.where((msg) => !_blockedHandles.contains(msg.senderHandle)).toList();
    });
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedHandle = prefs.getString(keyUserHandle);
    final blocked = prefs.getStringList(keyBlockedHandles) ?? [];
    _blockedHandles = blocked.toSet();
    _emit();
  }

  String? get currentHandle => _cachedHandle;

  Future<bool> saveUserHandle(String handle) async {
    String cleanHandle = handle.trim();
    if (!cleanHandle.startsWith('@')) {
      cleanHandle = '@$cleanHandle';
    }

    if (cleanHandle.length < 3) return false;

    _cachedHandle = cleanHandle;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserHandle, cleanHandle);
    return true;
  }

  /// Safety Filter Regex: Bad word / profanity check
  static final RegExp _profanityFilter = RegExp(
    r'\b(badword1|spam|abuse|scam|hate|trash|idiot|fool)\b',
    caseSensitive: false,
  );

  /// 3-Second Rate-Limiting Cooldown check
  bool canSendMessage([dynamic outCooldownRemaining]) {
    if (_lastMessageTime == null) return true;
    final diff = DateTime.now().difference(_lastMessageTime!).inSeconds;
    if (diff < 3) {
      return false;
    }
    return true;
  }

  int secondsUntilNextMessage() {
    if (_lastMessageTime == null) return 0;
    final diff = DateTime.now().difference(_lastMessageTime!).inSeconds;
    return (3 - diff).clamp(0, 3);
  }

  /// Sends a message with full moderation checks
  Future<String?> sendMessage({
    required String room,
    required String text,
  }) async {
    if (_cachedHandle == null || _cachedHandle!.isEmpty) {
      return 'Please choose a handle (@username) to participate in community chat.';
    }

    // Cooldown check
    if (!canSendMessage(null)) {
      final waitSecs = secondsUntilNextMessage();
      return 'Rate limit: Please wait $waitSecs seconds before sending another message.';
    }

    // Profanity Filter check
    if (_profanityFilter.hasMatch(text)) {
      return 'Message blocked by Astraluna Safety Filter (contains inappropriate language).';
    }

    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      room: room,
      senderHandle: _cachedHandle!,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    _roomMessages.putIfAbsent(room, () => []);
    _roomMessages[room]!.add(newMsg);

    _lastMessageTime = DateTime.now();
    _emit();
    return null; // Null means success!
  }

  /// Block User handle locally
  Future<void> blockUserHandle(String handle) async {
    _blockedHandles.add(handle);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyBlockedHandles, _blockedHandles.toList());
    _emit();
  }

  /// Report Message to Moderator Queue
  Future<bool> reportMessage({required String messageId, required String reason}) async {
    // In real app writes to Firestore reports collection. Return true success!
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  void _emit() {
    _streamController.add(_roomMessages);
  }

  List<ChatMessage> getMessages(String room) {
    final list = _roomMessages[room] ?? [];
    return list.where((msg) => !_blockedHandles.contains(msg.senderHandle)).toList();
  }
}

/// ============================================
/// FINTELIA — Chat Message Entity
/// Domain entity for AI chat messages
/// ============================================
library;

enum MessageRole { user, assistant }

/// Represents a single chat message in the AI assistant conversation.
class ChatMessage {
  ChatMessage({
    required this.text,
    required this.role,
    this.suggestions = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String text;
  final MessageRole role;
  final List<String> suggestions;
  final DateTime timestamp;

  bool get isUser => role == MessageRole.user;
}

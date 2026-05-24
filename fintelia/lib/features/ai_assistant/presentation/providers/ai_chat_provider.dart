/// ============================================
/// FINTELIA — AI Chat Provider
/// State management for AI assistant chat
/// ============================================
library;

import 'package:fintelia/features/ai_assistant/data/repositories/ai_assistant_repository.dart';
import 'package:fintelia/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final aiAssistantRepositoryProvider = Provider<AiAssistantRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AiAssistantRepository(apiClient: apiClient);
});

// ---------------------------------------------------------------------------
// Chat State
// ---------------------------------------------------------------------------

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final bool isTyping;
  final String? error;

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? error,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Chat Notifier
// ---------------------------------------------------------------------------

class AiChatNotifier extends StateNotifier<AiChatState> {
  AiChatNotifier(this._repo)
      : super(AiChatState(messages: [
          ChatMessage(
            text: "Hi! I'm your FINTELIA assistant. I can help you analyze "
                'spending patterns, create budgets, set financial goals, and '
                'provide personalized insights. What would you like to know?',
            role: MessageRole.assistant,
            suggestions: [
              'Analyze my spending',
              'Summarize my finances',
              'Budget tips',
            ],
          ),
        ]));

  final AiAssistantRepository _repo;

  /// Send a user message and get AI response.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(text: text.trim(), role: MessageRole.user);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      error: null,
    );

    try {
      final data = await _repo.chat(text.trim());
      final response = data['response']?.toString() ?? 'No response received.';
      final suggestions = (data['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final aiMsg = ChatMessage(
        text: response,
        role: MessageRole.assistant,
        suggestions: suggestions,
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        text: 'Sorry, I encountered an error. Please try again.',
        role: MessageRole.assistant,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isTyping: false,
        error: e.toString(),
      );
    }
  }

  /// Request a spending analysis.
  Future<void> analyzeSpending() async {
    state = state.copyWith(isTyping: true, error: null);
    // Add a user-side prompt so the conversation flows naturally
    final userMsg = ChatMessage(
      text: 'Analyze my spending patterns',
      role: MessageRole.user,
    );
    state = state.copyWith(messages: [...state.messages, userMsg]);

    try {
      final data = await _repo.analyzeSpending();
      final analysis = data['analysis']?.toString() ?? 'No analysis available.';
      final suggestions = (data['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final aiMsg = ChatMessage(
        text: analysis,
        role: MessageRole.assistant,
        suggestions: suggestions,
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
    } catch (e) {
      state = state.copyWith(isTyping: false, error: e.toString());
    }
  }

  /// Get the monthly financial summary.
  Future<void> getSummary() async {
    state = state.copyWith(isTyping: true, error: null);
    final userMsg = ChatMessage(
      text: 'Summarize my finances this month',
      role: MessageRole.user,
    );
    state = state.copyWith(messages: [...state.messages, userMsg]);

    try {
      final data = await _repo.getSummary();
      final summary = data['summary']?.toString() ?? 'No summary available.';
      final suggestions = (data['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final aiMsg = ChatMessage(
        text: summary,
        role: MessageRole.assistant,
        suggestions: suggestions,
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
    } catch (e) {
      state = state.copyWith(isTyping: false, error: e.toString());
    }
  }

  /// Clear conversation history.
  void clearChat() {
    state = AiChatState(messages: [
      ChatMessage(
        text: 'Chat cleared. How can I help you with your finances?',
        role: MessageRole.assistant,
        suggestions: [
          'Analyze my spending',
          'Summarize my finances',
          'Budget tips',
        ],
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Global Providers
// ---------------------------------------------------------------------------

/// Main chat provider.
final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final repo = ref.read(aiAssistantRepositoryProvider);
  return AiChatNotifier(repo);
});

/// AI recommendations provider (standalone, cacheable).
final aiRecommendationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(aiAssistantRepositoryProvider);
  return repo.getRecommendations();
});

/// AI financial summary provider (standalone, cacheable).
final aiSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(aiAssistantRepositoryProvider);
  return repo.getSummary();
});

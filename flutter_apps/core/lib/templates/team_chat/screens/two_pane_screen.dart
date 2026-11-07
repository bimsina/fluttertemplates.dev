import 'package:flutter/material.dart';

import '../state/chat_scope.dart';
import '../widgets/chat_style.dart';
import '../widgets/empty_state.dart';
import 'conversation_info_screen.dart';
import 'conversations_screen.dart';
import 'new_conversation_screen.dart';
import 'thread_screen.dart';

/// Width at which the list and the thread sit side by side.
const twoPaneBreakpoint = 720.0;

class TwoPaneScreen extends StatelessWidget {
  const TwoPaneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = ChatScope.of(context).navigation;
    final selectedId = navigation.selectedId;
    final scheme = Theme.of(context).colorScheme;

    final Widget detail;
    if (selectedId == null) {
      detail = const Scaffold(
        key: ValueKey('placeholder'),
        body: EmptyState(
          icon: Icons.forum_rounded,
          title: 'Pick a conversation',
          message: 'Choose a thread on the left, or start a new one.',
        ),
      );
    } else if (navigation.isInfoOpen) {
      detail = ConversationInfoScreen(
        key: ValueKey('info-$selectedId'),
        conversationId: selectedId,
      );
    } else {
      detail = ThreadScreen(
        key: ValueKey(selectedId),
        conversationId: selectedId,
        showBack: false,
      );
    }

    // The outer Scaffold owns snack bars. Without it, each pane would show its
    // own copy, because ScaffoldMessenger targets every root Scaffold.
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 340,
            child: navigation.isComposing
                ? const NewConversationScreen()
                : const ConversationsScreen(),
          ),
          VerticalDivider(width: 1, thickness: 1, color: scheme.hairline),
          Expanded(child: detail),
        ],
      ),
    );
  }
}

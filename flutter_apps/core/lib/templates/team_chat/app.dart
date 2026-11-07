import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data/chat_repository.dart';
import 'data/default_repository.dart';
import 'screens/conversation_info_screen.dart';
import 'screens/conversations_screen.dart';
import 'screens/new_conversation_screen.dart';
import 'screens/thread_screen.dart';
import 'screens/two_pane_screen.dart';
import 'state/chat_navigation.dart';
import 'state/chat_scope.dart';
import 'state/chat_store.dart';

/// Root of the template. Place it anywhere under a `MaterialApp`.
///
/// Without a [repository] the app uses `createDefaultRepository()` from
/// `data/default_repository.dart`, which is the place to connect a real backend,
/// and disposes it. A repository passed in stays the caller's to dispose.
class TeamChatApp extends StatefulWidget {
  const TeamChatApp({
    super.key,
    this.repository,
    this.seedColor = const Color(0xFF1F6FEB),
  });

  final ChatRepository? repository;

  /// Brand color the whole app's color scheme is generated from.
  final Color seedColor;

  @override
  State<TeamChatApp> createState() => _TeamChatAppState();
}

class _TeamChatAppState extends State<TeamChatApp> {
  late final ChatRepository _repository =
      widget.repository ?? createDefaultRepository();
  late final ChatStore _store = ChatStore(_repository);
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _store.addListener(_showActionError);
  }

  void _showActionError() {
    final error = _store.takeActionError();
    if (error == null) return;
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  void dispose() {
    _store.removeListener(_showActionError);
    _store.dispose();
    if (widget.repository == null) _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final host = Theme.of(context);
    final theme = host.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: widget.seedColor,
        brightness: host.brightness,
      ),
    );
    return ChatScope(
      store: _store,
      child: ScaffoldMessenger(
        key: _messengerKey,
        child: Theme(
          data: theme.copyWith(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: const CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _ChatNavigator(
                navigation: _store.navigation,
                isWide: constraints.maxWidth >= twoPaneBreakpoint,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Maps [ChatNavigation] onto a page stack.
///
/// On wide layouts the thread, info and composer screens live inside the panes
/// of [TwoPaneScreen], so the stack is only the home page.
class _ChatNavigator extends StatefulWidget {
  const _ChatNavigator({required this.navigation, required this.isWide});

  final ChatNavigation navigation;
  final bool isWide;

  @override
  State<_ChatNavigator> createState() => _ChatNavigatorState();
}

class _ChatNavigatorState extends State<_ChatNavigator> {
  static const _homeKey = ValueKey('home');
  static const _threadKey = ValueKey('thread');
  static const _infoKey = ValueKey('info');
  static const _composerKey = ValueKey('composer');

  final _navigatorKey = GlobalKey<NavigatorState>();
  List<Page<void>> _pages = const [];

  List<Page<void>> _buildPages() {
    final navigation = widget.navigation;
    if (widget.isWide) {
      return const [MaterialPage(key: _homeKey, child: TwoPaneScreen())];
    }
    final selectedId = navigation.selectedId;
    return [
      const MaterialPage(key: _homeKey, child: ConversationsScreen()),
      if (selectedId != null)
        MaterialPage(
          key: _threadKey,
          child: ThreadScreen(
            key: ValueKey(selectedId),
            conversationId: selectedId,
          ),
        ),
      if (selectedId != null && navigation.isInfoOpen)
        MaterialPage(
          key: _infoKey,
          child: ConversationInfoScreen(conversationId: selectedId),
        ),
      if (navigation.isComposing)
        const MaterialPage(key: _composerKey, child: NewConversationScreen()),
    ];
  }

  /// Keeps the state in step when a page is popped by a back gesture or the
  /// system back button. Pages dropped by a rebuild need no action.
  void _onDidRemovePage(Page<Object?> page) {
    if (!_pages.any((current) => current.key == page.key)) return;
    final navigation = widget.navigation;
    switch (page.key) {
      case _threadKey:
        navigation.closeThread();
      case _infoKey:
        navigation.closeInfo();
      case _composerKey:
        navigation.closeComposer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.navigation,
      builder: (context, _) {
        _pages = _buildPages();
        return NavigatorPopHandler(
          onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
          child: Navigator(
            key: _navigatorKey,
            pages: _pages,
            onDidRemovePage: _onDidRemovePage,
          ),
        );
      },
    );
  }
}

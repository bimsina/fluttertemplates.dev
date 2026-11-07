import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/message.dart';
import 'chat_store.dart';

sealed class ThreadItem {
  const ThreadItem(this.key);

  /// Stable across updates, so list rows keep their state as messages arrive.
  final String key;
}

class DayItem extends ThreadItem {
  DayItem(this.day) : super('day-${day.toIso8601String()}');

  final DateTime day;
}

class UnreadItem extends ThreadItem {
  const UnreadItem() : super('unread');
}

class EventItem extends ThreadItem {
  EventItem(this.message) : super(message.id);

  final Message message;
}

class MessageItem extends ThreadItem {
  MessageItem({
    required this.message,
    required this.startsGroup,
    required this.endsGroup,
    this.quoted,
  }) : super(message.id);

  final Message message;

  /// Consecutive messages from one person are grouped: only the first shows
  /// the name and only the last shows the avatar and time.
  final bool startsGroup;
  final bool endsGroup;
  final Message? quoted;
}

/// Messages of the open thread, shaped into rows for the list: what the
/// repository streams, followed by the store's outbox.
class ThreadController extends ChangeNotifier {
  ThreadController({
    required ChatStore store,
    required String conversationId,
    required int unreadCount,
  }) : _store = store,
       _conversationId = conversationId,
       _pendingUnread = unreadCount {
    _outbox = store.outbox(conversationId);
    _knownIds.addAll(_outbox.map((m) => m.id));
    _rebuild();
    store.addListener(_onStoreChanged);
    _subscribe();
  }

  static const _groupGap = Duration(minutes: 5);

  final ChatStore _store;
  final String _conversationId;

  late StreamSubscription<List<Message>> _subscription;

  List<Message> _messages = const [];
  List<Message> _outbox = const [];
  List<ThreadItem> _items = const [];
  Map<String, int> _indexByKey = const {};
  final _knownIds = <String>{};
  final _freshIds = <String>{};
  bool _isLoading = true;
  bool _hasError = false;
  int _pendingUnread;
  String? _firstUnreadId;

  bool get isLoading => _isLoading;

  /// True while the message stream is failing, until it emits again.
  bool get hasError => _hasError;

  /// Rows, newest first, to match a reversed list.
  List<ThreadItem> get items => _items;

  int? indexOfKey(String key) => _indexByKey[key];

  /// True once for a message that arrived while the thread was open, so only
  /// new messages play the entrance animation.
  bool takeFresh(String id) => _freshIds.remove(id);

  /// Subscribes to the message stream again, after [hasError].
  void reconnect() {
    _subscription.cancel();
    _hasError = false;
    _subscribe();
    notifyListeners();
  }

  void _subscribe() {
    _subscription = _store.repository
        .watchMessages(_conversationId)
        .listen(_onMessages, onError: _onError);
  }

  void _onError(Object error, StackTrace stackTrace) {
    debugPrint('Message stream failed: $error\n$stackTrace');
    _hasError = true;
    notifyListeners();
  }

  void _onStoreChanged() {
    final outbox = _store.outbox(_conversationId);
    if (identical(outbox, _outbox)) return;
    _outbox = outbox;
    _freshIds.addAll(
      outbox.map((m) => m.id).where((id) => !_knownIds.contains(id)),
    );
    _knownIds.addAll(outbox.map((m) => m.id));
    _rebuild();
  }

  void _onMessages(List<Message> messages) {
    _hasError = false;
    if (_isLoading) {
      if (_pendingUnread > 0 && _pendingUnread <= messages.length) {
        _firstUnreadId = messages[messages.length - _pendingUnread].id;
      }
      _pendingUnread = 0;
    } else {
      _freshIds.addAll(
        messages.map((m) => m.id).where((id) => !_knownIds.contains(id)),
      );
    }
    _knownIds.addAll(messages.map((m) => m.id));
    _isLoading = false;
    _messages = messages;
    _store.acknowledge(_conversationId, messages.map((m) => m.id));
    _outbox = _store.outbox(_conversationId);
    _rebuild();
  }

  void _rebuild() {
    _items = _buildItems();
    _indexByKey = {for (var i = 0; i < _items.length; i++) _items[i].key: i};
    notifyListeners();
  }

  List<ThreadItem> _buildItems() {
    final streamed = {for (final message in _messages) message.id};
    final messages = [
      ..._messages,
      ..._outbox.where((message) => !streamed.contains(message.id)),
    ];
    final byId = {for (final message in messages) message.id: message};
    final rows = <ThreadItem>[];

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final previous = i > 0 ? messages[i - 1] : null;
      final next = i + 1 < messages.length ? messages[i + 1] : null;

      if (previous == null || !_sameDay(previous.sentAt, message.sentAt)) {
        final at = message.sentAt;
        rows.add(DayItem(DateTime(at.year, at.month, at.day)));
      }
      if (message.id == _firstUnreadId) rows.add(const UnreadItem());

      if (message.isSystem) {
        rows.add(EventItem(message));
        continue;
      }
      rows.add(
        MessageItem(
          message: message,
          startsGroup:
              message.id == _firstUnreadId ||
              previous == null ||
              !_continues(previous, message),
          endsGroup:
              next == null ||
              next.id == _firstUnreadId ||
              !_continues(message, next),
          quoted: byId[message.replyToId],
        ),
      );
    }
    return rows.reversed.toList();
  }

  bool _continues(Message earlier, Message later) {
    return !earlier.isSystem &&
        !later.isSystem &&
        earlier.senderId == later.senderId &&
        _sameDay(earlier.sentAt, later.sentAt) &&
        later.sentAt.difference(earlier.sentAt) < _groupGap;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _subscription.cancel();
    super.dispose();
  }
}

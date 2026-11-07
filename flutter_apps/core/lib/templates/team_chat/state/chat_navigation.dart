import 'package:flutter/foundation.dart';

/// Which screens are open.
///
/// The navigator's page stack and the two-pane layout are both derived from
/// this state, so resizing between them keeps you in the same place.
class ChatNavigation extends ChangeNotifier {
  String? _selectedId;
  String? _focusMessageId;
  int _unreadAtOpen = 0;
  bool _isInfoOpen = false;
  bool _isComposing = false;

  String? get selectedId => _selectedId;

  /// A message to scroll to when the thread opens, set by search results.
  String? get focusMessageId => _focusMessageId;

  /// Unread count when the thread was opened, for the "New" divider.
  int get unreadAtOpen => _unreadAtOpen;
  bool get isInfoOpen => _isInfoOpen;
  bool get isComposing => _isComposing;

  void openThread(String id, {String? focusMessageId, int unreadCount = 0}) {
    _selectedId = id;
    _focusMessageId = focusMessageId;
    _unreadAtOpen = unreadCount;
    _isInfoOpen = false;
    _isComposing = false;
    notifyListeners();
  }

  void closeThread() {
    if (_selectedId == null) return;
    _selectedId = null;
    _focusMessageId = null;
    _unreadAtOpen = 0;
    _isInfoOpen = false;
    notifyListeners();
  }

  void openInfo() {
    _isInfoOpen = true;
    notifyListeners();
  }

  void closeInfo() {
    if (!_isInfoOpen) return;
    _isInfoOpen = false;
    notifyListeners();
  }

  void openComposer() {
    _isComposing = true;
    notifyListeners();
  }

  void closeComposer() {
    if (!_isComposing) return;
    _isComposing = false;
    notifyListeners();
  }
}

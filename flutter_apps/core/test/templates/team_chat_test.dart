import 'dart:async';
import 'dart:math';

import 'package:core/templates/team_chat/app.dart';
import 'package:core/templates/team_chat/data/chat_repository.dart';
import 'package:core/templates/team_chat/data/fake_chat_repository.dart';
import 'package:core/templates/team_chat/models/conversation.dart';
import 'package:core/templates/team_chat/models/message.dart';
import 'package:core/templates/team_chat/screens/conversations_screen.dart';
import 'package:core/templates/team_chat/state/chat_scope.dart';
import 'package:core/templates/team_chat/state/chat_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _thread = 'dm-priya';

/// The fake backend with switches for each way a real one can fail.
class FailingChatRepository extends FakeChatRepository {
  FailingChatRepository() : super(ambientActivity: false, random: Random(1));

  int failNextSends = 0;
  bool loseNextResponse = false;
  bool hangNextSend = false;

  /// Errors that are not rejections, raised before anything is stored.
  int dropNextSends = 0;

  /// Keeps new messages off the stream, as a lagging realtime feed would.
  bool holdMessages = false;
  bool failReads = false;
  bool failMutations = false;
  int failConversationWatches = 0;
  int failMessageWatches = 0;
  final clientIds = <String?>[];
  final messageErrors = StreamController<List<Message>>.broadcast();

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String text,
    String? replyToId,
    String? clientMessageId,
  }) async {
    clientIds.add(clientMessageId);
    if (hangNextSend) {
      hangNextSend = false;
      return Completer<Message>().future;
    }
    if (dropNextSends > 0) {
      dropNextSends--;
      throw StateError('connection dropped');
    }
    if (failNextSends > 0) {
      failNextSends--;
      nextSendFault = FakeSendFault.rejected;
    } else if (loseNextResponse) {
      loseNextResponse = false;
      nextSendFault = FakeSendFault.responseLost;
    }
    return super.sendMessage(
      conversationId: conversationId,
      text: text,
      replyToId: replyToId,
      clientMessageId: clientMessageId,
    );
  }

  @override
  Stream<List<Conversation>> watchConversations() {
    if (failConversationWatches > 0) {
      failConversationWatches--;
      return Stream.error(StateError('conversations failed'));
    }
    return super.watchConversations();
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    if (failMessageWatches > 0) {
      failMessageWatches--;
      return Stream.error(StateError('messages failed'));
    }
    final controller = StreamController<List<Message>>();
    final data = super.watchMessages(conversationId).listen((messages) {
      if (!holdMessages) controller.add(messages);
    });
    final errors = messageErrors.stream.listen(
      null,
      onError: controller.addError,
    );
    controller.onCancel = () {
      data.cancel();
      errors.cancel();
    };
    return controller.stream;
  }

  @override
  Future<void> markRead(String conversationId) async {
    if (failReads) throw StateError('markRead failed');
    return super.markRead(conversationId);
  }

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    if (failMutations) throw StateError('delete failed');
    return super.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  @override
  Future<void> toggleReaction({
    required String conversationId,
    required String messageId,
    required ReactionKind kind,
  }) async {
    if (failMutations) throw StateError('reaction failed');
    return super.toggleReaction(
      conversationId: conversationId,
      messageId: messageId,
      kind: kind,
    );
  }

  @override
  Future<List<Message>> searchMessages(String query) async {
    if (failMutations) throw StateError('search failed');
    return super.searchMessages(query);
  }

  Future<List<Message>> stored(String conversationId) {
    return super.watchMessages(conversationId).first;
  }
}

Future<ChatStore> _pumpApp(
  WidgetTester tester,
  FailingChatRepository repository,
) async {
  tester.view.physicalSize = const Size(420, 860);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(home: TeamChatApp(repository: repository)),
  );
  await _settle(tester);
  return ChatScope.read(tester.element(find.byType(ConversationsScreen)));
}

/// Pumps past animations. The typing indicator repeats, so this can't settle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _open(WidgetTester tester, ChatStore store) async {
  store.openConversation(_thread);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).last, text);
  await tester.pump();
}

Future<void> _sendFromComposer(WidgetTester tester, String text) async {
  await _type(tester, text);
  await tester.tap(find.byTooltip('Send'));
  await _settle(tester);
}

/// Reads the backend's messages outside the widget test's fake clock.
Future<List<Message>> _stored(
  WidgetTester tester,
  FailingChatRepository repository,
) async {
  return (await tester.runAsync(() => repository.stored(_thread)))!;
}

/// Unmounts the app and cancels the fake's timers.
Future<void> _finish(
  WidgetTester tester,
  FailingChatRepository repository,
) async {
  await tester.pumpWidget(const SizedBox());
  repository.dispose();
}

void main() {
  group('failed sends', () {
    testWidgets('keep the text and offer a visible retry', (tester) async {
      final repository = FailingChatRepository()..failNextSends = 1;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);

      await _sendFromComposer(tester, 'Ship it');

      expect(tester.takeException(), isNull);
      expect(find.text('Ship it'), findsOneWidget);
      expect(find.text('Not sent'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await _settle(tester);

      expect(find.text('Not sent'), findsNothing);
      expect(find.text('Ship it'), findsOneWidget);
      final stored = await _stored(tester, repository);
      expect(stored.where((m) => m.text == 'Ship it'), hasLength(1));
      await _finish(tester, repository);
    });

    testWidgets('show as sending until the repository answers', (tester) async {
      final repository = FailingChatRepository()..hangNextSend = true;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);

      await _sendFromComposer(tester, 'Still going');
      expect(find.text('Still going'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);

      await tester.pump(const Duration(seconds: 31));
      await _settle(tester);
      expect(find.text('May not have sent'), findsOneWidget);
      expect(find.text('Not sent'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      await _finish(tester, repository);
    });

    testWidgets('every failed message in a group offers retry', (tester) async {
      final repository = FailingChatRepository()..failNextSends = 2;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);

      await _sendFromComposer(tester, 'One');
      await _sendFromComposer(tester, 'Two');

      expect(find.text('Retry'), findsNWidgets(2));
      await _finish(tester, repository);
    });

    testWidgets('can be edited back into the composer with the reply', (
      tester,
    ) async {
      final repository = FailingChatRepository()..failNextSends = 1;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);
      final quoted = (await _stored(tester, repository)).last;
      store.setReplyTarget(quoted);
      await tester.pump();

      await _sendFromComposer(tester, 'Recover me');
      expect(store.replyTarget(_thread), isNull);

      await tester.tap(find.text('Edit'));
      await _settle(tester);

      expect(store.draft(_thread), 'Recover me');
      expect(store.replyTarget(_thread)?.id, quoted.id);
      final field = tester.widget<TextField>(find.byType(TextField).last);
      expect(field.controller!.text, 'Recover me');
      expect(find.text('Not sent'), findsNothing);
      await _finish(tester, repository);
    });

    testWidgets('editing keeps what is already in the composer', (
      tester,
    ) async {
      final repository = FailingChatRepository()..failNextSends = 1;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);

      await _sendFromComposer(tester, 'First');
      await _type(tester, 'Second');
      await tester.tap(find.text('Edit'));
      await _settle(tester);

      expect(store.draft(_thread), 'Second\nFirst');
      await _finish(tester, repository);
    });

    testWidgets('show on the conversation list', (tester) async {
      final repository = FailingChatRepository()..failNextSends = 1;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);
      await _sendFromComposer(tester, 'Hello');

      store.navigation.closeThread();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Message not sent'), findsOneWidget);
      await _finish(tester, repository);
    });

    testWidgets('survive leaving the thread and coming back', (tester) async {
      final repository = FailingChatRepository()..failNextSends = 1;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);
      await _sendFromComposer(tester, 'Come back');

      store.navigation.closeThread();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await _open(tester, store);

      expect(find.text('Come back'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      await _finish(tester, repository);
    });
  });

  group('unknown send outcomes', () {
    Future<FailingChatRepository> lostResponse(
      WidgetTester tester, [
      void Function(ChatStore)? onStore,
    ]) async {
      final repository = FailingChatRepository();
      final store = await _pumpApp(tester, repository);
      onStore?.call(store);
      await _open(tester, store);
      repository
        ..holdMessages = true
        ..loseNextResponse = true;
      await _sendFromComposer(tester, 'Did it land');
      return repository;
    }

    testWidgets('say the message may not have sent', (tester) async {
      final repository = await lostResponse(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('May not have sent'), findsOneWidget);
      expect(find.text('Not sent'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      await _finish(tester, repository);
    });

    testWidgets('retry with the same client id and post once', (tester) async {
      final repository = await lostResponse(tester);

      await tester.tap(find.text('Retry'));
      await _settle(tester);

      expect(find.text('May not have sent'), findsNothing);
      expect(find.text('Did it land'), findsOneWidget);
      expect(repository.clientIds, hasLength(2));
      expect(repository.clientIds.last, repository.clientIds.first);
      final stored = await _stored(tester, repository);
      expect(stored.where((m) => m.text == 'Did it land'), hasLength(1));
      await _finish(tester, repository);
    });

    testWidgets('warn before an edit, and Cancel changes nothing', (
      tester,
    ) async {
      late ChatStore store;
      final repository = await lostResponse(tester, (s) => store = s);

      await tester.tap(find.text('Edit'));
      await _settle(tester);
      expect(find.textContaining('posts a second message'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await _settle(tester);

      expect(find.text('May not have sent'), findsOneWidget);
      expect(store.draft(_thread), isEmpty);
      await _finish(tester, repository);
    });

    testWidgets('move to the composer once the warning is accepted', (
      tester,
    ) async {
      late ChatStore store;
      final repository = await lostResponse(tester, (s) => store = s);

      await tester.tap(find.text('Edit'));
      await _settle(tester);
      await tester.tap(find.text('Edit anyway'));
      await _settle(tester);

      expect(find.text('May not have sent'), findsNothing);
      expect(store.draft(_thread), 'Did it land');
      await _finish(tester, repository);
    });

    testWidgets('clear when the stream shows the message arrived', (
      tester,
    ) async {
      final repository = await lostResponse(tester);
      final latest = (await _stored(tester, repository)).last;

      repository.holdMessages = false;
      await repository.toggleReaction(
        conversationId: _thread,
        messageId: latest.id,
        kind: ReactionKind.like,
      );
      await _settle(tester);

      expect(find.text('May not have sent'), findsNothing);
      expect(find.text('Did it land'), findsOneWidget);
      await _finish(tester, repository);
    });

    testWidgets('show honestly on the conversation list', (tester) async {
      final repository = FailingChatRepository()..dropNextSends = 1;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);
      await _sendFromComposer(tester, 'Did it land');

      store.navigation.closeThread();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Message may not have sent'), findsOneWidget);
      expect(find.text('Message not sent'), findsNothing);
      await _finish(tester, repository);
    });

    testWidgets('a rejection edits with no warning', (tester) async {
      final repository = FailingChatRepository()..failNextSends = 1;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);
      await _sendFromComposer(tester, 'Rejected');
      expect(find.text('Not sent'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await _settle(tester);

      expect(find.text('Edit anyway'), findsNothing);
      expect(store.draft(_thread), 'Rejected');
      await _finish(tester, repository);
    });
  });

  group('FakeChatRepository send faults', () {
    late FakeChatRepository repository;

    setUp(() {
      repository = FakeChatRepository(
        ambientActivity: false,
        random: Random(1),
      );
      addTearDown(repository.dispose);
    });

    Future<Message> send(String id) {
      return repository.sendMessage(
        conversationId: _thread,
        text: 'Hello',
        clientMessageId: id,
      );
    }

    Future<Iterable<Message>> withId(String id) async {
      final messages = await repository.watchMessages(_thread).first;
      return messages.where((m) => m.id == id);
    }

    test('a rejection stores nothing and clears itself', () async {
      repository.nextSendFault = FakeSendFault.rejected;
      await expectLater(send('a'), throwsA(isA<MessageRejectedException>()));
      expect(await withId('a'), isEmpty);

      await send('a');
      expect(await withId('a'), hasLength(1));
    });

    test('a lost response stores the message, and a replay finds it', () async {
      repository.nextSendFault = FakeSendFault.responseLost;
      await expectLater(send('b'), throwsA(isA<TimeoutException>()));
      expect(await withId('b'), hasLength(1));

      final replay = await send('b');
      expect(replay.id, 'b');
      expect(await withId('b'), hasLength(1));
    });

    test('a conversation that is gone rejects the send', () async {
      await repository.leaveConversation(_thread);
      await expectLater(send('c'), throwsA(isA<MessageRejectedException>()));
    });
  });

  group('ChatStore outbox', () {
    late FailingChatRepository repository;
    late ChatStore store;

    setUp(() {
      repository = FailingChatRepository();
      store = ChatStore(repository);
      addTearDown(() {
        store.dispose();
        repository.dispose();
      });
    });

    test('a failed send is not an uncaught error', () async {
      repository.failNextSends = 1;
      store.send(_thread, 'Hello');
      expect(store.outbox(_thread).single.status, MessageStatus.sending);
      await pumpEventQueue();
      expect(store.outbox(_thread).single.status, MessageStatus.failed);
      expect(store.outbox(_thread).single.text, 'Hello');
      expect(store.failedCount(_thread), 1);
    });

    test('a retry after a lost response posts once', () async {
      repository.loseNextResponse = true;
      store.send(_thread, 'Once only');
      await pumpEventQueue();
      expect(store.outbox(_thread).single.status, MessageStatus.unconfirmed);

      store.retry(store.outbox(_thread).single);
      await pumpEventQueue();

      final stored = await repository.stored(_thread);
      expect(stored.where((m) => m.text == 'Once only'), hasLength(1));
      expect(repository.clientIds, hasLength(2));
      expect(repository.clientIds.first, isNotNull);
      expect(repository.clientIds.last, repository.clientIds.first);
    });

    test('retry ignores a message that is already sending', () async {
      repository.failNextSends = 1;
      store.send(_thread, 'Hello');
      await pumpEventQueue();
      final failed = store.outbox(_thread).single;
      store.retry(failed);
      store.retry(failed);
      await pumpEventQueue();
      expect(repository.clientIds, hasLength(2));
    });

    test('deleting a failed message only drops it locally', () async {
      repository.failNextSends = 1;
      store.send(_thread, 'Hello');
      await pumpEventQueue();
      store.deleteMessage(store.outbox(_thread).single);
      expect(store.outbox(_thread), isEmpty);
    });

    test('an error that is not a rejection is an unknown outcome', () async {
      repository.dropNextSends = 1;
      store.send(_thread, 'Hello');
      await pumpEventQueue();
      expect(store.outbox(_thread).single.status, MessageStatus.unconfirmed);
      expect(store.unconfirmedCount(_thread), 1);
      expect(store.failedCount(_thread), 0);
    });

    test('an unconfirmed message cannot be reacted to or quoted', () async {
      repository.loseNextResponse = true;
      store.send(_thread, 'Hello');
      await pumpEventQueue();
      expect(store.isUnsent(store.outbox(_thread).single), isTrue);
    });

    test('editing an unconfirmed message needs the risk accepted', () async {
      repository.loseNextResponse = true;
      store.send(_thread, 'One logical message');
      await pumpEventQueue();
      final unconfirmed = store.outbox(_thread).single;

      // What the review reproduced: Edit, then send what the composer holds.
      store.editFailed(unconfirmed);
      store.send(_thread, store.draft(_thread));
      await pumpEventQueue();

      expect(store.outbox(_thread).single.id, unconfirmed.id);
      final stored = await repository.stored(_thread);
      expect(
        stored.where((m) => m.text == 'One logical message'),
        hasLength(1),
      );
      expect(repository.clientIds, hasLength(1));

      store.editFailed(unconfirmed, acceptDuplicateRisk: true);
      expect(store.outbox(_thread), isEmpty);
      expect(store.draft(_thread), 'One logical message');
    });

    test('a rejected message edits freely and posts once', () async {
      repository.failNextSends = 1;
      store.send(_thread, 'Fix me');
      await pumpEventQueue();
      expect(store.outbox(_thread).single.status, MessageStatus.failed);

      store.editFailed(store.outbox(_thread).single);
      expect(store.draft(_thread), 'Fix me');
      store.send(_thread, 'Fixed');
      await pumpEventQueue();

      final stored = await repository.stored(_thread);
      expect(stored.where((m) => m.text == 'Fix me'), isEmpty);
      expect(stored.where((m) => m.text == 'Fixed'), hasLength(1));
    });

    test('deleting an unconfirmed message deletes it on the server', () async {
      repository.loseNextResponse = true;
      store.send(_thread, 'Take it back');
      await pumpEventQueue();
      final unconfirmed = store.outbox(_thread).single;

      store.deleteMessage(unconfirmed);
      await pumpEventQueue();

      expect(store.outbox(_thread), isEmpty);
      final stored = await repository.stored(_thread);
      expect(stored.singleWhere((m) => m.id == unconfirmed.id).isDeleted, true);
    });

    test('an unconfirmed message stays if the delete fails', () async {
      repository.loseNextResponse = true;
      store.send(_thread, 'Take it back');
      await pumpEventQueue();
      repository.failMutations = true;

      store.deleteMessage(store.outbox(_thread).single);
      await pumpEventQueue();

      expect(store.outbox(_thread).single.status, MessageStatus.unconfirmed);
      expect(store.takeActionError(), 'Could not delete the message.');
    });

    test('leaving clears the outbox even with a send in flight', () async {
      repository.hangNextSend = true;
      store.send(_thread, 'Hello');
      await store.leave(_thread);
      expect(store.outbox(_thread), isEmpty);
    });

    test('a starter chip leaves an unrelated draft alone', () async {
      store.setDraft(_thread, 'Half written');
      store.send(_thread, 'Hey!');
      expect(store.draft(_thread), 'Half written');
    });

    test('a store disposed mid-send stays quiet', () async {
      final other = ChatStore(repository);
      repository.failNextSends = 1;
      other.send(_thread, 'Hello');
      other.dispose();
      await pumpEventQueue();
    });

    test('failed background calls are caught and reported', () async {
      repository
        ..failMutations = true
        ..failReads = true;
      final message = (await repository.stored(_thread)).last;

      store.deleteMessage(message);
      await pumpEventQueue();
      expect(store.takeActionError(), 'Could not delete the message.');

      store.toggleReaction(message, ReactionKind.like);
      await pumpEventQueue();
      expect(store.takeActionError(), 'Could not update the reaction.');

      store.openConversation(_thread);
      await pumpEventQueue();
      expect(store.takeActionError(), isNull);
    });
  });

  group('stream errors', () {
    testWidgets('a failed first load shows an error with retry', (
      tester,
    ) async {
      final repository = FailingChatRepository()..failConversationWatches = 1;
      await _pumpApp(tester, repository);

      expect(tester.takeException(), isNull);
      expect(find.text('Could not load conversations'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await _settle(tester);

      expect(find.text('Could not load conversations'), findsNothing);
      expect(find.text('Priya Nair'), findsWidgets);
      await _finish(tester, repository);
    });

    testWidgets('a failed thread load shows an error with retry', (
      tester,
    ) async {
      final repository = FailingChatRepository()..failMessageWatches = 1;
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);

      expect(tester.takeException(), isNull);
      expect(find.text('Could not load messages'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await _settle(tester);

      expect(find.text('Could not load messages'), findsNothing);
      await _finish(tester, repository);
    });

    testWidgets('an error mid-thread keeps messages and shows a banner', (
      tester,
    ) async {
      final repository = FailingChatRepository();
      final store = await _pumpApp(tester, repository);
      await _open(tester, store);
      final last = (await _stored(tester, repository)).last;

      repository.messageErrors.addError(StateError('socket closed'));
      await _settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Connection lost'), findsOneWidget);
      expect(find.text(last.text), findsOneWidget);

      await tester.tap(find.text('Reconnect'));
      await _settle(tester);
      expect(find.textContaining('Connection lost'), findsNothing);
      await _finish(tester, repository);
    });

    test('the store reports a failing stream and recovers', () async {
      final repository = FailingChatRepository()..failConversationWatches = 1;
      final store = ChatStore(repository);
      addTearDown(() {
        store.dispose();
        repository.dispose();
      });

      await pumpEventQueue();
      expect(store.hasSyncError, isTrue);
      expect(store.isReady, isFalse);

      store.reconnect();
      await pumpEventQueue();
      expect(store.hasSyncError, isFalse);
      expect(store.isReady, isTrue);
    });
  });

  testWidgets('a failed background action shows a snack bar', (tester) async {
    final repository = FailingChatRepository()..failMutations = true;
    final store = await _pumpApp(tester, repository);
    await _open(tester, store);

    store.deleteMessage((await _stored(tester, repository)).last);
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Could not delete the message.'), findsOneWidget);
    await _finish(tester, repository);
  });

  testWidgets('a failed search is reported, not thrown', (tester) async {
    final repository = FailingChatRepository()..failMutations = true;
    final store = await _pumpApp(tester, repository);

    store.setQuery('launch');
    await tester.pump(const Duration(milliseconds: 200));
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Could not search messages.'), findsOneWidget);
    await _finish(tester, repository);
  });
}

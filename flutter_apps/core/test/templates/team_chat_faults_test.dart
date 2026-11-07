import 'dart:async';
import 'dart:math';

import 'package:core/templates/team_chat/app.dart';
import 'package:core/templates/team_chat/data/fake_chat_repository.dart';
import 'package:core/templates/team_chat/models/message.dart';
import 'package:core/templates/team_chat/state/chat_store.dart';
import 'package:core/templates/team_chat/screens/conversation_info_screen.dart';
import 'package:core/templates/team_chat/state/chat_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The fake backend with switches for leaving and deleting.
class FaultyLeaveRepository extends FakeChatRepository {
  FaultyLeaveRepository() : super(ambientActivity: false, random: Random(1));

  bool rejectLeave = false;
  bool loseLeaveResponse = false;
  bool hangLeave = false;
  bool rejectDelete = false;
  Completer<void>? leaveGate;
  int leaveCalls = 0;

  @override
  Future<void> leaveConversation(String conversationId) async {
    leaveCalls++;
    await leaveGate?.future;
    if (hangLeave) return Completer<void>().future;
    if (rejectLeave) throw StateError('leave rejected');
    await super.leaveConversation(conversationId);
    if (loseLeaveResponse) {
      // After the stream has told the store.
      await pumpEventQueue();
      throw TimeoutException('The response was lost');
    }
  }

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    if (rejectDelete) throw StateError('delete rejected');
    await super.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }
}

void main() {
  late FaultyLeaveRepository repository;
  late ChatStore store;
  late String groupId;

  /// A thread holding everything a leave could destroy.
  Future<Message> fillThread() async {
    store.openConversation(groupId);
    repository.nextSendFault = FakeSendFault.rejected;
    store.send(groupId, 'Only copy of a failed message');
    await pumpEventQueue();
    final messages = await repository.watchMessages(groupId).first;
    store.setDraft(groupId, 'Unsent draft');
    store.setReplyTarget(messages.last);
    return messages.last;
  }

  void expectThreadIntact(Message replyTarget) {
    expect(store.conversation(groupId), isNotNull);
    expect(store.navigation.selectedId, groupId);
    expect(store.draft(groupId), 'Unsent draft');
    expect(store.replyTarget(groupId)?.id, replyTarget.id);
    expect(store.outbox(groupId).single.text, 'Only copy of a failed message');
    expect(store.outbox(groupId).single.status, MessageStatus.failed);
  }

  void expectThreadForgotten() {
    expect(store.navigation.selectedId, isNull);
    expect(store.draft(groupId), isEmpty);
    expect(store.replyTarget(groupId), isNull);
    expect(store.outbox(groupId), isEmpty);
  }

  setUp(() async {
    repository = FaultyLeaveRepository();
    store = ChatStore(repository);
    await pumpEventQueue();
    groupId = store.conversations.firstWhere((c) => c.isGroup).id;
  });

  tearDown(() {
    store.dispose();
    repository.dispose();
  });

  group('leaving', () {
    test('a refused leave keeps the draft, reply and failed message', () async {
      final target = await fillThread();
      repository.rejectLeave = true;

      expect(await store.leave(groupId), isFalse);

      expectThreadIntact(target);
      expect(store.takeActionError(), 'Could not leave the conversation.');
    });

    test('nothing is cleared while the call is running', () async {
      final target = await fillThread();
      repository.leaveGate = Completer<void>();

      final leaving = store.leave(groupId);
      await pumpEventQueue();
      expectThreadIntact(target);

      repository.leaveGate!.complete();
      expect(await leaving, isTrue);
      expectThreadForgotten();
    });

    test('a successful leave clears everything', () async {
      await fillThread();

      expect(await store.leave(groupId), isTrue);
      await pumpEventQueue();

      expectThreadForgotten();
      expect(store.conversation(groupId), isNull);
      expect(store.takeActionError(), isNull);
    });

    test('a lost response counts once the stream shows the leave', () async {
      await fillThread();
      repository.loseLeaveResponse = true;

      expect(await store.leave(groupId), isTrue);

      expectThreadForgotten();
      expect(store.takeActionError(), isNull);
    });

    test(
      'a removal that arrives after a failed leave closes the thread',
      () async {
        await fillThread();
        repository.rejectLeave = true;
        expect(await store.leave(groupId), isFalse);

        repository.rejectLeave = false;
        await repository.leaveConversation(groupId);
        await pumpEventQueue();

        expectThreadForgotten();
      },
    );

    test('a thread opened before it is listed stays open', () async {
      store.navigation.openThread('not-listed-yet');

      repository.nextSendFault = null;
      await repository.setPinned(groupId, pinned: true);
      await pumpEventQueue();

      expect(store.navigation.selectedId, 'not-listed-yet');
    });

    test('a second tap while leaving sends nothing', () async {
      await fillThread();
      repository.leaveGate = Completer<void>();

      final leaving = store.leave(groupId);
      expect(await store.leave(groupId), isFalse);
      repository.leaveGate!.complete();
      await leaving;

      expect(repository.leaveCalls, 1);
    });

    test('a thread opened during the call stays open', () async {
      await fillThread();
      repository.leaveGate = Completer<void>();
      final other = store.conversations.firstWhere((c) => c.id != groupId).id;

      final leaving = store.leave(groupId);
      store.openConversation(other);
      repository.leaveGate!.complete();
      await leaving;

      expect(store.navigation.selectedId, other);
      expect(store.draft(groupId), isEmpty);
    });

    test('a store disposed during the call stays quiet', () async {
      final other = ChatStore(repository);
      await pumpEventQueue();
      repository
        ..leaveGate = Completer<void>()
        ..rejectLeave = true;

      final leaving = other.leave(groupId);
      other.dispose();
      repository.leaveGate!.complete();

      expect(await leaving, isFalse);
    });
  });

  testWidgets('a leave that never answers fails and keeps the thread', (
    tester,
  ) async {
    final repository = FaultyLeaveRepository();
    final store = ChatStore(repository);
    await tester.pump();
    final id = store.conversations.firstWhere((c) => c.isGroup).id;
    store
      ..openConversation(id)
      ..setDraft(id, 'Unsent draft');
    repository.hangLeave = true;

    final leaving = store.leave(id);
    await tester.pump(ChatStore.leaveTimeout);
    await tester.pump(const Duration(seconds: 1));

    expect(await leaving, isFalse);
    expect(store.draft(id), 'Unsent draft');
    expect(store.takeActionError(), 'Could not leave the conversation.');
    store.dispose();
    repository.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  group('deleting', () {
    test('a refused delete keeps the reply target', () async {
      final target = await fillThread();
      repository.rejectDelete = true;

      store.deleteMessage(target);
      await pumpEventQueue();

      expect(store.replyTarget(groupId)?.id, target.id);
      expect(store.takeActionError(), 'Could not delete the message.');
    });

    test('a successful delete clears the reply target', () async {
      final target = await fillThread();

      store.deleteMessage(target);
      await pumpEventQueue();

      expect(store.replyTarget(groupId), isNull);
    });
  });

  group('info screen', () {
    Future<(ChatStore, FaultyLeaveRepository)> openInfo(
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(375, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = FaultyLeaveRepository();
      await tester.pumpWidget(
        MaterialApp(home: TeamChatApp(repository: repository)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Launch crew'));
      await tester.pumpAndSettle();
      final store = ChatScope.read(tester.element(find.byType(Scaffold).first));
      store.navigation.openInfo();
      await tester.pumpAndSettle();
      expect(find.byType(ConversationInfoScreen), findsOneWidget);
      return (store, repository);
    }

    Future<void> confirmLeave(WidgetTester tester) async {
      await tester.tap(find.text('Leave group'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
    }

    Future<void> unmount(
      WidgetTester tester,
      FaultyLeaveRepository repository,
    ) async {
      await tester.pumpWidget(const SizedBox());
      repository.dispose();
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('a refused leave says so, and not "You left"', (tester) async {
      final (store, repository) = await openInfo(tester);
      final id = store.navigation.selectedId!;
      store.setDraft(id, 'Unsent draft');
      repository.rejectLeave = true;

      await confirmLeave(tester);

      expect(find.text('Could not leave the conversation.'), findsOneWidget);
      expect(find.textContaining('You left'), findsNothing);
      expect(find.byType(ConversationInfoScreen), findsOneWidget);
      expect(store.draft(id), 'Unsent draft');
      await unmount(tester, repository);
    });

    testWidgets('a successful leave confirms and closes', (tester) async {
      final (_, repository) = await openInfo(tester);

      await confirmLeave(tester);

      expect(find.textContaining('You left'), findsOneWidget);
      expect(find.byType(ConversationInfoScreen), findsNothing);
      await unmount(tester, repository);
    });
  });
}

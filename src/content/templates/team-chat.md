---
heroImage: "../../assets/template_images/team-chat.png"
title: "Team Chat"
description: "Flutter team chat app template with a conversation list, unread badges, message search, direct and group threads, typing indicators, reactions, reply-to, group info and a two-pane tablet layout. Uses only the Flutter SDK, with ChangeNotifier state and a stream-based repository you can swap for a real backend."
summary: "Direct and group threads, reactions, search and a two-pane tablet layout."
type: full-app
path: /templates/team_chat
code_dir: templates/team_chat
tags: ["chat", "messaging", "team", "groups", "responsive", "tablet", "changenotifier", "streams"]
---

## What's included

- **Conversation list.** Unread badges, pinned and muted threads, drafts, live typing status, and All, Unread and Groups filters
- **Search.** Covers conversations, people and message text. Tapping a message result opens the thread and scrolls to that message
- **Direct and group threads.** Consecutive messages grouped, date separators, a "New" divider at the first unread message, and delivery status
- **Failed sends.** They stay in the thread with Retry and Edit, and the conversation list shows them. A send the backend refused is marked "Not sent", and Edit puts the text and the reply target back in the composer. A send with no answer is marked "May not have sent", because it may have arrived: Retry reuses the same client id, and Edit warns first that the edit could post a second message
- **Connection errors.** A retry screen if conversations or a thread can't load, and a banner with Reconnect if a stream fails later. Other failed actions show a snack bar
- **Simulated teammates.** Send a message and someone starts typing, then replies. Replies keep arriving after you leave the thread, so the unread badge updates
- **Message actions.** Reactions, reply-to with a tappable quote, copy, and delete. Open the actions with a long press, a right click or the hover button. Swipe a message right to reply
- **Group info.** Rename, add people, mute, pin and leave, with a details page for direct threads. Leaving waits for the server, so if it fails you stay in the thread with your draft, reply and unsent messages
- **New conversation.** Starts a direct thread with one person or a group with several
- **Two-pane layout.** From 720px wide. Resizing keeps the open thread and any draft
- **Empty states.** For no conversations, no unread messages, no groups, no search results and new threads

Colors come from `Theme.of(context).colorScheme`, so the app follows the host theme in light and dark. Avatars are initials and reactions are Material icons, so there are no image or emoji font downloads.

## Structure

```
team_chat/
  app.dart      TeamChatApp, the store and the nested Navigator
  models/       ChatUser, Conversation, Message
  data/         ChatRepository interface, the swap point, in-memory fake, sample data
  state/        ChatStore, ChatNavigation, ThreadController, ChatScope
  screens/      List, thread, info, new conversation, two-pane shell
  widgets/      Avatars, message row, composer, typing indicator and others
```

All imports are relative, so you can copy the folder into any project. Place the widget anywhere below a `MaterialApp`:

```dart
MaterialApp(home: const TeamChatApp());
```

`ChatNavigation` holds which screens are open, and the page stack is built from it. The same state drives the phone stack and the two panes, which is why a thread stays open when the layout changes.

## Connecting a real backend

The UI only talks to the `ChatRepository` interface in `data/chat_repository.dart`, and `data/default_repository.dart` is the only file that names the fake.

1. Create a class that implements `ChatRepository`.
2. Back each `watch` method with your realtime source, such as a websocket or a database query. Each stream should emit the current value on listen and again on every change.
3. Back the other methods with your API calls. `sendMessage` should throw `MessageRejectedException` only when you know the message wasn't kept. Any other error counts as an unknown outcome. `ChatStore` shows the message right away and keeps it until `watchMessages` delivers it. It passes a `clientMessageId` that stays the same across retries: use it as the message id, and return the existing message if you see it twice, or a retry after a lost response posts a duplicate. `deleteMessage` must not throw for an id you don't have, because deleting a "May not have sent" message calls it in case the message did arrive.
4. `leaveConversation` should throw if the user wasn't removed. `ChatStore` keeps the thread, draft, reply and unsent messages until it completes, and counts no answer within 30 seconds as a failure. If `watchConversations` later drops a thread that is open, the store closes it and clears those.
5. Return your repository from `data/default_repository.dart`, in place of the fake. The app creates it and disposes it:

```dart
import 'chat_repository.dart';
import 'supabase_chat_repository.dart';

ChatRepository createDefaultRepository() =>
    SupabaseChatRepository(Supabase.instance.client);
```

6. Delete `data/fake_chat_repository.dart` and `data/seed_data.dart`.

`TeamChatApp(repository: ...)` overrides the default for one app instance, which is useful in tests. A repository passed that way stays yours to dispose, and it doesn't replace step 5.

Failed and sending messages live in `ChatStore`'s outbox, in memory, so they don't survive a restart. A send with no answer after 30 seconds counts as an unknown outcome, and the row clears by itself if `watchMessages` later delivers that id. An edited message is a new message with a new client id, so if the original did arrive and the user accepts the warning, both stay on the server. To try both states with the fake, set `nextSendFault` on `FakeChatRepository`. Reconnect subscribes to the streams again, and nothing retries on its own, so add backoff if you want that. `ChatRepository` loads each thread's full history at once, so add pagination to `watchMessages` for a real service.

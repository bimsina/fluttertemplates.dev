import '../models/chat_user.dart';
import '../models/conversation.dart';
import '../models/message.dart';

const currentUserId = 'me';

const seedUsers = <ChatUser>[
  ChatUser(
    id: currentUserId,
    name: 'Alex Rivera',
    role: 'Product designer',
    presence: Presence.online,
  ),
  ChatUser(
    id: 'maya',
    name: 'Maya Okafor',
    role: 'Engineering lead',
    presence: Presence.online,
  ),
  ChatUser(
    id: 'priya',
    name: 'Priya Nair',
    role: 'Product manager',
    presence: Presence.online,
  ),
  ChatUser(
    id: 'theo',
    name: 'Theo Lindqvist',
    role: 'Mobile engineer',
    presence: Presence.online,
  ),
  ChatUser(
    id: 'jonas',
    name: 'Jonas Weber',
    role: 'Backend engineer',
    presence: Presence.away,
  ),
  ChatUser(
    id: 'sofia',
    name: 'Sofia Alvarez',
    role: 'Brand designer',
    presence: Presence.online,
  ),
  ChatUser(id: 'kenji', name: 'Kenji Mori', role: 'QA engineer'),
  ChatUser(
    id: 'amara',
    name: 'Amara Diallo',
    role: 'Customer support',
    presence: Presence.away,
  ),
  ChatUser(id: 'hana', name: 'Hana Park', role: 'Marketing'),
];

class SeedConversation {
  const SeedConversation(this.conversation, this.messages);

  final Conversation conversation;
  final List<Message> messages;
}

/// Sample conversations, timed relative to [now] so "Today" and "Yesterday"
/// separators are always accurate.
List<SeedConversation> buildSeedConversations(DateTime now) {
  var nextId = 0;

  Message line(
    String conversationId,
    String senderId,
    Duration ago,
    String text, {
    String? replyToId,
    Map<ReactionKind, Set<String>> reactions = const {},
    MessageStatus status = MessageStatus.read,
    bool isSystem = false,
    String? id,
  }) {
    return Message(
      id: id ?? 'seed-${nextId++}',
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      sentAt: now.subtract(ago),
      replyToId: replyToId,
      reactions: reactions,
      status: status,
      isSystem: isSystem,
    );
  }

  SeedConversation thread(
    Conversation conversation,
    List<Message> Function(String id) messages,
  ) {
    final list = messages(conversation.id);
    return SeedConversation(
      conversation.copyWith(lastMessage: () => list.last),
      list,
    );
  }

  Duration days(int days, [int hours = 0]) =>
      Duration(days: days, hours: hours);
  Duration minutes(int minutes) => Duration(minutes: minutes);

  return [
    thread(
      Conversation(
        id: 'launch',
        title: 'Launch crew',
        topic: 'Everything for the 2.4 release',
        isGroup: true,
        isPinned: true,
        unreadCount: 3,
        memberIds: const [currentUserId, 'maya', 'priya', 'theo', 'kenji'],
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      (id) => [
        line(id, 'priya', days(2, 3), 'Release checklist is in the wiki.'),
        line(
          id,
          'priya',
          days(2, 3) - minutes(1),
          'Please add your owners by Thursday.',
        ),
        line(
          id,
          currentUserId,
          days(1, 5),
          'Onboarding screens are final, handing off the specs now.',
          id: 'launch-specs',
          reactions: {
            ReactionKind.celebrate: {'maya', 'priya'},
          },
        ),
        line(
          id,
          'theo',
          days(1, 4),
          'Got them. The empty state on the second screen is a nice touch.',
          replyToId: 'launch-specs',
          reactions: {
            ReactionKind.love: {currentUserId},
          },
        ),
        line(
          id,
          'maya',
          minutes(96),
          'Staging is on the release candidate. Can everyone do a pass '
              'before the end of the day?',
          reactions: {
            ReactionKind.like: {'priya', 'theo', currentUserId},
          },
        ),
        line(id, currentUserId, minutes(88), 'On it after lunch.'),
        line(
          id,
          'kenji',
          minutes(21),
          'Found one blocker: the invite link expires after a single tap on '
              'Android.',
          id: 'launch-blocker',
          reactions: {
            ReactionKind.looking: {'maya'},
          },
        ),
        line(
          id,
          'maya',
          minutes(14),
          'Taking that one. Looks like the token gets consumed on preview.',
          replyToId: 'launch-blocker',
        ),
        line(id, 'theo', minutes(6), 'Fix is up for review, one line change.'),
      ],
    ),
    thread(
      Conversation(
        id: 'dm-maya',
        memberIds: const [currentUserId, 'maya'],
        unreadCount: 1,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      (id) => [
        line(
          id,
          'maya',
          days(6),
          'Do you have time to look at the permissions flow next week?',
        ),
        line(id, currentUserId, days(6) - minutes(12), 'Yes. Tuesday works.'),
        line(
          id,
          currentUserId,
          days(1, 2),
          'Sketches for the permissions flow are ready.',
          reactions: {
            ReactionKind.like: {'maya'},
          },
        ),
        line(id, 'maya', days(1, 1), 'These look right. One note on step 3.'),
        line(
          id,
          'maya',
          minutes(38),
          'Could the role picker stay on the same screen? It saves a step.',
        ),
      ],
    ),
    thread(
      Conversation(
        id: 'crit',
        title: 'Design crit',
        topic: 'Work in progress, feedback welcome',
        isGroup: true,
        unreadCount: 2,
        memberIds: const [currentUserId, 'sofia', 'priya', 'hana'],
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      (id) => [
        line(
          id,
          currentUserId,
          days(3, 1),
          'Moved crit to Thursday mornings so Hana can join.',
          status: MessageStatus.read,
        ),
        line(
          id,
          'hana',
          days(3),
          'Thank you, that helps a lot.',
          reactions: {
            ReactionKind.done: {currentUserId},
          },
        ),
        line(
          id,
          'sofia',
          Duration(hours: 3, minutes: 10),
          'New icon set is ready for review. I redrew the whole navigation '
              'row at 24px.',
        ),
        line(
          id,
          'sofia',
          Duration(hours: 3, minutes: 9),
          'Happy to walk through it tomorrow.',
        ),
      ],
    ),
    thread(
      Conversation(
        id: 'dm-priya',
        memberIds: const [currentUserId, 'priya'],
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      (id) => [
        line(id, 'priya', days(1, 6), 'Roadmap review moved to 3pm tomorrow.'),
        line(
          id,
          currentUserId,
          days(1, 5),
          'Thanks. I will bring the research summary.',
        ),
        line(
          id,
          'priya',
          Duration(hours: 5),
          'Perfect, ten minutes is plenty.',
          reactions: {
            ReactionKind.like: {currentUserId},
          },
        ),
      ],
    ),
    thread(
      Conversation(
        id: 'oncall',
        title: 'Platform on-call',
        topic: 'Alerts and handovers',
        isGroup: true,
        isMuted: true,
        unreadCount: 4,
        memberIds: const [currentUserId, 'jonas', 'maya', 'kenji'],
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      (id) => [
        line(id, 'jonas', days(2), 'Handover notes are in the usual place.'),
        line(
          id,
          'jonas',
          days(1, 8),
          'Queue depth alert fired twice overnight. Both cleared on their own.',
        ),
        line(id, 'kenji', days(1, 7), 'Same pattern as last Tuesday.'),
        line(id, 'jonas', days(1, 7), 'Raising the threshold for now.'),
        line(id, 'maya', days(1, 6), 'Good call. Add a ticket to revisit it.'),
      ],
    ),
    thread(
      Conversation(
        id: 'dm-theo',
        memberIds: const [currentUserId, 'theo'],
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      (id) => [
        line(
          id,
          'theo',
          days(4),
          'Is the tablet layout in scope for this release?',
        ),
        line(id, currentUserId, days(4), 'Two pane only, nothing fancier.'),
        line(id, 'theo', days(4), 'That I can do.'),
      ],
    ),
    thread(
      Conversation(
        id: 'dm-amara',
        memberIds: const [currentUserId, 'amara'],
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      (id) => [
        line(
          id,
          'amara',
          days(9),
          'Support saw a few questions about the new billing page.',
        ),
        line(id, currentUserId, days(9), 'Send them over, I will take a look.'),
      ],
    ),
  ];
}

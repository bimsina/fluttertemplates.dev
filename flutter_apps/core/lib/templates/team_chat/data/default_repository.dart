import 'chat_repository.dart';
import 'fake_chat_repository.dart';

/// The swap point: the only place outside the demo data that names a
/// repository. Return yours here, then delete `fake_chat_repository.dart` and
/// `seed_data.dart`.
ChatRepository createDefaultRepository() => FakeChatRepository();

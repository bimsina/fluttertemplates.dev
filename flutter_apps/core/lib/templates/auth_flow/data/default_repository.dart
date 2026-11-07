import 'auth_repository.dart';
import 'fake_auth_repository.dart';

/// SWAP POINT: the only place outside the demo data that names a repository.
/// Return yours here, then delete `fake_auth_repository.dart`.
AuthRepository createDefaultRepository() => FakeAuthRepository();

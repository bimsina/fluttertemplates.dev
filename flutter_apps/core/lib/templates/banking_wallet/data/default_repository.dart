import 'in_memory_wallet_repository.dart';
import 'wallet_repository.dart';

/// The swap point: the only place outside the demo data that names a
/// repository. Return yours here, then delete
/// `in_memory_wallet_repository.dart` and `seed_data.dart`.
WalletRepository createDefaultRepository() => InMemoryWalletRepository();

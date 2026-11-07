import 'in_memory_pos_repository.dart';
import 'pos_repository.dart';

/// The swap point: the only place outside the demo data that names a
/// repository. Return yours here, then delete `in_memory_pos_repository.dart`
/// and `seed_data.dart`.
PosRepository createDefaultRepository() => InMemoryPosRepository.seeded();

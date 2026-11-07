import 'food_repository.dart';
import 'in_memory_food_repository.dart';

/// The swap point: the only place outside the demo data that names a
/// repository. Return yours here, then delete
/// `in_memory_food_repository.dart` and `fake_data.dart`.
FoodRepository createDefaultRepository() => InMemoryFoodRepository();

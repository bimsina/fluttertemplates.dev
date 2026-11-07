import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The demo data that the backend instructions tell people to delete.
const _demoFiles = {
  'auth_flow': ['fake_auth_repository'],
  'banking_wallet': ['in_memory_wallet_repository', 'seed_data'],
  'food_delivery': ['in_memory_food_repository', 'fake_data'],
  'retail_pos': ['in_memory_pos_repository', 'seed_data'],
  'team_chat': ['fake_chat_repository', 'seed_data'],
};

void main() {
  for (final MapEntry(key: template, value: files) in _demoFiles.entries) {
    test('$template names its demo data only in the swap point', () {
      final root = Directory('lib/templates/$template');
      final offenders = [
        for (final file in root.listSync(recursive: true).whereType<File>())
          if (file.path.endsWith('.dart') &&
              !files.any((name) => file.path.endsWith('data/$name.dart')) &&
              !file.path.endsWith('data/default_repository.dart') &&
              files.any(
                (name) => file.readAsStringSync().contains("$name.dart'"),
              ))
            file.path,
      ];

      expect(offenders, isEmpty);
    });
  }
}

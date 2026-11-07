import 'dart:math';

import 'package:flutter/material.dart';

import '../models/message.dart';

/// Bubbles and the search field sit on this tone. It is mixed from the scheme
/// rather than read from `surfaceContainerHigh`, because schemes that are not
/// built with `fromSeed` leave those roles equal to `surface`.
extension ChatTones on ColorScheme {
  Color get raised =>
      Color.alphaBlend(onSurface.withValues(alpha: 0.07), surface);
  Color get hairline => onSurface.withValues(alpha: 0.1);
}

/// A background and foreground pair for a person, picked by id.
///
/// Hues rotate around the theme's primary container, so the avatars change with
/// the seed color and stay legible in light and dark.
class PersonTone {
  const PersonTone(this.background, this.foreground);

  factory PersonTone.of(String id, ColorScheme scheme) {
    final hash = id.codeUnits.fold<int>(7, (sum, unit) => sum * 31 + unit);
    final step = (hash % 8) * 45.0;
    final background = HSLColor.fromColor(scheme.primaryContainer);
    final foreground = HSLColor.fromColor(scheme.onPrimaryContainer);
    return PersonTone(
      background
          .withHue((background.hue + step) % 360)
          .withSaturation(max(background.saturation, 0.4))
          .toColor(),
      foreground
          .withHue((foreground.hue + step) % 360)
          .withSaturation(max(foreground.saturation, 0.45))
          .toColor(),
    );
  }

  final Color background;
  final Color foreground;
}

IconData reactionIcon(ReactionKind kind) {
  return switch (kind) {
    ReactionKind.like => Icons.thumb_up_rounded,
    ReactionKind.love => Icons.favorite_rounded,
    ReactionKind.celebrate => Icons.celebration_rounded,
    ReactionKind.ship => Icons.rocket_launch_rounded,
    ReactionKind.looking => Icons.visibility_rounded,
    ReactionKind.done => Icons.check_circle_rounded,
  };
}

String reactionLabel(ReactionKind kind) {
  return switch (kind) {
    ReactionKind.like => 'Like',
    ReactionKind.love => 'Love',
    ReactionKind.celebrate => 'Celebrate',
    ReactionKind.ship => 'Ship it',
    ReactionKind.looking => 'Looking',
    ReactionKind.done => 'Done',
  };
}

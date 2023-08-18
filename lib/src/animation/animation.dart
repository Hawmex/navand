import 'dart:html' as html;

import '../widgets/painted_widget.dart';
import 'animation_direction.dart';
import 'animation_fill_mode.dart';
import 'easing.dart';
import 'keyframe.dart';

/// This class can be used to add animations to a [PaintedWidget].
///
/// The properties of this class is almost identical to `animate()`'s parameters
/// in JavaScript. Though, some naming conventions are different.
final class Animation {
  final List<Keyframe> keyframes;
  final Duration duration;
  final Duration startDelay;
  final Duration endDelay;
  final Easing easing;
  final AnimationDirection direction;
  final AnimationFillMode fillMode;
  final double iterations;

  /// Creates a new [Animation].
  const Animation({
    required this.keyframes,
    this.duration = Duration.zero,
    this.startDelay = Duration.zero,
    this.endDelay = Duration.zero,
    this.easing = Easing.linear,
    this.direction = AnimationDirection.normal,
    this.fillMode = AnimationFillMode.none,
    this.iterations = 1,
  });

  /// Runs this animation on the given [element] and returns the
  /// [html.Animation] object.
  html.Animation runOnElement(final html.Element element) {
    return element.animate(
      keyframes.map((final keyframe) => keyframe.toMap()),
      {
        'duration': duration.inMilliseconds,
        'delay': startDelay.inMilliseconds,
        'endDelay': endDelay.inMilliseconds,
        'easing': '$easing',
        'direction': '$direction',
        'fill': '$fillMode',
        'iterations': iterations,
      },
    );
  }
}

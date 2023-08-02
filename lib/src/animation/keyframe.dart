import '../core/style.dart';
import 'easing.dart';

/// Similar to keyframes in CSS and JS animations.
///
/// Each keyframe has an [offset], a [style], and an [easing] property.
final class Keyframe {
  final double offset;
  final Style style;
  final Easing? easing;

  /// Creates a new [Keyframe].
  const Keyframe({required this.offset, required this.style, this.easing});

  /// Returns a [Map] representation of this [Keyframe].
  Map<String, String> toMap() {
    return {
      ...style.toKeyframeMap(),
      'offset': '$offset',
      if (easing != null) 'easing': '$easing'
    };
  }
}

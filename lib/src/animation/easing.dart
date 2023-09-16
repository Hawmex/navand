part of animation;

/// An implementation of the `cubic-bezier` curves.
///
/// Note that [Easing] includes five static properties:
/// - [linear]
/// - [ease]
/// - [easeIn]
/// - [easeOut]
/// - [easeInOut]
final class Easing {
  static const linear = Easing(0, 0, 1, 1);
  static const ease = Easing(0.25, 0.1, 0.25, 1);
  static const easeIn = Easing(0.42, 0, 1, 1);
  static const easeOut = Easing(0, 0, 0.58, 1);
  static const easeInOut = Easing(0.42, 0, 0.58, 1);

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  /// Creates a new [Easing].
  const Easing(this.x1, this.y1, this.x2, this.y2);

  @override
  String toString() => 'cubic-bezier($x1, $y1, $x2, $y2)';
}

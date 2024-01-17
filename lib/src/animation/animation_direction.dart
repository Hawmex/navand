part of '../animation.dart';

/// Similar to `animation-direction` in CSS and JS animations.
enum AnimationDirection {
  normal('normal'),
  reverse('reverse'),
  alternate('alternate'),
  alternateReverse('alternate-reverse');

  final String _value;

  const AnimationDirection(this._value);

  @override
  String toString() => _value;
}

import '../widgets/painted_widget.dart';
import 'string_helpers.dart';

/// Describes how a [PaintedWidget] should look on the screens.
final class Style {
  final Map<String, String> _rules;

  /// Creates a new [Style].
  const Style(this._rules);

  /// Returns a map representation of this [Style] that can be used by
  /// JavaScript's animation API.
  Map<String, String> toKeyframeMap() {
    return _rules.map((final key, final value) {
      return MapEntry(
        key.fromKebabCaseToCamelCase(),
        value,
      );
    });
  }

  /// Concatenates two styles.
  Style operator +(final Style? otherStyle) {
    return Style({
      ..._rules,
      if (otherStyle != null) ...otherStyle._rules,
    });
  }

  /// Concatenates two styles.
  Style addAll(final Style? otherStyle) => this + otherStyle;

  @override
  String toString() {
    if (_rules.isEmpty) return '';

    return _rules.entries
        .map((final ruleEntry) => '${ruleEntry.key}: ${ruleEntry.value}')
        .join('; ')
        .removeExtraWhitespace();
  }
}

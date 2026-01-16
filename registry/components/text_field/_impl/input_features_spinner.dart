part of '../text_field.dart';

/// Adds spinner controls (increment/decrement) to numeric input fields.
///
/// Provides up/down buttons to adjust numeric values in fixed steps.
/// Optionally supports gesture-based adjustments (e.g., drag to change value).
///
/// Example:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   features: [
///     InputSpinnerFeature(
///       step: 5.0,
///       enableGesture: true,
///     ),
///   ],
/// )
/// ```
class InputSpinnerFeature extends InputFeature {
  /// The amount to increment or decrement on each step.
  final double step;

  /// Whether to enable gesture-based value adjustment.
  final bool enableGesture;

  /// Default value when the input is invalid or empty.
  final double? invalidValue;

  /// Creates an [InputSpinnerFeature].
  ///
  /// Parameters:
  /// - [step] (`double`, default: `1.0`): Increment/decrement step size.
  /// - [enableGesture] (`bool`, default: `true`): Enable drag gestures.
  /// - [invalidValue] (`double?`, default: `0.0`): Fallback value for invalid input.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputSpinnerFeature({
    super.visibility,
    super.skipFocusTraversal,
    this.step = 1.0,
    this.enableGesture = true,
    this.invalidValue = 0.0,
  });

  @override
  InputFeatureState createState() => _InputSpinnerFeatureState();
}

class _InputSpinnerFeatureState extends InputFeatureState<InputSpinnerFeature> {
  void _replaceText(UnaryOperator<String> replacer) {
    var controller = this.controller;
    var text = controller.text;
    var newText = replacer(text);
    if (newText != text) {
      controller.text = newText;
      input.onChanged?.call(newText);
    }
  }

  void _increase() {
    _replaceText((text) {
      var value = double.tryParse(text);
      if (value == null) {
        if (feature.invalidValue != null) {
          return _newText(feature.invalidValue!);
        }
        return text;
      }
      return _newText(value + feature.step);
    });
  }

  String _newText(double value) {
    String newText = value.toString();
    if (newText.contains('.')) {
      while (newText.endsWith('0')) {
        newText = newText.substring(0, newText.length - 1);
      }
      if (newText.endsWith('.')) {
        newText = newText.substring(0, newText.length - 1);
      }
    }
    return newText;
  }

  void _decrease() {
    _replaceText((text) {
      var value = double.tryParse(text);
      if (value == null) {
        if (feature.invalidValue != null) {
          return _newText(feature.invalidValue!);
        }
        return text;
      }
      return _newText(value - feature.step);
    });
  }

  Widget _wrapGesture(Widget child) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < 0) {
          _increase();
        } else {
          _decrease();
        }
      },
      child: child,
    );
  }

  Widget _buildButtons() {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton.text(
            icon: Transform.translate(
              offset: Offset(0, -1 * theme.scaling),
              child: Transform.scale(
                alignment: Alignment.center,
                scale: 1.5,
                child: const Icon(LucideIcons.chevronUp),
              ),
            ),
            onPressed: _increase,
            density: ButtonDensity.compact,
            size: ButtonSize.xSmall,
          ),
          IconButton.text(
            icon: Transform.translate(
              offset: Offset(0, 1 * theme.scaling),
              child: Transform.scale(
                alignment: Alignment.center,
                scale: 1.5,
                child: const Icon(LucideIcons.chevronDown),
              ),
            ),
            onPressed: _decrease,
            density: ButtonDensity.compact,
            size: ButtonSize.xSmall,
          ),
        ],
      );
    });
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    if (feature.enableGesture) {
      yield _wrapGesture(_buildButtons());
    } else {
      yield _buildButtons();
    }
  }
}

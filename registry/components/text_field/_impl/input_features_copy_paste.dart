part of '../text_field.dart';

/// Adds a copy button to the input field.
///
/// Provides a button that copies the current input text to the clipboard.
/// Useful for allowing users to easily copy generated or displayed content.
///
/// Example:
/// ```dart
/// TextField(
///   controller: TextEditingController(text: 'Copy me!'),
///   features: [
///     InputCopyFeature(),
///   ],
/// )
/// ```
class InputCopyFeature extends InputFeature {
  /// Position of the copy button.
  final InputFeaturePosition position;

  /// Custom icon for the copy button.
  final Widget? icon;

  /// Creates an [InputCopyFeature].
  ///
  /// Parameters:
  /// - [position] (`InputFeaturePosition`, default: `InputFeaturePosition.trailing`):
  ///   Where to place the copy button.
  /// - [icon] (`Widget?`, optional): Custom icon widget.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputCopyFeature({
    super.visibility,
    super.skipFocusTraversal,
    this.position = InputFeaturePosition.trailing,
    this.icon,
  });

  @override
  InputFeatureState createState() => _InputCopyFeatureState();
}

class _InputCopyFeatureState extends InputFeatureState<InputCopyFeature> {
  void _copy() {
    Actions.invoke(context, const TextFieldSelectAllAndCopyIntent());
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    if (feature.position == InputFeaturePosition.trailing) {
      yield IconButton.text(
        icon: feature.icon ?? const Icon(LucideIcons.copy),
        onPressed: _copy,
        density: ButtonDensity.compact,
      );
    }
  }

  @override
  Iterable<Widget> buildLeading() sync* {
    if (feature.position == InputFeaturePosition.leading) {
      yield IconButton.text(
        icon: feature.icon ?? const Icon(LucideIcons.copy),
        onPressed: _copy,
        density: ButtonDensity.compact,
      );
    }
  }
}

/// Adds a custom widget to the leading (left) side of the input field.
///
/// Allows you to place any widget before the input text, such as icons,
/// labels, or other decorative elements.
///
/// Example:
/// ```dart
/// TextField(
///   features: [
///     InputLeadingFeature(
///       Icon(Icons.search),
///     ),
///   ],
/// )
/// ```
class InputLeadingFeature extends InputFeature {
  /// The widget to display on the leading side.
  final Widget prefix;

  /// Creates an [InputLeadingFeature].
  ///
  /// Parameters:
  /// - [prefix] (`Widget`, required): The widget to show before the input.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputLeadingFeature(
    this.prefix, {
    super.visibility,
    super.skipFocusTraversal,
  });

  @override
  InputFeatureState createState() => _InputLeadingFeatureState();
}

class _InputLeadingFeatureState extends InputFeatureState<InputLeadingFeature> {
  @override
  Iterable<Widget> buildLeading() sync* {
    yield feature.prefix;
  }
}

/// Adds a custom widget to the trailing (right) side of the input field.
///
/// Allows you to place any widget after the input text, such as icons,
/// buttons, or other decorative elements.
///
/// Example:
/// ```dart
/// TextField(
///   features: [
///     InputTrailingFeature(
///       Icon(Icons.arrow_forward),
///     ),
///   ],
/// )
/// ```
class InputTrailingFeature extends InputFeature {
  /// The widget to display on the trailing side.
  final Widget suffix;

  /// Creates an [InputTrailingFeature].
  ///
  /// Parameters:
  /// - [suffix] (`Widget`, required): The widget to show after the input.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputTrailingFeature(
    this.suffix, {
    super.visibility,
    super.skipFocusTraversal,
  });

  @override
  InputFeatureState createState() => _InputTrailingFeatureState();
}

class _InputTrailingFeatureState
    extends InputFeatureState<InputTrailingFeature> {
  @override
  Iterable<Widget> buildTrailing() sync* {
    yield feature.suffix;
  }
}

/// Adds a paste button to the input field.
///
/// Provides a button that pastes content from the clipboard into the input.
/// Useful for improving user experience when entering copied data.
///
/// Example:
/// ```dart
/// TextField(
///   features: [
///     InputPasteFeature(
///       position: InputFeaturePosition.trailing,
///     ),
///   ],
/// )
/// ```
class InputPasteFeature extends InputFeature {
  /// Position of the paste button.
  final InputFeaturePosition position;

  /// Custom icon for the paste button.
  final Widget? icon;

  /// Creates an [InputPasteFeature].
  ///
  /// Parameters:
  /// - [position] (`InputFeaturePosition`, default: `InputFeaturePosition.trailing`):
  ///   Where to place the paste button.
  /// - [icon] (`Widget?`, optional): Custom icon widget.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputPasteFeature({
    super.visibility,
    super.skipFocusTraversal,
    this.position = InputFeaturePosition.trailing,
    this.icon,
  });

  @override
  InputFeatureState createState() => _InputPasteFeatureState();
}

class _InputPasteFeatureState extends InputFeatureState<InputPasteFeature> {
  void _paste() {
    var clipboardData = Clipboard.getData('text/plain');
    clipboardData.then((value) {
      if (value != null) {
        var text = value.text;
        if (text != null && text.isNotEmpty && context.mounted) {
          Actions.invoke(context, TextFieldAppendTextIntent(text: text));
        }
      }
    });
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    if (feature.position == InputFeaturePosition.trailing) {
      yield IconButton.text(
        icon: feature.icon ?? const Icon(LucideIcons.clipboard),
        onPressed: _paste,
        density: ButtonDensity.compact,
      );
    }
  }

  @override
  Iterable<Widget> buildLeading() sync* {
    if (feature.position == InputFeaturePosition.leading) {
      yield IconButton.text(
        icon: feature.icon ?? const Icon(LucideIcons.clipboard),
        onPressed: _paste,
        density: ButtonDensity.compact,
      );
    }
  }
}

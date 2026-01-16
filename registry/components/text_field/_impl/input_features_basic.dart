part of '../text_field.dart';

/// Position where an input feature is displayed.
///
/// Determines whether an input feature (icon, button, widget) appears on
/// the leading (left/start) or trailing (right/end) side of the input.
enum InputFeaturePosition {
  /// Display the feature on the leading side.
  leading,

  /// Display the feature on the trailing side.
  trailing,
}

/// Adds a hint/info button to the input field with a popover.
///
/// Displays an icon button that shows a popover with additional information
/// when clicked. Optionally supports keyboard shortcuts (F1) to open the hint.
///
/// Example:
/// ```dart
/// TextField(
///   features: [
///     InputHintFeature(
///       popupBuilder: (context) => const Text('Enter your email'),
///       icon: Icon(Icons.help),
///     ),
///   ],
/// )
/// ```
class InputHintFeature extends InputFeature {
  /// Builder for the hint popover content.
  final WidgetBuilder popupBuilder;

  /// Custom icon to display (defaults to info icon).
  final Widget? icon;

  /// Position of the hint button.
  final InputFeaturePosition position;

  /// Whether to enable keyboard shortcut (F1) to show the hint.
  final bool enableShortcuts;

  /// Creates an [InputHintFeature].
  ///
  /// Parameters:
  /// - [popupBuilder] (`WidgetBuilder`, required): Builds the hint content.
  /// - [position] (`InputFeaturePosition`, default: `InputFeaturePosition.trailing`):
  ///   Where to place the hint icon.
  /// - [icon] (`Widget?`, optional): Custom icon widget.
  /// - [enableShortcuts] (`bool`, default: `true`): Enable F1 keyboard shortcut.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputHintFeature({
    super.visibility,
    super.skipFocusTraversal,
    required this.popupBuilder,
    this.position = InputFeaturePosition.trailing,
    this.icon,
    this.enableShortcuts = true,
  });

  @override
  InputFeatureState createState() => _InputHintFeatureState();
}

class _InputHintFeatureState extends InputFeatureState<InputHintFeature> {
  final _popoverController = PopoverController();
  void _showPopup(BuildContext context) {
    _popoverController.show(
      context: context,
      builder: feature.popupBuilder,
      alignment: AlignmentDirectional.topCenter,
      anchorAlignment: AlignmentDirectional.bottomCenter,
    );
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    if (feature.position == InputFeaturePosition.trailing) {
      yield Builder(builder: (context) {
        return IconButton.text(
          icon: feature.icon ?? const Icon(LucideIcons.info),
          onPressed: () => _showPopup(context),
          density: ButtonDensity.compact,
        );
      });
    }
  }

  @override
  Iterable<Widget> buildLeading() sync* {
    if (feature.position == InputFeaturePosition.leading) {
      yield IconButton.text(
        icon: feature.icon ?? const Icon(LucideIcons.info),
        onPressed: () => _showPopup(context),
        density: ButtonDensity.compact,
      );
    }
  }

  @override
  Iterable<MapEntry<ShortcutActivator, Intent>> buildShortcuts() sync* {
    if (feature.enableShortcuts) {
      yield const MapEntry(
        SingleActivator(LogicalKeyboardKey.f1),
        InputShowHintIntent(),
      );
    }
  }

  @override
  Iterable<MapEntry<Type, Action<Intent>>> buildActions() sync* {
    if (feature.enableShortcuts) {
      yield MapEntry(
        InputShowHintIntent,
        CallbackContextAction<InputShowHintIntent>(
          onInvoke: (intent, [context]) {
            if (context == null) {
              throw FlutterError(
                'CallbackContextAction was invoked without a valid BuildContext. '
                'This likely indicates a problem in the action system. '
                'Context must not be null when invoking InputShowHintIntent.',
              );
            }
            _showPopup(context);
            return true;
          },
        ),
      );
    }
  }
}

/// Intent to show an input hint popover.
///
/// Used in keyboard shortcut actions to trigger the hint display.
class InputShowHintIntent extends Intent {
  /// Creates an [InputShowHintIntent].
  const InputShowHintIntent();
}

/// Mode for password visibility toggling.
///
/// Determines whether the password visibility toggle holds (shows while pressed)
/// or toggles (switches state on each press).
enum PasswordPeekMode {
  /// Show password only while button is held down.
  hold,

  /// Toggle password visibility on each press.
  toggle,
}

/// Adds a password visibility toggle feature to the input field.
///
/// Provides a button that allows users to toggle between showing and hiding
/// password text. Supports both hold-to-reveal and toggle modes.
///
/// Example:
/// ```dart
/// TextField(
///   obscureText: true,
///   features: [
///     InputPasswordToggleFeature(
///       mode: PasswordPeekMode.toggle,
///     ),
///   ],
/// )
/// ```
class InputPasswordToggleFeature extends InputFeature {
  /// The mode for password peeking behavior.
  final PasswordPeekMode mode;

  /// Position of the toggle button.
  final InputFeaturePosition position;

  /// Icon to display when password is hidden.
  final Widget? icon;

  /// Icon to display when password is shown.
  final Widget? iconShow;

  /// Creates an [InputPasswordToggleFeature].
  ///
  /// Parameters:
  /// - [mode] (`PasswordPeekMode`, default: `PasswordPeekMode.toggle`):
  ///   Toggle or hold behavior.
  /// - [position] (`InputFeaturePosition`, default: `InputFeaturePosition.trailing`):
  ///   Where to place the toggle.
  /// - [icon] (`Widget?`, optional): Custom icon for hidden state.
  /// - [iconShow] (`Widget?`, optional): Custom icon for visible state.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputPasswordToggleFeature({
    super.visibility,
    this.icon,
    this.iconShow,
    this.mode = PasswordPeekMode.toggle,
    this.position = InputFeaturePosition.trailing,
    super.skipFocusTraversal,
  });

  @override
  InputFeatureState createState() => _InputPasswordToggleFeatureState();
}

class _InputPasswordToggleFeatureState
    extends InputFeatureState<InputPasswordToggleFeature> {
  bool? _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      if (_obscureText == null) {
        _obscureText = true;
      } else {
        _obscureText = null;
      }
    });
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    if (feature.position == InputFeaturePosition.trailing) {
      yield _buildIconButton();
    }
  }

  @override
  Iterable<Widget> buildLeading() sync* {
    if (feature.position == InputFeaturePosition.leading) {
      yield _buildIconButton();
    }
  }

  Widget _buildIcon() {
    if (_obscureText == true || input.obscureText) {
      return feature.icon ?? const Icon(LucideIcons.eye);
    }
    return feature.iconShow ?? const Icon(LucideIcons.eyeOff);
  }

  Widget _buildIconButton() {
    if (feature.mode == PasswordPeekMode.hold) {
      return IconButton.text(
        icon: _buildIcon(),
        onTapDown: (_) {
          setState(() {
            _obscureText = null;
          });
        },
        onTapUp: (_) {
          setState(() {
            _obscureText = true;
          });
        },
        enabled: true,
        density: ButtonDensity.compact,
      );
    }
    return IconButton.text(
      icon: _buildIcon(),
      onPressed: _toggleObscureText,
      density: ButtonDensity.compact,
    );
  }

  @override
  TextField interceptInput(TextField input) {
    return input.copyWith(
      obscureText: () => _obscureText ?? false,
    );
  }
}

/// Adds a clear button to the input field.
///
/// Provides a button that clears all text from the input when pressed.
/// Commonly used to improve user experience by offering quick text removal.
///
/// Example:
/// ```dart
/// TextField(
///   features: [
///     InputClearFeature(
///       position: InputFeaturePosition.trailing,
///     ),
///   ],
/// )
/// ```
class InputClearFeature extends InputFeature {
  /// Position of the clear button.
  final InputFeaturePosition position;

  /// Custom icon for the clear button.
  final Widget? icon;

  /// Creates an [InputClearFeature].
  ///
  /// Parameters:
  /// - [position] (`InputFeaturePosition`, default: `InputFeaturePosition.trailing`):
  ///   Where to place the clear button.
  /// - [icon] (`Widget?`, optional): Custom icon widget.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputClearFeature({
    super.visibility,
    super.skipFocusTraversal,
    this.position = InputFeaturePosition.trailing,
    this.icon,
  });

  @override
  InputFeatureState createState() => _InputClearFeatureState();
}

class _InputClearFeatureState extends InputFeatureState<InputClearFeature> {
  void _clear() {
    controller.text = '';
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    if (feature.position == InputFeaturePosition.trailing) {
      yield IconButton.text(
        icon: feature.icon ?? const Icon(LucideIcons.x),
        onPressed: _clear,
        density: ButtonDensity.compact,
      );
    }
  }

  @override
  Iterable<Widget> buildLeading() sync* {
    if (feature.position == InputFeaturePosition.leading) {
      yield IconButton.text(
        icon: feature.icon ?? const Icon(LucideIcons.x),
        onPressed: _clear,
        density: ButtonDensity.compact,
      );
    }
  }
}

/// Adds a revalidate button to the input field.
///
/// Provides a button that triggers form validation when pressed.
/// Useful for manually triggering validation after user input.
///
/// Example:
/// ```dart
/// TextField(
///   features: [
///     InputRevalidateFeature(),
///   ],
/// )
/// ```
class InputRevalidateFeature extends InputFeature {
  /// Position of the revalidate button.
  final InputFeaturePosition position;

  /// Custom icon for the revalidate button.
  final Widget? icon;

  /// Creates an [InputRevalidateFeature].
  ///
  /// Parameters:
  /// - [position] (`InputFeaturePosition`, default: `InputFeaturePosition.trailing`):
  ///   Where to place the revalidate button.
  /// - [icon] (`Widget?`, optional): Custom icon widget.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputRevalidateFeature({
    super.visibility,
    super.skipFocusTraversal,
    this.position = InputFeaturePosition.trailing,
    this.icon,
  });

  @override
  InputFeatureState createState() => _InputRevalidateFeatureState();
}

class _InputRevalidateFeatureState
    extends InputFeatureState<InputRevalidateFeature> {
  void _revalidate() {
    var formFieldHandle = Data.maybeFind<FormFieldHandle>(context);
    if (formFieldHandle != null) {
      formFieldHandle.revalidate();
    }
  }

  Widget _buildIcon() {
    return FormPendingBuilder(
      builder: (context, futures, _) {
        if (futures.isEmpty) {
          return IconButton.text(
            icon: feature.icon ?? const Icon(LucideIcons.refreshCw),
            onPressed: _revalidate,
            density: ButtonDensity.compact,
          );
        }

        var futureAll = Future.wait(futures.values);
        return FutureBuilder(
          future: futureAll,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return IconButton.text(
                icon: RepeatedAnimationBuilder(
                  start: 0.0,
                  end: 360.0,
                  duration: const Duration(seconds: 1),
                  child: feature.icon ?? const Icon(LucideIcons.refreshCw),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: degToRad(value),
                      child: child,
                    );
                  },
                ),
                onPressed: null,
                density: ButtonDensity.compact,
              );
            }
            return IconButton.text(
              icon: feature.icon ?? const Icon(LucideIcons.refreshCw),
              onPressed: _revalidate,
              density: ButtonDensity.compact,
            );
          },
        );
      },
    );
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    if (feature.position == InputFeaturePosition.trailing) {
      yield _buildIcon();
    }
  }

  @override
  Iterable<Widget> buildLeading() sync* {
    if (feature.position == InputFeaturePosition.leading) {
      yield _buildIcon();
    }
  }
}

part of '../text_field.dart';

/// A callback that provides suggestions based on a query string.
///
/// Parameters:
/// - [query] (`String`): The current input text to generate suggestions for.
///
/// Returns: `FutureOr<Iterable<String>>` — The list of suggestion strings.
typedef SuggestionBuilder = FutureOr<Iterable<String>> Function(String query);

/// Adds autocomplete functionality to the input field.
///
/// Displays a popover with suggestions as the user types. Suggestions are
/// provided by the [querySuggestions] callback and can be selected to fill
/// the input.
///
/// Example:
/// ```dart
/// TextField(
///   features: [
///     InputAutoCompleteFeature(
///       querySuggestions: (query) async {
///         return ['apple', 'apricot', 'avocado']
///             .where((s) => s.startsWith(query));
///       },
///       child: const Text('Fruits'),
///     ),
///   ],
/// )
/// ```
class InputAutoCompleteFeature extends InputFeature {
  /// Callback to provide suggestions for a given query.
  final SuggestionBuilder querySuggestions;

  /// Child widget displayed in the suggestion list.
  final Widget child;

  /// Constraints for the popover size.
  final BoxConstraints? popoverConstraints;

  /// Width constraint for the popover.
  final PopoverConstraint? popoverWidthConstraint;

  /// Anchor alignment for the popover.
  final AlignmentDirectional? popoverAnchorAlignment;

  /// Popover alignment relative to the anchor.
  final AlignmentDirectional? popoverAlignment;

  /// Autocomplete mode (e.g., popover or inline).
  final AutoCompleteMode mode;

  /// Creates an [InputAutoCompleteFeature].
  ///
  /// Parameters:
  /// - [querySuggestions] (`SuggestionBuilder`, required): Provides suggestions.
  /// - [child] (`Widget`, required): Content for suggestion items.
  /// - [popoverConstraints] (`BoxConstraints?`, optional): Size constraints.
  /// - [popoverWidthConstraint] (`PopoverConstraint?`, optional): Width constraint.
  /// - [popoverAnchorAlignment] (`AlignmentDirectional?`, optional): Anchor alignment.
  /// - [popoverAlignment] (`AlignmentDirectional?`, optional): Popover alignment.
  /// - [mode] (`AutoCompleteMode`, required): Autocomplete display mode.
  /// - [visibility] (`InputFeatureVisibility`, optional): Controls visibility.
  /// - [skipFocusTraversal] (`bool`, optional): Whether to skip in focus order.
  const InputAutoCompleteFeature({
    super.visibility,
    super.skipFocusTraversal,
    required this.querySuggestions,
    required this.child,
    this.popoverConstraints,
    this.popoverWidthConstraint,
    this.popoverAnchorAlignment,
    this.popoverAlignment,
    this.mode = AutoCompleteMode.replaceWord,
  });

  @override
  InputFeatureState createState() => _AutoCompleteFeatureState();
}

class _AutoCompleteFeatureState
    extends InputFeatureState<InputAutoCompleteFeature> {
  final GlobalKey _key = GlobalKey();
  final ValueNotifier<FutureOr<Iterable<String>>?> _suggestions =
      ValueNotifier(null);

  @override
  void onTextChanged(String text) {
    _suggestions.value = feature.querySuggestions(text);
  }

  @override
  Widget wrap(Widget child) {
    return ListenableBuilder(
      listenable: _suggestions,
      builder: (context, child) {
        var suggestions = _suggestions.value;
        if (suggestions is Future<Iterable<String>>) {
          return FutureBuilder(
            future: suggestions,
            builder: (context, snapshot) {
              return AutoComplete(
                key: _key,
                suggestions:
                    snapshot.hasData ? snapshot.requireData.toList() : const [],
                popoverConstraints: feature.popoverConstraints,
                popoverWidthConstraint: feature.popoverWidthConstraint,
                popoverAnchorAlignment: feature.popoverAnchorAlignment,
                popoverAlignment: feature.popoverAlignment,
                mode: feature.mode,
                child: child!,
              );
            },
          );
        }
        return AutoComplete(
          key: _key,
          suggestions: suggestions == null ? const [] : suggestions.toList(),
          popoverConstraints: feature.popoverConstraints,
          popoverWidthConstraint: feature.popoverWidthConstraint,
          popoverAnchorAlignment: feature.popoverAnchorAlignment,
          popoverAlignment: feature.popoverAlignment,
          mode: feature.mode,
          child: child!,
        );
      },
      child: child,
    );
  }
}

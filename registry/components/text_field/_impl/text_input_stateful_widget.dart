part of '../text_field.dart';

abstract class TextInputStatefulWidget extends StatefulWidget with TextInput {
  @override
  final Object groupId;
  @override
  final TextEditingController? controller;
  @override
  final FocusNode? focusNode;
  @override
  final BoxDecoration? decoration;
  @override
  final EdgeInsetsGeometry? padding;
  @override
  final Widget? placeholder;
  @override
  final CrossAxisAlignment crossAxisAlignment;
  @override
  final String? clearButtonSemanticLabel;
  @override
  final TextInputType? keyboardType;
  @override
  final TextInputAction? textInputAction;
  @override
  final TextCapitalization textCapitalization;
  @override
  final TextStyle? style;
  @override
  final StrutStyle? strutStyle;
  @override
  final TextAlign textAlign;
  @override
  final TextAlignVertical? textAlignVertical;
  @override
  final TextDirection? textDirection;
  @override
  final bool readOnly;
  @override
  final bool? showCursor;
  @override
  final bool autofocus;
  @override
  final String obscuringCharacter;
  @override
  final bool obscureText;
  @override
  final bool autocorrect;
  @override
  final SmartDashesType smartDashesType;
  @override
  final SmartQuotesType smartQuotesType;
  @override
  final bool enableSuggestions;
  @override
  final int? maxLines;
  @override
  final int? minLines;
  @override
  final bool expands;
  @override
  final int? maxLength;
  @override
  final MaxLengthEnforcement? maxLengthEnforcement;
  @override
  final ValueChanged<String>? onChanged;
  @override
  final VoidCallback? onEditingComplete;
  @override
  final ValueChanged<String>? onSubmitted;
  @override
  final TapRegionCallback? onTapOutside;
  @override
  final TapRegionCallback? onTapUpOutside;
  @override
  final List<TextInputFormatter>? inputFormatters;
  @override
  final bool enabled;
  @override
  final double cursorWidth;
  @override
  final double? cursorHeight;
  @override
  final Radius cursorRadius;
  @override
  final bool cursorOpacityAnimates;
  @override
  final Color? cursorColor;
  @override
  final ui.BoxHeightStyle selectionHeightStyle;
  @override
  final ui.BoxWidthStyle selectionWidthStyle;
  @override
  final Brightness? keyboardAppearance;
  @override
  final EdgeInsets scrollPadding;
  @override
  final bool enableInteractiveSelection;
  @override
  final TextSelectionControls? selectionControls;
  @override
  final DragStartBehavior dragStartBehavior;
  @override
  final ScrollController? scrollController;
  @override
  final ScrollPhysics? scrollPhysics;
  @override
  final GestureTapCallback? onTap;
  @override
  final Iterable<String>? autofillHints;
  @override
  final Clip clipBehavior;
  @override
  final String? restorationId;
  @override
  final bool stylusHandwritingEnabled;
  @override
  final bool enableIMEPersonalizedLearning;
  @override
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  @override
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  @override
  final String? initialValue;
  @override
  final String? hintText;
  @override
  final Border? border;
  @override
  final BorderRadiusGeometry? borderRadius;
  @override
  final bool? filled;
  @override
  final WidgetStatesController? statesController;
  @override
  final TextMagnifierConfiguration? magnifierConfiguration;
  @override
  final SpellCheckConfiguration? spellCheckConfiguration;
  @override
  final UndoHistoryController? undoController;
  @override
  final List<InputFeature> features;
  @override
  final List<TextInputFormatter>? submitFormatters;
  @override
  final bool skipInputFeatureFocusTraversal;

  /// Creates a stateful text input widget with comprehensive configuration options.
  ///
  /// This constructor accepts all properties defined in the [TextInput] mixin,
  /// providing extensive control over text input behavior, appearance, and interactions.
  ///
  /// Most parameters mirror Flutter's [EditableText] widget while adding custom
  /// features like input features, decorations, and form integration.
  ///
  /// Key parameters include:
  /// - [controller]: Text editing controller, created automatically if null
  /// - [focusNode]: Focus node for keyboard interaction
  /// - [decoration]: Box decoration for the input container
  /// - [padding]: Inner padding around the text field
  /// - [placeholder]: Widget shown when field is empty
  /// - [enabled]: Whether input accepts user interaction, defaults to true
  /// - [readOnly]: Whether text can be edited, defaults to false
  /// - [obscureText]: Whether to hide input (for passwords), defaults to false
  /// - [maxLines]: Maximum number of lines, defaults to 1
  /// - [features]: List of input features (e.g., clear button, character count)
  ///
  /// See [TextInput] mixin documentation for full parameter details.
  const TextInputStatefulWidget({
    super.key,
    this.groupId = EditableText,
    this.controller,
    this.focusNode,
    this.decoration,
    this.padding,
    this.placeholder,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.clearButtonSemanticLabel,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType = SmartDashesType.enabled,
    this.smartQuotesType = SmartQuotesType.enabled,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTapOutside,
    this.onTapUpOutside,
    this.inputFormatters,
    this.enabled = true,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius = const Radius.circular(2.0),
    this.cursorOpacityAnimates = true,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrollController,
    this.scrollPhysics,
    this.onTap,
    this.autofillHints = const [],
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.stylusHandwritingEnabled =
        EditableText.defaultStylusHandwritingEnabled,
    this.enableIMEPersonalizedLearning = true,
    this.contentInsertionConfiguration,
    this.contextMenuBuilder,
    this.initialValue,
    this.hintText,
    this.border,
    this.borderRadius,
    this.filled,
    this.statesController,
    this.magnifierConfiguration,
    this.spellCheckConfiguration,
    this.undoController,
    this.features = const [],
    this.submitFormatters = const [],
    this.skipInputFeatureFocusTraversal = false,
  });

  /// Creates a copy of this text field with the given properties replaced.
  ///

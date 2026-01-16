part of '../text_field.dart';

class _TextFieldSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _TextFieldSelectionGestureDetectorBuilder({required TextFieldState state})
      : _state = state,
        super(delegate: state);

  final TextFieldState _state;

  @override
  void onSingleTapUp(TapDragUpDetails details) {
    // Because TextSelectionGestureDetector listens to taps that happen on
    // widgets in front of it, tapping the clear button will also trigger
    // this handler. If the clear button widget recognizes the up event,
    // then do not handle it.
    if (_state._clearGlobalKey.currentContext != null) {
      final RenderBox renderBox = _state._clearGlobalKey.currentContext!
          .findRenderObject()! as RenderBox;
      final Offset localOffset =
          renderBox.globalToLocal(details.globalPosition);
      if (renderBox.hitTest(BoxHitTestResult(), position: localOffset)) {
        return;
      }
    }
    super.onSingleTapUp(details);
    _state.widget.onTap?.call();
  }

  @override
  void onDragSelectionEnd(TapDragEndDetails details) {
    _state._requestKeyboard();
    super.onDragSelectionEnd(details);
  }
}

/// Mixin defining the interface for text input widgets.
///
/// Provides a comprehensive set of properties that text input widgets
/// must implement, ensuring consistency across [TextField], [ChipInput],
/// [TextArea], and similar components. This mixin helps avoid missing
/// properties when implementing custom text input widgets.
///
/// Properties are organized into categories:
/// - Basic configuration: groupId, controller, focusNode
/// - Visual styling: decoration, padding, placeholder, border, borderRadius
/// - Text configuration: style, strutStyle, textAlign, textDirection
/// - Input behavior: keyboardType, textInputAction, autocorrect, enableSuggestions
/// - Cursor styling: cursorWidth, cursorHeight, cursorRadius, cursorColor
/// - Selection: enableInteractiveSelection, selectionControls, selectionHeightStyle
/// - Callbacks: onChanged, onSubmitted, onEditingComplete, onTap
/// - Features: features, inputFormatters, submitFormatters

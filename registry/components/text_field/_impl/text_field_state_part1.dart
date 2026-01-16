part of '../text_field.dart';

class TextFieldState extends State<TextField>
    with
        RestorationMixin,
        AutomaticKeepAliveClientMixin<TextField>,
        FormValueSupplier<String, TextField>,
        TickerProviderStateMixin
    implements TextSelectionGestureDetectorBuilderDelegate, AutofillClient {
  final ValueNotifier<String> _effectiveText = ValueNotifier('');
  final ValueNotifier<TextSelection> _effectiveSelection =
      ValueNotifier(const TextSelection.collapsed(offset: -1));
  final GlobalKey _clearGlobalKey = GlobalKey();

  final List<_AttachedInputFeature> _attachedFeatures = [];

  late WidgetStatesController _statesController;

  RestorableTextEditingController? _controller;

  /// The effective text editing controller for this text field.
  ///
  /// Returns the widget's controller or the internally created controller.
  TextEditingController get effectiveController =>
      widget.controller ?? _controller!.value;

  FocusNode? _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  MaxLengthEnforcement get _effectiveMaxLengthEnforcement =>
      widget.maxLengthEnforcement ??
      LengthLimitingTextInputFormatter.getDefaultMaxLengthEnforcement();

  bool _showSelectionHandles = false;

  late _TextFieldSelectionGestureDetectorBuilder
      _selectionGestureDetectorBuilder;

  void _setStateFeature(VoidCallback fn) {
    setState(fn);
  }

  // API for TextSelectionGestureDetectorBuilderDelegate.
  @override
  bool get forcePressEnabled => true;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled =>
      widget.enableInteractiveSelection && widget.enabled;
  // End of API for TextSelectionGestureDetectorBuilderDelegate.

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder =
        _TextFieldSelectionGestureDetectorBuilder(
      state: this,
    );
    if (widget.controller == null) {
      _createLocalController(widget.initialValue != null
          ? TextEditingValue(text: widget.initialValue!)
          : null);
    } else {
      widget.controller!.addListener(_handleControllerChanged);
    }
    _effectiveFocusNode.canRequestFocus = widget.enabled;
    _effectiveFocusNode.addListener(_handleFocusChanged);
    _statesController = widget.statesController ?? WidgetStatesController();
    String effectiveText = widget.controller?.text ?? widget.initialValue ?? '';
    formValue = effectiveText.isEmpty ? null : effectiveText;
    for (final feature in widget.features) {
      final state = feature.createState();
      state._attached = _AttachedInputFeature(feature, state);
      state._inputState = this;
      state.initState();
      _attachedFeatures.add(state._attached!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final attached in _attachedFeatures) {
      attached.state.didChangeDependencies();
    }
  }

  @override
  void didUpdateWidget(TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
      if (widget.controller != null) {
        _handleControllerChanged();
      }
    }

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _focusNode)?.removeListener(_handleFocusChanged);
      (widget.focusNode ?? _focusNode)?.addListener(_handleFocusChanged);
    }
    _effectiveFocusNode.canRequestFocus = widget.enabled;

    for (var i = 0;
        i < max(oldWidget.features.length, widget.features.length);
        i++) {
      if (i >= oldWidget.features.length) {
        final newFeature = widget.features[i];
        final newState = newFeature.createState();
        newState._attached = _AttachedInputFeature(newFeature, newState);
        newState._inputState = this;
        newState.initState();
        newState.didChangeDependencies();
        _attachedFeatures.add(newState._attached!);
        continue;
      }
      if (i >= widget.features.length) {
        final oldState = _attachedFeatures[i].state;
        oldState.dispose();
        _attachedFeatures.removeAt(i);
        continue;
      }
      final oldFeature = oldWidget.features[i];
      final newFeature = widget.features[i];
      final oldState = _attachedFeatures[i].state;
      if (!InputFeature.canUpdate(oldFeature, newFeature)) {
        oldState.dispose();
        final newState = newFeature.createState();
        newState._attached = _AttachedInputFeature(newFeature, newState);
        newState._inputState = this;
        newState.initState();
        newState.didChangeDependencies();
        _attachedFeatures[i] = newState._attached!;
      } else {
        oldState._attached!.feature = newFeature;
        oldState.didFeatureUpdate(oldFeature);
      }
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
    _controller!.value.addListener(updateKeepAlive);
    _controller!.value.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    _effectiveText.value = effectiveController.text;
    _effectiveSelection.value = effectiveController.selection;
    formValue =
        effectiveController.text.isEmpty ? null : effectiveController.text;
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (value != null) {
      _effectiveText.value = value.text;
      _effectiveSelection.value = value.selection;
    }
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void dispose() {
    for (final attached in _attachedFeatures) {
      attached.state.dispose();
    }
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  EditableTextState get _editableText => editableTextKey.currentState!;

  void _requestKeyboard() {
    _editableText.requestKeyboard();
  }

  void _handleFocusChanged() {
    setState(() {
      // Rebuild the widget on focus change to show/hide the text selection
      // highlight.
    });
    _statesController.update(WidgetState.focused, _effectiveFocusNode.hasFocus);
    if (!_effectiveFocusNode.hasFocus) {
      _formatSubmit();
    }
  }

  void _formatSubmit() {
    if (widget.submitFormatters != null) {
      TextEditingValue value = effectiveController.value;
      for (var formatter in widget.submitFormatters!) {
        value = formatter.formatEditUpdate(value, value);
      }
      if (value != effectiveController.value) {
        effectiveController.value = value;
        widget.onChanged?.call(value.text);
      }
    }
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    // When the text field is activated by something that doesn't trigger the
    // selection overlay, we shouldn't show the handles either.
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar) {
      return false;
    }

    // On iOS, we don't show handles when the selection is collapsed.
    if (effectiveController.selection.isCollapsed) {
      return false;
    }

    if (cause == SelectionChangedCause.keyboard) {
      return false;
    }

    if (cause == SelectionChangedCause.stylusHandwriting) {
      return true;
    }

    if (effectiveController.text.isNotEmpty) {
      return true;
    }

    return false;
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    _effectiveSelection.value = selection;
    final bool willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    if (willShowSelectionHandles != _showSelectionHandles) {
      setState(() {
        _showSelectionHandles = willShowSelectionHandles;
      });
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        if (cause == SelectionChangedCause.longPress) {
          _editableText.bringIntoView(selection.extent);
        }
      // ignore: unreachable_switch_default
      default:
        // using the normal flutter sdk, this is unreachable.
        // but for other forks like flutter for ohos, we keep it
        // so that they can add their own platform specific behavior.
        if (cause == SelectionChangedCause.longPress) {
          _editableText.bringIntoView(selection.extent);
        }
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        break;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        if (cause == SelectionChangedCause.drag) {
          _editableText.hideToolbar();
        }
      // ignore: unreachable_switch_default
      default:
        if (cause == SelectionChangedCause.drag) {
          _editableText.hideToolbar();
        }
    }

    for (final attached in _attachedFeatures) {
      attached.state.onSelectionChanged(selection);
    }
  }

  @override
  bool get wantKeepAlive => _controller?.value.text.isNotEmpty ?? false;

  // True if any surrounding decoration widgets will be shown.
  bool get _hasDecoration {
    return widget.placeholder != null || widget.features.isNotEmpty;
  }

  // Provide default behavior if widget.textAlignVertical is not set.
  // CupertinoTextField has top alignment by default, unless it has decoration
  // like a prefix or suffix, in which case it's aligned to the center.
  TextAlignVertical get _textAlignVertical {
    if (widget.textAlignVertical != null) {
      return widget.textAlignVertical!;
    }
    return _hasDecoration ? TextAlignVertical.center : TextAlignVertical.top;
  }

  @override
  TextField get widget {
    TextField widget = super.widget;
    for (final attached in _attachedFeatures) {
      widget = attached.state.interceptInput(widget);
    }
    return widget;
  }

  Widget _addTextDependentAttachments(
    Widget editableText,
    TextStyle textStyle,
    ThemeData theme,
  ) {
    var widget = this.widget;
    // If there are no surrounding widgets, just return the core editable text
    // part.
    if (!_hasDecoration) {
      return editableText;
    }

    // Otherwise, listen to the current state of the text entry.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: effectiveController,
      child: editableText,
      builder: (BuildContext context, TextEditingValue text, Widget? child) {
        final bool hasText = text.text.isNotEmpty;
        final Widget? placeholder = widget.placeholder == null
            ? null
            // Make the placeholder invisible when hasText is true.
            : Visibility(
                maintainAnimation: true,
                maintainSize: true,
                maintainState: true,
                visible: !hasText,
                child: SizedBox(
                  width: double.infinity,
                  child: DefaultTextStyle(
                    style: textStyle
                        .merge(theme.typography.small)
                        .merge(theme.typography.normal)
                        .copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                    textAlign: widget.textAlign,
                    maxLines: widget.maxLines,
                    child: widget.placeholder!,
                  ),
                ),
              );

        List<Widget> leadingChildren = [];
        List<Widget> trailingChildren = [];
        for (final attached in _attachedFeatures) {
          leadingChildren.addAll(attached.state._internalBuildLeading().map(
                (e) => Focus(
                  skipTraversal: widget.skipInputFeatureFocusTraversal ||
                      attached.feature.skipFocusTraversal,
                  child: e,
                ),
              ));
          trailingChildren.addAll(attached.state._internalBuildTrailing().map(
                (e) => FocusScope(
                  skipTraversal: widget.skipInputFeatureFocusTraversal ||
                      attached.feature.skipFocusTraversal,
                  child: e,
                ),
              ));
        }

        Widget leadingWidget = Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4 * theme.scaling,
          children: leadingChildren,
        );

        Widget trailingWidget = Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4 * theme.scaling,
          children: trailingChildren,
        );

        return Row(
          crossAxisAlignment: widget.crossAxisAlignment,
          spacing: 8.0 * theme.scaling,
          children: [
            // Insert a prefix at the front if the prefix visibility mode matches
            // the current text state.
            if (leadingChildren.isNotEmpty) leadingWidget,
            // In the middle part, stack the placeholder on top of the main EditableText
            // if needed.
            Expanded(
              child: Stack(
                // Ideally this should be baseline aligned. However that comes at
                // the cost of the ability to compute the intrinsic dimensions of
                // this widget.
                // See also https://github.com/flutter/flutter/issues/13715.
                alignment: AlignmentDirectional.center,
                textDirection: widget.textDirection,
                children: <Widget>[
                  if (placeholder != null) placeholder,
                  editableText
                ],
              ),
            ),
            if (trailingChildren.isNotEmpty) trailingWidget,
          ],
        );
      },
    );
  }

  // AutofillClient implementation start.
  @override
  String get autofillId => _editableText.autofillId;

  @override
  void autofill(TextEditingValue newEditingValue) =>
      _editableText.autofill(newEditingValue);

  @override
  TextInputConfiguration get textInputConfiguration {
    var widget = this.widget;
    final List<String>? autofillHints =
        widget.autofillHints?.toList(growable: false);
    final AutofillConfiguration autofillConfiguration = autofillHints != null
        ? AutofillConfiguration(
            uniqueIdentifier: autofillId,
            autofillHints: autofillHints,
            currentEditingValue: effectiveController.value,
            hintText: widget.hintText,
          )
        : AutofillConfiguration.disabled;

    return _editableText.textInputConfiguration.copyWith(
      autofillConfiguration: autofillConfiguration,
    );
  }
  // AutofillClient implementation end.

  void _onChanged(String value) {
    var widget = this.widget;

part of '../text_field.dart';

    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
    formValue = value.isEmpty ? null : value;
    _effectiveText.value = value;

    for (final attached in _attachedFeatures) {
      attached.state.onTextChanged(value);
    }
  }

  void _onEnter(PointerEnterEvent event) {
    _statesController.update(WidgetState.hovered, true);
  }

  void _onExit(PointerExitEvent event) {
    _statesController.update(WidgetState.hovered, false);
  }

  Widget _wrapActions({required Widget child}) {
    Map<Type, Action<Intent>> featureActions = {};
    Map<ShortcutActivator, Intent> featureShortcuts = {};
    for (final attached in _attachedFeatures) {
      for (final action in attached.state.buildActions()) {
        featureActions[action.key] = action.value;
      }
      for (final shortcut in attached.state.buildShortcuts()) {
        featureShortcuts[shortcut.key] = shortcut.value;
      }
    }
    return Actions(
        actions: {
          TextFieldClearIntent: Action.overridable(
            context: context,
            defaultAction: CallbackAction<TextFieldClearIntent>(
              onInvoke: (intent) {
                effectiveController.clear();
                return;
              },
            ),
          ),
          TextFieldAppendTextIntent: Action.overridable(
            context: context,
            defaultAction: CallbackAction<TextFieldAppendTextIntent>(
              onInvoke: (intent) {
                _appendText(intent.text);
                return;
              },
            ),
          ),
          TextFieldReplaceCurrentWordIntent: Action.overridable(
            context: context,
            defaultAction: CallbackAction<TextFieldReplaceCurrentWordIntent>(
              onInvoke: (intent) {
                _replaceCurrentWord(intent.text);
                return;
              },
            ),
          ),
          TextFieldSetTextIntent: Action.overridable(
            context: context,
            defaultAction: CallbackAction<TextFieldSetTextIntent>(
              onInvoke: (intent) {
                _setText(intent.text);
                return;
              },
            ),
          ),
          TextFieldSetSelectionIntent: Action.overridable(
            context: context,
            defaultAction: CallbackAction<TextFieldSetSelectionIntent>(
              onInvoke: (intent) {
                effectiveController.selection = intent.selection;
                return;
              },
            ),
          ),
          TextFieldSelectAllAndCopyIntent: Action.overridable(
            context: context,
            defaultAction: CallbackAction<TextFieldSelectAllAndCopyIntent>(
              onInvoke: (intent) {
                effectiveController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: effectiveController.text.length,
                );
                var text = effectiveController.text;
                if (text.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: text));
                }
                return;
              },
            ),
          ),
          AutoCompleteIntent: Action.overridable(
            context: context,
            defaultAction: CallbackAction<AutoCompleteIntent>(
              onInvoke: (intent) {
                switch (intent.mode) {
                  case AutoCompleteMode.append:
                    _appendText(intent.suggestion);
                    break;
                  case AutoCompleteMode.replaceWord:
                    _replaceCurrentWord(intent.suggestion);
                    break;
                  case AutoCompleteMode.replaceAll:
                    _setText(intent.suggestion);
                    break;
                }
                return;
              },
            ),
          ),
          ...featureActions,
        },
        child: Shortcuts(
          shortcuts: featureShortcuts,
          child: child,
        ));
  }

  void _appendText(String text) {
    final newText = effectiveController.text + text;
    effectiveController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  void _replaceCurrentWord(String text) {
    final replacement = text;
    final value = effectiveController.value;
    final selection = value.selection;
    if (selection.isCollapsed) {
      int start = selection.start;
      final newText =
          replaceWordAtCaret(value.text, start, replacement, (char) {
        return char == ' ' ||
            char == '\n' ||
            char == '\t' ||
            ChipInput.isChipCharacter(char);
      });
      effectiveController.value = TextEditingValue(
        text: newText.$2,
        selection: TextSelection.collapsed(
          offset: newText.$1 + replacement.length,
        ),
      );
    }
  }

  void _setText(String text) {
    effectiveController.value = TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }

  @override
  Widget build(BuildContext context) {
    var widget = this.widget;
    super.build(context); // See AutomaticKeepAliveClientMixin.
    final ThemeData theme = Theme.of(context);
    final compTheme = ComponentTheme.maybeOf<TextFieldTheme>(context);
    assert(debugCheckHasDirectionality(context));
    final TextEditingController controller = effectiveController;

    TextSelectionControls? textSelectionControls = widget.selectionControls;
    VoidCallback? handleDidGainAccessibilityFocus;
    VoidCallback? handleDidLoseAccessibilityFocus;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        textSelectionControls ??= cupertinoDesktopTextSelectionHandleControls;
        handleDidGainAccessibilityFocus = () {
          // Automatically activate the TextField when it receives accessibility focus.
          if (!_effectiveFocusNode.hasFocus &&
              _effectiveFocusNode.canRequestFocus) {
            _effectiveFocusNode.requestFocus();
          }
        };
        handleDidLoseAccessibilityFocus = () {
          _effectiveFocusNode.unfocus();
        };
      // ignore: unreachable_switch_default
      default:
        textSelectionControls ??= cupertinoDesktopTextSelectionHandleControls;
        handleDidGainAccessibilityFocus = () {
          // Automatically activate the TextField when it receives accessibility focus.
          if (!_effectiveFocusNode.hasFocus &&
              _effectiveFocusNode.canRequestFocus) {
            _effectiveFocusNode.requestFocus();
          }
        };
        handleDidLoseAccessibilityFocus = () {
          _effectiveFocusNode.unfocus();
        };
    }

    final bool enabled = widget.enabled;
    final List<TextInputFormatter> formatters = <TextInputFormatter>[
      ...?widget.inputFormatters,
      if (widget.maxLength != null)
        LengthLimitingTextInputFormatter(
          widget.maxLength,
          maxLengthEnforcement: _effectiveMaxLengthEnforcement,
        ),
    ];

    TextStyle defaultTextStyle;
    if (widget.style != null) {
      defaultTextStyle = DefaultTextStyle.of(context)
          .style
          .merge(theme.typography.small)
          .merge(theme.typography.normal)
          .copyWith(
            color: theme.colorScheme.foreground,
          )
          .merge(widget.style);
    } else {
      defaultTextStyle = DefaultTextStyle.of(context)
          .style
          .merge(theme.typography.small)
          .merge(theme.typography.normal)
          .copyWith(
            color: theme.colorScheme.foreground,
          );
    }

    final Brightness keyboardAppearance =
        widget.keyboardAppearance ?? theme.brightness;
    final Color cursorColor = widget.cursorColor ??
        DefaultSelectionStyle.of(context).cursorColor ??
        theme.colorScheme.primary;

    // Use the default disabled color only if the box decoration was not set.
    final effectiveBorder = styleValue(
      defaultValue: Border.all(
        color: theme.colorScheme.border,
      ),
      themeValue: compTheme?.border,
      widgetValue: widget.border,
    );
    Decoration effectiveDecoration = widget.decoration ??
        BoxDecoration(
          borderRadius: optionallyResolveBorderRadius(
                context,
                widget.borderRadius ?? compTheme?.borderRadius,
              ) ??
              BorderRadius.circular(theme.radiusMd),
          color: (widget.filled ?? compTheme?.filled ?? false)
              ? theme.colorScheme.muted
              : theme.colorScheme.input.scaleAlpha(0.3),
          border: effectiveBorder,
        );

    // final inputGroup = InputGroupData.maybeOf(context);
    // if (inputGroup != null) {
    //   effectiveDecoration = inputGroup.applyBoxDecoration(effectiveDecoration, Directionality.maybeOf(context) ?? TextDirection.ltr);
    // }
    final styleOverride = Data.maybeOf<ButtonStyleOverrideData>(context);
    if (styleOverride != null) {
      effectiveDecoration = styleOverride.decoration
              ?.call(context, _statesController.value, effectiveDecoration) ??
          effectiveDecoration;
    }

    final Color selectionColor =
        DefaultSelectionStyle.of(context).selectionColor ??
            theme.colorScheme.primary.withValues(
              alpha: 0.2,
            );

    // Set configuration as disabled if not otherwise specified. If specified,
    // ensure that configuration uses Cupertino text style for misspelled words
    // unless a custom style is specified.
    final SpellCheckConfiguration spellCheckConfiguration =
        widget.spellCheckConfiguration ??
            const SpellCheckConfiguration.disabled();

    final scaling = theme.scaling;
    final Widget editable = RepaintBoundary(
      child: UnmanagedRestorationScope(
        bucket: bucket,
        child: EditableText(
          key: editableTextKey,
          controller: controller,
          undoController: widget.undoController,
          readOnly: widget.readOnly || !enabled,
          showCursor: widget.showCursor,
          showSelectionHandles: _showSelectionHandles,
          focusNode: _effectiveFocusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          style: defaultTextStyle,
          strutStyle: widget.strutStyle,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          autofocus: widget.autofocus,
          obscuringCharacter: widget.obscuringCharacter,
          obscureText: widget.obscureText,
          autocorrect: widget.autocorrect,
          smartDashesType: widget.smartDashesType,
          smartQuotesType: widget.smartQuotesType,
          enableSuggestions: widget.enableSuggestions,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          expands: widget.expands,
          magnifierConfiguration: widget.magnifierConfiguration ??
              const TextMagnifierConfiguration(),
          // Only show the selection highlight when the text field is focused.
          selectionColor: _effectiveFocusNode.hasFocus ? selectionColor : null,
          selectionControls: selectionEnabled ? textSelectionControls : null,
          groupId: widget.groupId,
          onChanged: _onChanged,
          onSelectionChanged: _handleSelectionChanged,
          onEditingComplete: () {
            widget.onEditingComplete?.call();
            _formatSubmit();
          },
          onSubmitted: (value) {
            widget.onSubmitted?.call(value);
            _formatSubmit();
          },
          onTapOutside: widget.onTapOutside,
          inputFormatters: formatters,
          rendererIgnoresPointer: true,
          cursorWidth: widget.cursorWidth,
          cursorHeight: widget.cursorHeight,
          cursorRadius: widget.cursorRadius,
          cursorColor: cursorColor,
          cursorOpacityAnimates: widget.cursorOpacityAnimates,
          paintCursorAboveText: true,
          autocorrectionTextRectColor: selectionColor,
          backgroundCursorColor: theme.colorScheme.border,
          selectionHeightStyle: widget.selectionHeightStyle,
          selectionWidthStyle: widget.selectionWidthStyle,
          scrollPadding: widget.scrollPadding,
          keyboardAppearance: keyboardAppearance,
          dragStartBehavior: widget.dragStartBehavior,
          scrollController: widget.scrollController,
          scrollPhysics: widget.scrollPhysics,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          autofillClient: this,
          clipBehavior: Clip.none,
          restorationId: 'editable',
          stylusHandwritingEnabled: widget.stylusHandwritingEnabled,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          contentInsertionConfiguration: widget.contentInsertionConfiguration,
          contextMenuBuilder: widget.contextMenuBuilder,
          spellCheckConfiguration: spellCheckConfiguration,
        ),
      ),
    );

    Widget textField = MouseRegion(
      cursor: enabled ? SystemMouseCursors.text : SystemMouseCursors.forbidden,
      child: FocusOutline(
        focused: _effectiveFocusNode.hasFocus,
        borderRadius: effectiveDecoration is BoxDecoration
            ? effectiveDecoration.borderRadius
            : null,
        child: IconTheme.merge(
          data: theme.iconTheme.small.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
          child: _wrapActions(
            child: MouseRegion(
              onEnter: _onEnter,
              onExit: _onExit,
              opaque: false,
              child: Semantics(
                enabled: enabled,
                onTap: !enabled || widget.readOnly
                    ? null
                    : () {
                        if (!controller.selection.isValid) {
                          controller.selection = TextSelection.collapsed(
                              offset: controller.text.length);
                        }
                        _requestKeyboard();
                      },
                onDidGainAccessibilityFocus: handleDidGainAccessibilityFocus,
                onDidLoseAccessibilityFocus: handleDidLoseAccessibilityFocus,
                onFocus: enabled
                    ? () {
                        assert(
                          _effectiveFocusNode.canRequestFocus,
                          'Received SemanticsAction.focus from the engine. However, the FocusNode '
                          'of this text field cannot gain focus. This likely indicates a bug. '
                          'If this text field cannot be focused (e.g. because it is not '
                          'enabled), then its corresponding semantics node must be configured '
                          'such that the assistive technology cannot request focus on it.',
                        );

                        if (_effectiveFocusNode.canRequestFocus &&
                            !_effectiveFocusNode.hasFocus) {
                          _effectiveFocusNode.requestFocus();
                        } else if (!widget.readOnly) {
                          // If the platform requested focus, that means that previously the
                          // platform believed that the text field did not have focus (even
                          // though Flutter's widget system believed otherwise). This likely
                          // means that the on-screen keyboard is hidden, or more generally,
                          // there is no current editing session in this field. To correct
                          // that, keyboard must be requested.
                          //
                          // A concrete scenario where this can happen is when the user
                          // dismisses the keyboard on the web. The editing session is
                          // closed by the engine, but the text field widget stays focused
                          // in the framework.
                          _requestKeyboard();
                        }
                      }
                    : null,
                child: TextFieldTapRegion(
                  child: IgnorePointer(
                    ignoring: !enabled,
                    child: Container(
                      clipBehavior: widget.clipBehavior,
                      decoration: effectiveDecoration,
                      child:
                          _selectionGestureDetectorBuilder.buildGestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Align(
                          alignment: Alignment(-1.0, _textAlignVertical.y),
                          widthFactor: 1.0,
                          heightFactor: 1.0,
                          child: Padding(
                            padding: widget.padding ??
                                compTheme?.padding ??
                                EdgeInsets.symmetric(
                                  horizontal: 12 * scaling,
                                  vertical: 8 * scaling,
                                ),
                            child: _addTextDependentAttachments(
                                editable, defaultTextStyle, theme),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (final attached in _attachedFeatures) {
      textField = attached.state.wrap(textField);
    }

    double fontHeight =
        (defaultTextStyle.fontSize ?? 14.0) * (defaultTextStyle.height ?? 1.0);
    double verticalPadding = (widget.padding?.vertical ??
        compTheme?.padding?.vertical ??
        (8.0 * 2 * theme.scaling));

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: fontHeight + verticalPadding,
      ),
      child: WidgetStatesProvider(
        states: {
          if (_effectiveFocusNode.hasFocus) WidgetState.hovered,
        },
        child: textField,
      ),
    );
  }

  @override
  void didReplaceFormValue(String value) {
    effectiveController.text = value;
    widget.onChanged?.call(value);
  }
}

/// Intent to append text to the current text field content.
///
/// Used with Flutter's Actions/Shortcuts system to programmatically
/// append text to a text field.

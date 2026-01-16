  void initState() {
    super.initState();
    final layer = Data.maybeFind<_SortableLayerState>(context);
    if (layer != null) {
      var data = widget.data;
      if (layer._canClaimDrop(this, data)) {
        _hasClaimedDrop.value = true;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (mounted) {
            layer._claimDrop(this, data);
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant Sortable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (!widget.enabled && _dragging) {
        _onDragCancel();
      }
    }
    if (widget.data != oldWidget.data || _claimUnchanged) {
      _claimUnchanged = false;
      final layer = Data.maybeFind<_SortableLayerState>(context);
      if (layer != null && layer._canClaimDrop(this, widget.data)) {
        _hasClaimedDrop.value = true;
        final data = widget.data;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (mounted) {
            layer._claimDrop(this, data);
          }
        });
      }
    }
  }

  final GlobalKey _key = GlobalKey();
  final GlobalKey _gestureKey = GlobalKey();

  Widget _buildAnimatedSize({
    AlignmentGeometry alignment = Alignment.center,
    Widget? child,
    bool hasCandidate = false,
    required Duration duration,
  }) {
    if (!hasCandidate) {
      return child!;
    }
    return AnimatedSize(
      duration: duration,
      alignment: alignment,
      child: child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_dragging) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollableLayer?._endDrag(this);
        _session!.layer.removeDraggingSession(_session!);
        _currentTarget.value = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final layer = Data.of<_SortableLayerState>(context);
    return MetaData(
      behavior: HitTestBehavior.translucent,
      metaData: this,
      // must define the generic type to avoid type inference _SortableState<T>
      child: Data<_SortableState>.inherit(
        data: this,
        child: ListenableBuilder(
          listenable: layer._sessions,
          builder: (context, child) {
            bool hasCandidate = layer._sessions.value.isNotEmpty;
            Widget container = GestureDetector(
              key: _gestureKey,
              behavior: widget.behavior,
              onPanStart: widget.enabled ? _onDragStart : null,
              onPanUpdate: widget.enabled ? _onDragUpdate : null,
              onPanEnd: widget.enabled ? _onDragEnd : null,
              onPanCancel: widget.enabled ? _onDragCancel : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AbsorbPointer(
                    child: _buildAnimatedSize(
                      duration: kDefaultDuration,
                      alignment: Alignment.centerRight,
                      hasCandidate: hasCandidate,
                      child: ListenableBuilder(
                        listenable: leftCandidate,
                        builder: (context, child) {
                          if (leftCandidate.value != null) {
                            return SizedBox.fromSize(
                              size: leftCandidate.value!.size,
                              child: leftCandidate.value!.placeholder,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AbsorbPointer(
                          child: _buildAnimatedSize(
                            duration: kDefaultDuration,
                            alignment: Alignment.bottomCenter,
                            hasCandidate: hasCandidate,
                            child: ListenableBuilder(
                              listenable: topCandidate,
                              builder: (context, child) {
                                if (topCandidate.value != null) {
                                  return SizedBox.fromSize(
                                    size: topCandidate.value!.size,
                                    child: topCandidate.value!.placeholder,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: _dragging
                              ? widget.fallback ??
                                  ListenableBuilder(
                                    listenable: _hasDraggedOff,
                                    builder: (context, child) {
                                      return (_hasDraggedOff.value
                                          ? AbsorbPointer(
                                              child: Visibility(
                                                visible: false,
                                                maintainState: true,
                                                child: KeyedSubtree(
                                                  key: _key,
                                                  child: widget.child,
                                                ),
                                              ),
                                            )
                                          : AbsorbPointer(
                                              child: Visibility(
                                                maintainSize: true,
                                                maintainAnimation: true,
                                                maintainState: true,
                                                visible: false,
                                                child: KeyedSubtree(
                                                  key: _key,
                                                  child: widget.child,
                                                ),
                                              ),
                                            ));
                                    },
                                  )
                              : ListenableBuilder(
                                  listenable: _hasClaimedDrop,
                                  builder: (context, child) {
                                    return IgnorePointer(
                                      ignoring:
                                          hasCandidate || _hasClaimedDrop.value,
                                      child: Visibility(
                                        maintainSize: true,
                                        maintainAnimation: true,
                                        maintainState: true,
                                        visible: !_hasClaimedDrop.value,
                                        child: KeyedSubtree(
                                          key: _key,
                                          child: widget.child,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        AbsorbPointer(
                          child: _buildAnimatedSize(
                            duration: kDefaultDuration,
                            alignment: Alignment.topCenter,
                            hasCandidate: hasCandidate,
                            child: ListenableBuilder(
                              listenable: bottomCandidate,
                              builder: (context, child) {
                                if (bottomCandidate.value != null) {
                                  return SizedBox.fromSize(
                                    size: bottomCandidate.value!.size,
                                    child: bottomCandidate.value!.placeholder,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AbsorbPointer(
                    child: _buildAnimatedSize(
                      duration: kDefaultDuration,
                      alignment: Alignment.centerLeft,
                      hasCandidate: hasCandidate,
                      child: ListenableBuilder(
                        listenable: rightCandidate,
                        builder: (context, child) {
                          if (rightCandidate.value != null) {
                            return SizedBox.fromSize(
                              size: rightCandidate.value!.size,
                              child: rightCandidate.value!.placeholder,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
            if (!hasCandidate) {
              return container;
            }
            return AnimatedSize(
              duration: kDefaultDuration,
              child: container,
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => _dragging;
}

/// A dedicated drag handle for initiating sortable drag operations.
///
/// SortableDragHandle provides a specific area within a sortable widget that
/// can be used to initiate drag operations. This is useful when you want to
/// restrict drag initiation to a specific handle area rather than the entire
/// sortable widget.
///
/// The handle automatically detects its parent Sortable widget and delegates
/// drag operations to it. It provides visual feedback with appropriate mouse
/// cursors and can be enabled/disabled independently.
///
/// Features:
/// - Dedicated drag initiation area within sortable widgets
/// - Automatic mouse cursor management (grab/grabbing states)
/// - Independent enable/disable control
/// - Automatic cleanup and lifecycle management
///
/// Example:
/// ```dart
/// Sortable<String>(
///   data: SortableData('item'),
///   child: Row(
///     children: [
///       SortableDragHandle(
///         child: Icon(Icons.drag_handle),
///       ),
///       Expanded(child: Text('Drag me by the handle')),
///     ],
///   ),
/// )
/// ```

part of '../sortable.dart';

class _SortableState<T> extends State<Sortable<T>>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<_SortableDraggingSession<T>?> topCandidate =
      ValueNotifier(null);
  final ValueNotifier<_SortableDraggingSession<T>?> leftCandidate =
      ValueNotifier(null);
  final ValueNotifier<_SortableDraggingSession<T>?> rightCandidate =
      ValueNotifier(null);
  final ValueNotifier<_SortableDraggingSession<T>?> bottomCandidate =
      ValueNotifier(null);

  final ValueNotifier<_DroppingTarget<T>?> _currentTarget = ValueNotifier(null);
  final ValueNotifier<_SortableDropFallbackState<T>?> _currentFallback =
      ValueNotifier(null);
  final ValueNotifier<bool> _hasClaimedDrop = ValueNotifier(false);
  final ValueNotifier<bool> _hasDraggedOff = ValueNotifier(false);

  (_SortableState<T>, Offset)? _findState(
      _SortableLayerState target, Offset globalPosition) {
    BoxHitTestResult result = BoxHitTestResult();
    RenderBox renderBox = target.context.findRenderObject() as RenderBox;
    renderBox.hitTest(result, position: globalPosition);
    for (final HitTestEntry entry in result.path) {
      if (entry.target is RenderMetaData) {
        RenderMetaData metaData = entry.target as RenderMetaData;
        if (metaData.metaData is _SortableState<T> &&
            metaData.metaData != this) {
          return (
            metaData.metaData as _SortableState<T>,
            (entry as BoxHitTestEntry).localPosition
          );
        }
      }
    }
    return null;
  }

  _SortableDropFallbackState<T>? _findFallbackState(
      _SortableLayerState target, Offset globalPosition) {
    BoxHitTestResult result = BoxHitTestResult();
    RenderBox renderBox = target.context.findRenderObject() as RenderBox;
    renderBox.hitTest(result, position: globalPosition);
    for (final HitTestEntry entry in result.path) {
      if (entry.target is RenderMetaData) {
        RenderMetaData metaData = entry.target as RenderMetaData;
        if (metaData.metaData is _SortableDropFallbackState<T> &&
            metaData.metaData != this) {
          return metaData.metaData as _SortableDropFallbackState<T>;
        }
      }
    }
    return null;
  }

  bool _dragging = false;
  bool _claimUnchanged = false;
  _SortableDraggingSession<T>? _session;

  _ScrollableSortableLayerState? _scrollableLayer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollableLayer = Data.maybeOf<_ScrollableSortableLayerState>(context);
  }

  void _onDragStart(DragStartDetails details) {
    if (_hasClaimedDrop.value) {
      return;
    }
    _hasDraggedOff.value = false;
    _SortableLayerState? layer = Data.maybeFind<_SortableLayerState>(context);
    assert(layer != null, 'Sortable must be a descendant of SortableLayer');
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    RenderBox layerRenderBox = layer!.context.findRenderObject() as RenderBox;
    Matrix4 transform = renderBox.getTransformTo(layerRenderBox);
    Size size = renderBox.size;
    Offset minOffset = MatrixUtils.transformPoint(transform, Offset.zero);
    Offset maxOffset = MatrixUtils.transformPoint(
      transform,
      Offset(size.width, size.height),
    );
    final ghost = widget.ghost ?? widget.child;
    final candidateFallback = widget.candidateFallback;
    _session = _SortableDraggingSession(
      layer: layer,
      layerRenderBox: layerRenderBox,
      target: this,
      transform: transform,
      size: size,
      ghost: ListenableBuilder(
        listenable: _currentTarget,
        builder: (context, child) {
          if (_currentTarget.value != null) {
            return candidateFallback ?? widget.child;
          }
          return ghost;
        },
      ),
      placeholder: widget.placeholder ?? widget.child,
      data: widget.data,
      minOffset: minOffset,
      maxOffset: maxOffset,
      lock: layer.widget.lock,
      offset: Offset.zero,
    );
    layer.pushDraggingSession(_session!);
    widget.onDragStart?.call();
    setState(() {
      _dragging = true;
    });
    _scrollableLayer?._startDrag(this, details.globalPosition);
  }

  ValueNotifier<_SortableDraggingSession<T>?> _getByLocation(
      _SortableDropLocation location) {
    switch (location) {
      case _SortableDropLocation.top:
        return topCandidate;
      case _SortableDropLocation.left:
        return leftCandidate;
      case _SortableDropLocation.right:
        return rightCandidate;
      case _SortableDropLocation.bottom:
        return bottomCandidate;
    }
  }

  void _handleDrag(Offset delta) {
    Offset minOffset = _session!.minOffset;
    Offset maxOffset = _session!.maxOffset;
    if (_session != null) {
      RenderBox sessionRenderBox =
          _session!.layer.context.findRenderObject() as RenderBox;
      Size size = sessionRenderBox.size;
      if (_session!.lock) {
        double minX = -minOffset.dx;
        double maxX = size.width - maxOffset.dx;
        double minY = -minOffset.dy;
        double maxY = size.height - maxOffset.dy;
        _session!.offset.value = Offset(
          (_session!.offset.value.dx + delta.dx).clamp(
            min(minX, maxX),
            max(minX, maxX),
          ),
          (_session!.offset.value.dy + delta.dy).clamp(
            min(minY, maxY),
            max(minY, maxY),
          ),
        );
      } else {
        _session!.offset.value += delta;
      }
      Offset globalPosition = _session!.offset.value +
          minOffset +
          Offset((maxOffset.dx - minOffset.dx) / 2,
              (maxOffset.dy - minOffset.dy) / 2);
      (_SortableState<T>, Offset)? target =
          _findState(_session!.layer, globalPosition);
      if (target == null) {
        _SortableDropFallbackState<T>? fallback =
            _findFallbackState(_session!.layer, globalPosition);
        _currentFallback.value = fallback;
        if (_currentTarget.value != null && fallback == null) {
          _currentTarget.value!.dispose(_session!);
          _currentTarget.value = null;
        }
      } else {
        _hasDraggedOff.value = true;
        _currentFallback.value = null;
        if (_currentTarget.value != null) {
          _currentTarget.value!.dispose(_session!);
        }
        var targetRenderBox = target.$1.context.findRenderObject() as RenderBox;
        var size = targetRenderBox.size;
        _SortableDropLocation? location = _getPosition(
          target.$2,
          size,
          acceptTop: widget.onAcceptTop != null,
          acceptLeft: widget.onAcceptLeft != null,
          acceptRight: widget.onAcceptRight != null,
          acceptBottom: widget.onAcceptBottom != null,
        );
        if (location != null) {
          ValueNotifier<_SortableDraggingSession<T>?> candidate =
              target.$1._getByLocation(location);

          candidate.value = _session;
          _currentTarget.value = _DroppingTarget(
              candidate: candidate, source: target.$1, location: location);
        }
      }
    }
  }

  ValueChanged<SortableData<T>>? _getCallback(_SortableDropLocation location) {
    switch (location) {
      case _SortableDropLocation.top:
        return widget.onAcceptTop;
      case _SortableDropLocation.left:
        return widget.onAcceptLeft;
      case _SortableDropLocation.right:
        return widget.onAcceptRight;
      case _SortableDropLocation.bottom:
        return widget.onAcceptBottom;
    }
  }

  Predicate<SortableData<T>>? _getPredicate(_SortableDropLocation location) {
    switch (location) {
      case _SortableDropLocation.top:
        return widget.canAcceptTop;
      case _SortableDropLocation.left:
        return widget.canAcceptLeft;
      case _SortableDropLocation.right:
        return widget.canAcceptRight;
      case _SortableDropLocation.bottom:
        return widget.canAcceptBottom;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_hasClaimedDrop.value) {
      return;
    }
    _handleDrag(details.delta);
    _scrollableLayer?._updateDrag(this, details.globalPosition);
  }

  void _onDragEnd(DragEndDetails details) {
    widget.onDragEnd?.call();
    if (_session != null) {
      if (_currentTarget.value != null) {
        _currentTarget.value!.dispose(_session!);
        var target = _currentTarget.value!.source;
        var location = _currentTarget.value!.location;
        var predicate = target._getPredicate(location);
        var sortData = _session!.data;
        if (predicate == null || predicate(sortData)) {
          var callback = target._getCallback(location);
          if (callback != null) {
            callback(sortData);
          }
        }
        _session!.layer.removeDraggingSession(_session!);
        _currentTarget.value = null;
      } else if (_hasDraggedOff.value) {
        var target = _currentFallback.value;
        if (target != null) {
          var sortData = _session!.data;
          if (target.widget.canAccept == null ||
              target.widget.canAccept!(sortData)) {
            target.widget.onAccept?.call(sortData);
          }
        }
        _session!.layer.removeDraggingSession(_session!);
        if (target == null) {
          _session!.layer._claimDrop(this, _session!.data, true);
        }
      } else {
        // basically the same as drag cancel, because the drag has not been
        // dragged off of itself
        _session!.layer.removeDraggingSession(_session!);
        widget.onDropFailed?.call();
        _session!.layer._claimDrop(this, _session!.data, true);
      }
      _claimUnchanged = true;
      _session = null;
    }
    setState(() {
      _dragging = false;
    });
    _scrollableLayer?._endDrag(this);
  }

  void _onDragCancel() {
    if (_session != null) {
      if (_currentTarget.value != null) {
        _currentTarget.value!.dispose(_session!);
        _currentTarget.value = null;
      }
      _session!.layer.removeDraggingSession(_session!);
      _session!.layer._claimDrop(this, _session!.data, true);
      _session = null;
    }
    setState(() {
      _dragging = false;
    });
    widget.onDragCancel?.call();
    _scrollableLayer?._endDrag(this);
  }

  @override

part of '../sortable.dart';

class _SortableDragHandleState extends State<SortableDragHandle>
    with AutomaticKeepAliveClientMixin {
  _SortableState? _state;

  bool _dragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = Data.maybeOf<_SortableState>(context);
  }

  @override
  bool get wantKeepAlive {
    return _dragging;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MouseRegion(
      cursor: widget.enabled
          ? (widget.cursor ?? SystemMouseCursors.grab)
          : MouseCursor.defer,
      hitTestBehavior: widget.behavior,
      child: GestureDetector(
        behavior: widget.behavior,
        onPanStart: widget.enabled && _state != null
            ? (details) {
                _dragging = true;
                _state!._onDragStart(details);
              }
            : null,
        onPanUpdate:
            widget.enabled && _state != null ? _state!._onDragUpdate : null,
        onPanEnd: widget.enabled && _state != null
            ? (details) {
                _state!._onDragEnd(details);
                _dragging = false;
              }
            : null,
        onPanCancel: widget.enabled && _state != null
            ? () {
                _state!._onDragCancel();
                _dragging = false;
              }
            : null,
        child: widget.child,
      ),
    );
  }
}

/// Immutable data wrapper for sortable items in drag-and-drop operations.
///
/// SortableData wraps the actual data being sorted and provides identity for
/// drag-and-drop operations. Each sortable item must have associated data that
/// uniquely identifies it within the sorting context.
///
/// The class is immutable and uses reference equality for comparison, ensuring
/// that each sortable item maintains its identity throughout drag operations.
/// This is crucial for proper drop validation and handling.
///
/// Type parameter [T] represents the type of data being sorted, which can be
/// any type including primitive types, custom objects, or complex data structures.
///
/// Example:
/// ```dart
/// // Simple string data
/// SortableData<String>('item_1')
///
/// // Complex object data
/// SortableData<TodoItem>(TodoItem(id: 1, title: 'Task 1'))
///
/// // Map data
/// SortableData<Map<String, dynamic>>({'id': 1, 'name': 'Item'})
/// ```
@immutable

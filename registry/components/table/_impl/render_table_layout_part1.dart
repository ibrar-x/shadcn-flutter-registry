part of '../table.dart';

class RenderTableLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableParentData> {
  TableSizeSupplier _width;
  TableSizeSupplier _height;
  Clip _clipBehavior;
  CellPredicate? _frozenColumn;
  CellPredicate? _frozenRow;
  double? _verticalOffset;
  double? _horizontalOffset;
  Size? _viewportSize;

  TableLayoutResult? _layoutResult;

  /// Creates a render object for table layout.
  ///
  /// Initializes the table layout system with sizing functions and optional
  /// frozen cell configurations. This render object handles the complex
  /// layout calculations for tables with variable cell sizes.
  ///
  /// Parameters:
  /// - [children] (`List<RenderBox>?`): Optional initial child render boxes
  /// - [width] (TableSizeSupplier, required): Function providing width for each column
  /// - [height] (TableSizeSupplier, required): Function providing height for each row
  /// - [clipBehavior] (Clip, required): How to clip children outside table bounds
  /// - [frozenCell] (CellPredicate?): Predicate identifying frozen columns
  /// - [frozenRow] (CellPredicate?): Predicate identifying frozen rows
  /// - [verticalOffset] (double?): Vertical scroll offset for viewport
  /// - [horizontalOffset] (double?): Horizontal scroll offset for viewport
  /// - [viewportSize] (Size?): Size of the visible viewport area
  ///
  /// Frozen cells remain visible during scrolling, useful for sticky headers.
  RenderTableLayout(
      {List<RenderBox>? children,
      required TableSizeSupplier width,
      required TableSizeSupplier height,
      required Clip clipBehavior,
      CellPredicate? frozenCell,
      CellPredicate? frozenRow,
      double? verticalOffset,
      double? horizontalOffset,
      Size? viewportSize})
      : _clipBehavior = clipBehavior,
        _width = width,
        _height = height,
        _frozenColumn = frozenCell,
        _frozenRow = frozenRow,
        _verticalOffset = verticalOffset,
        _horizontalOffset = horizontalOffset,
        _viewportSize = viewportSize {
    addAll(children);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! TableParentData) {
      child.parentData = TableParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // reverse hit test traversal so that the first child is hit tested last
    // important for column and row spans
    RenderBox? child = firstChild;
    while (child != null) {
      final parentData = child.parentData as TableParentData;
      final hit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
      if (hit) {
        return true;
      }
      child = childAfter(child);
    }
    return false;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return computeTableSize(BoxConstraints.loose(Size(double.infinity, height)),
        (child, extent) {
      return child.getMinIntrinsicWidth(extent);
    }).width;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return computeTableSize(constraints).size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // reverse paint traversal so that the first child is painted last
    // important for column and row spans
    // (ASSUMPTION: children are already sorted in the correct order)
    if (_clipBehavior != Clip.none) {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        (context, offset) {
          RenderBox? child = lastChild;
          while (child != null) {
            final parentData = child.parentData as TableParentData;
            if (parentData.computeSize &&
                !parentData.frozenRow &&
                !parentData.frozenColumn) {
              context.paintChild(child, offset + parentData.offset);
            }
            child = childBefore(child);
          }
        },
        clipBehavior: _clipBehavior,
      );
      RenderBox? child = lastChild;
      while (child != null) {
        final parentData = child.parentData as TableParentData;
        if (!parentData.computeSize &&
            !parentData.frozenRow &&
            !parentData.frozenColumn) {
          context.paintChild(child, offset + parentData.offset);
        }
        child = childBefore(child);
      }
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        (context, offset) {
          RenderBox? child = lastChild;
          while (child != null) {
            final parentData = child.parentData as TableParentData;
            if (parentData.frozenColumn) {
              context.paintChild(child, offset + parentData.offset);
            }
            child = childBefore(child);
          }
        },
        clipBehavior: _clipBehavior,
      );
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        (context, offset) {
          RenderBox? child = lastChild;
          while (child != null) {
            final parentData = child.parentData as TableParentData;
            if (parentData.frozenRow) {
              context.paintChild(child, offset + parentData.offset);
            }
            child = childBefore(child);
          }
        },
        clipBehavior: _clipBehavior,
      );
      child = lastChild;
      while (child != null) {
        final parentData = child.parentData as TableParentData;
        if (!parentData.computeSize && (parentData.frozenColumn)) {
          context.paintChild(child, offset + parentData.offset);
        }
        child = childBefore(child);
      }
      child = lastChild;
      while (child != null) {
        final parentData = child.parentData as TableParentData;
        if (!parentData.computeSize && (parentData.frozenRow)) {
          context.paintChild(child, offset + parentData.offset);
        }
        child = childBefore(child);
      }
      return;
    }
    RenderBox? child = lastChild;
    while (child != null) {
      final parentData = child.parentData as TableParentData;
      if (!parentData.frozenRow && !parentData.frozenColumn) {
        context.paintChild(child, offset + parentData.offset);
      }
      child = childBefore(child);
    }
    child = lastChild;
    while (child != null) {
      final parentData = child.parentData as TableParentData;
      if (parentData.frozenColumn) {
        context.paintChild(child, offset + parentData.offset);
      }
      child = childBefore(child);
    }
    child = lastChild;
    while (child != null) {
      final parentData = child.parentData as TableParentData;
      if (parentData.frozenRow) {
        context.paintChild(child, offset + parentData.offset);
      }
      child = childBefore(child);
    }
  }

  @override
  void performLayout() {

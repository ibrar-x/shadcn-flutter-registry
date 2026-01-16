    final result = computeTableSize(constraints);
    size = constraints.constrain(result.size);

    Map<int, double> frozenRows = {};
    Map<int, double> frozenColumns = {};

    double effectiveHorizontalOffset = _horizontalOffset ?? 0;
    double effectiveVerticalOffset = _verticalOffset ?? 0;

    if (_viewportSize != null) {
      double maxHorizontalScroll = max(0, size.width - _viewportSize!.width);
      double maxVerticalScroll = max(0, size.height - _viewportSize!.height);
      effectiveHorizontalOffset =
          effectiveHorizontalOffset.clamp(0, maxHorizontalScroll);
      effectiveVerticalOffset =
          effectiveVerticalOffset.clamp(0, maxVerticalScroll);
    } else {
      effectiveHorizontalOffset = max(0, effectiveHorizontalOffset);
      effectiveVerticalOffset = max(0, effectiveVerticalOffset);
    }

    RenderBox? child = firstChild;
    while (child != null) {
      final parentData = child.parentData as TableParentData;
      final column = parentData.column;
      final row = parentData.row;
      if (column != null && row != null) {
        double width = 0;
        double height = 0;
        int columnSpan = parentData.columnSpan ?? 1;
        int rowSpan = parentData.rowSpan ?? 1;
        bool frozenRow = _frozenRow?.call(row, rowSpan) ?? false;
        bool frozenColumn = _frozenColumn?.call(column, columnSpan) ?? false;
        for (int i = 0;
            i < columnSpan && column + i < result.columnWidths.length;
            i++) {
          width += result.columnWidths[column + i];
        }
        for (int i = 0;
            i < rowSpan && row + i < result.rowHeights.length;
            i++) {
          height += result.rowHeights[row + i];
        }
        child.layout(BoxConstraints.tightFor(width: width, height: height));
        final offset = result.getOffset(column, row);
        double offsetX = offset.dx;
        double offsetY = offset.dy;

        if (frozenRow) {
          double verticalOffset = effectiveVerticalOffset;
          double offsetInViewport =
              offsetY - (_viewportSize != null ? verticalOffset : 0);

          // make sure its visible on the viewport
          double minViewport = 0;
          double maxViewport = _viewportSize?.height ?? constraints.maxHeight;
          if (maxViewport == double.infinity) {
            maxViewport = size.height;
          }
          for (int i = 0; i < row; i++) {
            var rowHeight = frozenRows[i] ?? 0;
            minViewport += rowHeight;
          }
          double verticalAdjustment = 0;
          if (_viewportSize != null && verticalOffset < 0) {
            verticalAdjustment = verticalOffset;
          } else if (offsetInViewport < minViewport) {
            verticalAdjustment = -offsetInViewport + minViewport;
          } else if (offsetInViewport + height > maxViewport) {
            // Sticky bottom logic if needed, but for now just top sticking
            // verticalAdjustment = maxViewport - offsetInViewport - height;
          }
          frozenRows[row] = max(frozenRows[row] ?? 0, height);
          offsetY += verticalAdjustment;
        }
        if (frozenColumn) {
          double horizontalOffset = effectiveHorizontalOffset;
          double offsetInViewport =
              offsetX - (_viewportSize != null ? horizontalOffset : 0);

          // make sure its visible on the viewport
          double minViewport = 0;
          double maxViewport = _viewportSize?.width ?? constraints.maxWidth;
          if (maxViewport == double.infinity) {
            maxViewport = size.width;
          }
          for (int i = 0; i < column; i++) {
            var columnWidth = frozenColumns[i] ?? 0;
            minViewport += columnWidth;
          }
          double horizontalAdjustment = 0;
          if (_viewportSize != null && horizontalOffset < 0) {
            horizontalAdjustment = horizontalOffset;
          } else if (offsetInViewport < minViewport) {
            horizontalAdjustment = -offsetInViewport + minViewport;
          } else if (offsetInViewport + width > maxViewport) {
            // Sticky right logic if needed
            // horizontalAdjustment = maxViewport - offsetInViewport - width;
          }
          frozenColumns[column] = max(frozenColumns[column] ?? 0, width);
          offsetX += horizontalAdjustment;
        }
        parentData.frozenRow = frozenRow;
        parentData.frozenColumn = frozenColumn;
        parentData.offset = Offset(offsetX, offsetY);
      }
      child = childAfter(child);
    }

    _layoutResult = result;
  }

  /// Computes the table layout with specified constraints.
  ///
  /// Performs the complex table layout algorithm that:
  /// 1. Determines maximum row and column counts from child cells
  /// 2. Calculates fixed and flexible sizing for all columns and rows
  /// 3. Distributes available space among flex items
  /// 4. Handles both tight and loose flex constraints
  /// 5. Computes final dimensions for each column and row
  ///
  /// The layout algorithm respects size constraints from [TableSize] objects
  /// and ensures cells spanning multiple columns/rows are properly handled.
  ///
  /// Parameters:
  /// - [constraints] (BoxConstraints, required): Layout constraints for the table
  /// - [intrinsicComputer] (IntrinsicComputer?): Optional function to compute intrinsic sizes
  ///
  /// Returns [TableLayoutResult] containing computed dimensions and layout metadata.
  TableLayoutResult computeTableSize(BoxConstraints constraints,
      [IntrinsicComputer? intrinsicComputer]) {
    double flexWidth = 0;
    double flexHeight = 0;
    double fixedWidth = 0;
    double fixedHeight = 0;

    Map<int, double> columnWidths = {};
    Map<int, double> rowHeights = {};

    int maxRow = 0;
    int maxColumn = 0;

    bool hasTightFlexWidth = false;
    bool hasTightFlexHeight = false;

    // find the maximum row and column
    RenderBox? child = firstChild;
    while (child != null) {
      final parentData = child.parentData as TableParentData;
      if (parentData.computeSize) {
        int? column = parentData.column;
        int? row = parentData.row;
        if (column != null && row != null) {
          int columnSpan = parentData.columnSpan ?? 1;
          int rowSpan = parentData.rowSpan ?? 1;
          maxColumn = max(maxColumn, column + columnSpan - 1);
          maxRow = max(maxRow, row + rowSpan - 1);
        }
      }
      child = childAfter(child);
    }

    // micro-optimization: avoid calculating flexes if there are no flexes
    bool hasFlexWidth = false;
    bool hasFlexHeight = false;

    // row
    for (int r = 0; r <= maxRow; r++) {
      final heightConstraint = _height(r);
      if (heightConstraint is FlexTableSize &&
          constraints.hasBoundedHeight &&
          intrinsicComputer == null) {
        flexHeight += heightConstraint.flex;
        hasFlexHeight = true;
        if (heightConstraint.fit == FlexFit.tight) {
          hasTightFlexHeight = true;
        }
      } else if (heightConstraint is FixedTableSize) {
        fixedHeight += heightConstraint.value;
        rowHeights[r] = max(rowHeights[r] ?? 0, heightConstraint.value);
      }
    }
    // column
    for (int c = 0; c <= maxColumn; c++) {
      final widthConstraint = _width(c);
      if (widthConstraint is FlexTableSize && constraints.hasBoundedWidth) {
        flexWidth += widthConstraint.flex;
        hasFlexWidth = true;
        if (widthConstraint.fit == FlexFit.tight) {
          hasTightFlexWidth = true;
        }
      } else if (widthConstraint is FixedTableSize) {
        fixedWidth += widthConstraint.value;
        columnWidths[c] = max(columnWidths[c] ?? 0, widthConstraint.value);
      } else if (widthConstraint is FractionalTableSize &&
          constraints.hasBoundedWidth) {
        double value = widthConstraint.fraction * constraints.maxWidth;
        fixedWidth += value;
        columnWidths[c] = max(columnWidths[c] ?? 0, value);
      }

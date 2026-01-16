  double computeMaxIntrinsicWidth(double height) {
    return computeTableSize(BoxConstraints.loose(Size(double.infinity, height)),
        (child, extent) {
      return child.getMaxIntrinsicWidth(extent);
    }).width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return computeTableSize(BoxConstraints.loose(Size(width, double.infinity)),
        (child, extent) {
      return child.getMinIntrinsicHeight(extent);
    }).height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeTableSize(BoxConstraints.loose(Size(width, double.infinity)),
        (child, extent) {
      return child.getMaxIntrinsicHeight(extent);
    }).height;
  }

  // delegate from TableLayoutResult, with read-only view
  /// Gets an unmodifiable list of computed column widths.
  ///
  /// Returns the width of each column after layout calculation. The list
  /// index corresponds to the column index, and the value is the width in
  /// logical pixels.
  ///
  /// Throws [AssertionError] if called before layout is complete.
  ///
  /// Returns an unmodifiable `List<double>` of column widths.
  List<double> get columnWidths {
    assert(_layoutResult != null, 'Layout result is not available');
    return List.unmodifiable(_layoutResult!.columnWidths);
  }

  /// Gets an unmodifiable list of computed row heights.
  ///
  /// Returns the height of each row after layout calculation. The list
  /// index corresponds to the row index, and the value is the height in
  /// logical pixels.
  ///
  /// Throws [AssertionError] if called before layout is complete.
  ///
  /// Returns an unmodifiable `List<double>` of row heights.
  List<double> get rowHeights {
    assert(_layoutResult != null, 'Layout result is not available');
    return List.unmodifiable(_layoutResult!.rowHeights);
  }

  /// Gets the top-left offset of a cell at the specified position.
  ///
  /// Calculates the cumulative offset by summing the widths of all columns
  /// before the specified column and heights of all rows before the specified row.
  ///
  /// Parameters:
  /// - [column] (int, required): Zero-based column index
  /// - [row] (int, required): Zero-based row index
  ///
  /// Throws [AssertionError] if called before layout is complete.
  ///
  /// Returns [Offset] representing the cell's top-left corner position.
  Offset getOffset(int column, int row) {
    assert(_layoutResult != null, 'Layout result is not available');
    return _layoutResult!.getOffset(column, row);
  }

  /// Gets the remaining unclaimed width in the table layout.
  ///
  /// This represents horizontal space not allocated to any column after
  /// fixed and flex sizing calculations. Useful for understanding how much
  /// space is available for expansion or debugging layout issues.
  ///
  /// Throws [AssertionError] if called before layout is complete.
  ///
  /// Returns remaining width in logical pixels as a double.
  double get remainingWidth {
    assert(_layoutResult != null, 'Layout result is not available');
    return _layoutResult!.remainingWidth;
  }

  /// Gets the remaining unclaimed height in the table layout.
  ///
  /// This represents vertical space not allocated to any row after
  /// fixed and flex sizing calculations. Useful for understanding how much
  /// space is available for expansion or debugging layout issues.
  ///
  /// Throws [AssertionError] if called before layout is complete.
  ///
  /// Returns remaining height in logical pixels as a double.
  double get remainingHeight {
    assert(_layoutResult != null, 'Layout result is not available');
    return _layoutResult!.remainingHeight;
  }

  /// Gets the remaining loose (flexible) width available for loose flex items.
  ///
  /// Loose flex items can shrink below their flex allocation. This getter
  /// returns the remaining width available specifically for items with
  /// loose flex constraints (FlexFit.loose).
  ///
  /// Throws [AssertionError] if called before layout is complete.
  ///
  /// Returns remaining loose width in logical pixels as a double.
  double get remainingLooseWidth {
    assert(_layoutResult != null, 'Layout result is not available');
    return _layoutResult!.remainingLooseWidth;
  }

  /// Gets the remaining loose (flexible) height available for loose flex items.
  ///
  /// Loose flex items can shrink below their flex allocation. This getter
  /// returns the remaining height available specifically for items with
  /// loose flex constraints (FlexFit.loose).
  ///
  /// Throws [AssertionError] if called before layout is complete.
  ///
  /// Returns remaining loose height in logical pixels as a double.
  double get remainingLooseHeight {
    assert(_layoutResult != null, 'Layout result is not available');
    return _layoutResult!.remainingLooseHeight;
  }

  /// Indicates whether any column uses tight flex sizing.
  ///
  /// Tight flex items must occupy their full flex allocation. This getter
  /// returns true if at least one column has a tight flex constraint
  /// (FlexFit.tight), which affects how remaining space is distributed.
  ///
  /// Throws [AssertionError] if called before layout is complete.
  ///
  /// Returns true if table has tight flex width columns, false otherwise.
  bool get hasTightFlexWidth {
    assert(_layoutResult != null, 'Layout result is not available');
    return _layoutResult!.hasTightFlexWidth;
  }

  /// Indicates whether any row uses tight flex sizing.
  ///
  /// Tight flex items must occupy their full flex allocation. This getter
  /// returns true if at least one row has a tight flex constraint
  /// (FlexFit.tight), which affects how remaining space is distributed.
  ///
  /// Throws [AssertionError] if called before layout is complete.
  ///
  /// Returns true if table has tight flex height rows, false otherwise.
  bool get hasTightFlexHeight {
    assert(_layoutResult != null, 'Layout result is not available');
    return _layoutResult!.hasTightFlexHeight;
  }
}

/// Function that computes intrinsic dimensions for a render box.
///
/// Used internally during table layout to calculate natural sizes
/// of cells when using intrinsic sizing modes.

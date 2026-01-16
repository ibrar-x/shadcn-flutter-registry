    }

    double spacePerFlexWidth = 0;
    double spacePerFlexHeight = 0;
    double remainingWidth;
    double remainingHeight;
    if (constraints.hasBoundedWidth) {
      remainingWidth = constraints.maxWidth - fixedWidth;
    } else {
      remainingWidth = double.infinity;
    }
    if (constraints.hasBoundedHeight) {
      remainingHeight = constraints.maxHeight - fixedHeight;
    } else {
      remainingHeight = double.infinity;
    }

    // find the proper intrinsic sizes (if any)
    child = lastChild;
    while (child != null) {
      final parentData = child.parentData as TableParentData;
      if (parentData.computeSize) {
        int? column = parentData.column;
        int? row = parentData.row;
        if (column != null && row != null) {
          final widthConstraint = _width(column);
          final heightConstraint = _height(row);
          if (widthConstraint is IntrinsicTableSize ||
              (widthConstraint is FlexTableSize && intrinsicComputer != null)) {
            var extent = rowHeights[row] ?? remainingHeight;
            double maxIntrinsicWidth = intrinsicComputer != null
                ? intrinsicComputer(child, extent)
                : child.getMaxIntrinsicWidth(extent);
            maxIntrinsicWidth = min(maxIntrinsicWidth, remainingWidth);
            int columnSpan = parentData.columnSpan ?? 1;
            // distribute the intrinsic width to all columns
            maxIntrinsicWidth = maxIntrinsicWidth / columnSpan;
            for (int i = 0; i < columnSpan; i++) {
              columnWidths[column + i] =
                  max(columnWidths[column + i] ?? 0, maxIntrinsicWidth);
            }
          }
          if (heightConstraint is IntrinsicTableSize ||
              (heightConstraint is FlexTableSize &&
                  intrinsicComputer != null)) {
            var extent = columnWidths[column] ?? remainingWidth;
            double maxIntrinsicHeight = intrinsicComputer != null
                ? intrinsicComputer(child, extent)
                : child.getMaxIntrinsicHeight(extent);
            maxIntrinsicHeight = min(maxIntrinsicHeight, remainingHeight);
            int rowSpan = parentData.rowSpan ?? 1;
            // distribute the intrinsic height to all rows

            maxIntrinsicHeight = maxIntrinsicHeight / rowSpan;
            for (int i = 0; i < rowSpan; i++) {
              rowHeights[row + i] =
                  max(rowHeights[row + i] ?? 0, maxIntrinsicHeight);
            }
          }
        }
      }
      child = childBefore(child);
    }

    double usedColumnWidth = columnWidths.values.fold(0, (a, b) => a + b);
    double usedRowHeight = rowHeights.values.fold(0, (a, b) => a + b);
    double looseRemainingWidth = remainingWidth;
    double looseRemainingHeight = remainingHeight;
    double looseSpacePerFlexWidth = 0;
    double looseSpacePerFlexHeight = 0;

    if (intrinsicComputer == null) {
      // recalculate remaining space for flexes
      if (constraints.hasBoundedWidth) {
        remainingWidth = constraints.maxWidth - usedColumnWidth;
      } else {
        remainingWidth = double.infinity;
      }
      if (constraints.hasInfiniteWidth) {
        looseRemainingWidth = double.infinity;
      } else {
        looseRemainingWidth = max(0, constraints.minWidth - usedColumnWidth);
      }
      if (constraints.hasBoundedHeight) {
        remainingHeight = constraints.maxHeight - usedRowHeight;
      } else {
        remainingHeight = double.infinity;
      }
      if (constraints.hasInfiniteHeight) {
        looseRemainingHeight = double.infinity;
      } else {
        looseRemainingHeight = max(0, constraints.minHeight - usedRowHeight);
      }
      if (flexWidth > 0 && remainingWidth > 0) {
        spacePerFlexWidth = remainingWidth / flexWidth;
      } else {
        spacePerFlexWidth = 0;
      }
      if (flexWidth > 0 && looseRemainingWidth > 0) {
        looseSpacePerFlexWidth = looseRemainingWidth / flexWidth;
      }
      if (flexHeight > 0 && remainingHeight > 0) {
        spacePerFlexHeight = remainingHeight / flexHeight;
      } else {
        spacePerFlexHeight = 0;
      }
      if (flexHeight > 0 && looseRemainingHeight > 0) {
        spacePerFlexHeight = looseRemainingHeight / flexHeight;
      }

      // calculate space used for flexes
      if (hasFlexWidth) {
        for (int c = 0; c <= maxColumn; c++) {
          final widthConstraint = _width(c);
          if (widthConstraint is FlexTableSize) {
            // columnWidths[c] = widthConstraint.flex * spacePerFlexWidth;
            if (widthConstraint.fit == FlexFit.tight || hasTightFlexWidth) {
              columnWidths[c] = widthConstraint.flex * spacePerFlexWidth;
            } else {
              columnWidths[c] = widthConstraint.flex * looseSpacePerFlexWidth;
            }
          }
        }
      }
      if (hasFlexHeight) {
        for (int r = 0; r <= maxRow; r++) {
          final heightConstraint = _height(r);
          if (heightConstraint is FlexTableSize) {
            // rowHeights[r] = heightConstraint.flex * spacePerFlexHeight;
            if (heightConstraint.fit == FlexFit.tight || hasTightFlexHeight) {
              rowHeights[r] = heightConstraint.flex * spacePerFlexHeight;
            } else {
              rowHeights[r] = heightConstraint.flex * looseSpacePerFlexHeight;
            }
          }
        }
      }
    }

    // Second pass: recalculate intrinsic sizes if they depend on flex sizes
    if (intrinsicComputer == null) {
      child = lastChild;
      while (child != null) {
        final parentData = child.parentData as TableParentData;
        if (parentData.computeSize) {
          int? column = parentData.column;
          int? row = parentData.row;
          if (column != null && row != null) {
            final heightConstraint = _height(row);
            // Check if we need to recalculate height (Intrinsic row with Flex/Fixed column)
            if (heightConstraint is IntrinsicTableSize) {
              // If column was Flex, it now has a calculated width in columnWidths
              // If column was Fixed, it's also in columnWidths
              // We can use the actual column width now
              int columnSpan = parentData.columnSpan ?? 1;
              double availableWidth = 0;
              for (int i = 0; i < columnSpan; i++) {
                availableWidth += columnWidths[column + i] ?? 0;
              }

              if (availableWidth > 0) {
                double maxIntrinsicHeight =
                    child.getMaxIntrinsicHeight(availableWidth);
                maxIntrinsicHeight = min(maxIntrinsicHeight, remainingHeight);

                int rowSpan = parentData.rowSpan ?? 1;

                maxIntrinsicHeight = maxIntrinsicHeight / rowSpan;
                for (int i = 0; i < rowSpan; i++) {
                  rowHeights[row + i] =
                      max(rowHeights[row + i] ?? 0, maxIntrinsicHeight);
                }
              }
            }
          }
        }
        child = childBefore(child);
      }
    }

    // convert the column widths and row heights to a list, where missing values are 0
    List<double> columnWidthsList = List.generate(maxColumn + 1, (index) {
      return columnWidths[index] ?? 0;
    });
    columnWidths.forEach((key, value) {
      columnWidthsList[key] = value;
    });
    List<double> rowHeightsList =
        // List.filled(rowHeights.keys.reduce(max) + 1, 0);
        List.generate(maxRow + 1, (index) {
      return rowHeights[index] ?? 0;
    });
    rowHeights.forEach((key, value) {
      rowHeightsList[key] = value;
    });
    return TableLayoutResult(
      columnWidths: columnWidthsList,
      rowHeights: rowHeightsList,
      remainingWidth: remainingWidth,
      remainingHeight: remainingHeight,
      remainingLooseWidth: looseRemainingWidth,
      remainingLooseHeight: looseRemainingHeight,
      hasTightFlexWidth: hasTightFlexWidth,
      hasTightFlexHeight: hasTightFlexHeight,
    );
  }

  @override

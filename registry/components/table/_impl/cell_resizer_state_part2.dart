                            details.primaryDelta!);
                  }
                },
                onVerticalDragEnd: _onDragEnd,
                onVerticalDragCancel: _onDragCancel,
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    widget.hoverNotifier,
                    widget.dragNotifier,
                  ]),
                  builder: (context, child) {
                    _HoveredLine? hover = widget.hoverNotifier.value;
                    _HoveredLine? drag = widget.dragNotifier.value;
                    if (drag != null) {
                      hover = null;
                    }
                    return Container(
                      color: (hover?.index == row + rowSpan - 1 &&
                                  hover?.direction == Axis.horizontal) ||
                              (drag?.index == row + rowSpan - 1 &&
                                  drag?.direction == Axis.horizontal)
                          ? widget.theme?.resizerColor ??
                              theme.colorScheme.primary
                          : null,
                    );
                  },
                ),
              ),
            ),
          ),
        // left
        if (column > 0 && widthMode != TableCellResizeMode.none)
          Positioned(
            left: -thickness / 2,
            top: 0,
            bottom: 0,
            width: thickness,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              hitTestBehavior: HitTestBehavior.translucent,
              onEnter: (event) {
                widget.onHover(true, column - 1, Axis.vertical);
              },
              onExit: (event) {
                widget.onHover(false, column - 1, Axis.vertical);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: _onDragStartColumn,
                onHorizontalDragUpdate: (details) {
                  if (widthMode == TableCellResizeMode.reallocate) {
                    _onDragUpdate(column - 1, column, details);
                  } else {
                    widget.controller.resizeColumn(
                        column - 1,
                        widget.controller.getColumnWidth(column - 1) +
                            details.primaryDelta!);
                  }
                },
                onHorizontalDragEnd: _onDragEnd,
                onHorizontalDragCancel: _onDragCancel,
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    widget.hoverNotifier,
                    widget.dragNotifier,
                  ]),
                  builder: (context, child) {
                    _HoveredLine? hover = widget.hoverNotifier.value;
                    _HoveredLine? drag = widget.dragNotifier.value;
                    if (drag != null) {
                      hover = null;
                    }
                    return Container(
                      color: (hover?.index == column - 1 &&
                                  hover?.direction == Axis.vertical) ||
                              (drag?.index == column - 1 &&
                                  drag?.direction == Axis.vertical)
                          ? widget.theme?.resizerColor ??
                              theme.colorScheme.primary
                          : null,
                    );
                  },
                ),
              ),
            ),
          ),
        // right
        if ((column + columnSpan <= tableData.maxColumn ||
                widthMode == TableCellResizeMode.expand) &&
            widthMode != TableCellResizeMode.none)
          Positioned(
            right: -thickness / 2,
            top: 0,
            bottom: 0,
            width: thickness,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              hitTestBehavior: HitTestBehavior.translucent,
              onEnter: (event) {
                widget.onHover(true, column + columnSpan - 1, Axis.vertical);
              },
              onExit: (event) {
                widget.onHover(false, column + columnSpan - 1, Axis.vertical);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: _onDragStartColumn,
                onHorizontalDragUpdate: (details) {
                  if (widthMode == TableCellResizeMode.reallocate) {
                    _onDragUpdate(
                        column + columnSpan - 1, column + columnSpan, details);
                  } else {
                    widget.controller.resizeColumn(
                        column + columnSpan - 1,
                        widget.controller
                                .getColumnWidth(column + columnSpan - 1) +
                            details.primaryDelta!);
                  }
                },
                onHorizontalDragEnd: _onDragEnd,
                onHorizontalDragCancel: _onDragCancel,
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    widget.hoverNotifier,
                    widget.dragNotifier,
                  ]),
                  builder: (context, child) {
                    _HoveredLine? hover = widget.hoverNotifier.value;
                    _HoveredLine? drag = widget.dragNotifier.value;
                    if (drag != null) {
                      hover = null;
                    }
                    return Container(
                      color: (hover?.index == column + columnSpan - 1 &&
                                  hover?.direction == Axis.vertical) ||
                              (drag?.index == column + columnSpan - 1 &&
                                  drag?.direction == Axis.vertical)
                          ? widget.theme?.resizerColor ??
                              theme.colorScheme.primary
                          : null,
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}


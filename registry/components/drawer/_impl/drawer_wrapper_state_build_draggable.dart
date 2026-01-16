part of '../drawer.dart';

  Widget buildDraggable(BuildContext context, ControlledAnimation? controlled,
      Widget child, ThemeData theme) {
    switch (resolvedPosition) {
      case OverlayPosition.left:
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            if (controlled == null) {
              return;
            }
            final size = getSize(context);
            final increment = details.primaryDelta! / size.width;
            double newValue = controlled.value + increment;
            if (newValue < 0) {
              newValue = 0;
            }
            if (newValue > 1) {
              _extraOffset.value +=
                  details.primaryDelta! / max(_extraOffset.value, 1);
              newValue = 1;
            }
            controlled.value = newValue;
          },
          onHorizontalDragEnd: (details) {
            if (controlled == null) {
              return;
            }
            _extraOffset.forward(0, Curves.easeOut);
            if (controlled.value + _extraOffset.value < 0.5) {
              controlled.forward(0, Curves.easeOut).then((value) {
                closeDrawer(context);
              });
            } else {
              controlled.forward(1, Curves.easeOut);
            }
          },
          child: Row(
            textDirection: TextDirection.ltr,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                  animation: _extraOffset,
                  builder: (context, child) {
                    return Gap(
                        widget.extraSize.width + _extraOffset.value.max(0));
                  }),
              Flexible(
                child: AnimatedBuilder(
                  builder: (context, child) {
                    return Transform.scale(
                        scaleX:
                            1 + _extraOffset.value / getSize(context).width / 4,
                        alignment: Alignment.centerRight,
                        child: child);
                  },
                  animation: _extraOffset,
                  child: child,
                ),
              ),
              if (widget.showDragHandle) ...[
                Gap(widget.gapAfterDragger ?? 16 * theme.scaling),
                buildDraggableBar(theme),
                Gap(widget.gapBeforeDragger ?? 12 * theme.scaling),
              ],
            ],
          ),
        );
      case OverlayPosition.right:
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            if (controlled == null) {
              return;
            }
            final size = getSize(context);
            final increment = details.primaryDelta! / size.width;
            double newValue = controlled.value - increment;
            if (newValue < 0) {
              newValue = 0;
            }
            if (newValue > 1) {
              _extraOffset.value +=
                  -details.primaryDelta! / max(_extraOffset.value, 1);
              newValue = 1;
            }
            controlled.value = newValue;
          },
          onHorizontalDragEnd: (details) {
            if (controlled == null) {
              return;
            }
            _extraOffset.forward(0, Curves.easeOut);
            if (controlled.value + _extraOffset.value < 0.5) {
              controlled.forward(0, Curves.easeOut).then((value) {
                closeDrawer(context);
              });
            } else {
              controlled.forward(1, Curves.easeOut);
            }
          },
          child: Row(
            textDirection: TextDirection.ltr,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDragHandle) ...[
                Gap(widget.gapBeforeDragger ?? 12 * theme.scaling),
                buildDraggableBar(theme),
                Gap(widget.gapAfterDragger ?? 16 * theme.scaling),
              ],
              Flexible(
                child: AnimatedBuilder(
                  builder: (context, child) {
                    return Transform.scale(
                        scaleX:
                            1 + _extraOffset.value / getSize(context).width / 4,
                        alignment: Alignment.centerLeft,
                        child: child);
                  },
                  animation: _extraOffset,
                  child: child,
                ),
              ),
              AnimatedBuilder(
                  animation: _extraOffset,
                  builder: (context, child) {
                    return Gap(
                        widget.extraSize.width + _extraOffset.value.max(0));
                  }),
            ],
          ),
        );
      case OverlayPosition.top:
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: (details) {
            if (controlled == null) {
              return;
            }
            final size = getSize(context);
            final increment = details.primaryDelta! / size.height;
            double newValue = controlled.value + increment;
            if (newValue < 0) {
              newValue = 0;
            }
            if (newValue > 1) {
              _extraOffset.value +=
                  details.primaryDelta! / max(_extraOffset.value, 1);
              newValue = 1;
            }
            controlled.value = newValue;
          },
          onVerticalDragEnd: (details) {
            if (controlled == null) {
              return;
            }
            _extraOffset.forward(0, Curves.easeOut);
            if (controlled.value + _extraOffset.value < 0.5) {
              controlled.forward(0, Curves.easeOut).then((value) {
                closeDrawer(context);
              });
            } else {
              controlled.forward(1, Curves.easeOut);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                  animation: _extraOffset,
                  builder: (context, child) {
                    return Gap(
                        widget.extraSize.height + _extraOffset.value.max(0));
                  }),
              Flexible(
                child: AnimatedBuilder(
                  builder: (context, child) {
                    return Transform.scale(
                        scaleY: 1 +
                            _extraOffset.value / getSize(context).height / 4,
                        alignment: Alignment.bottomCenter,
                        child: child);
                  },
                  animation: _extraOffset,
                  child: child,
                ),
              ),
              if (widget.showDragHandle) ...[
                Gap(widget.gapAfterDragger ?? 16 * theme.scaling),
                buildDraggableBar(theme),
                Gap(widget.gapBeforeDragger ?? 12 * theme.scaling),
              ],
            ],
          ),
        );
      case OverlayPosition.bottom:
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: (details) {
            if (controlled == null) {
              return;
            }
            final size = getSize(context);
            final increment = details.primaryDelta! / size.height;
            double newValue = controlled.value - increment;
            if (newValue < 0) {
              newValue = 0;
            }
            if (newValue > 1) {
              _extraOffset.value +=
                  -details.primaryDelta! / max(_extraOffset.value, 1);
              newValue = 1;
            }
            controlled.value = newValue;
          },
          onVerticalDragEnd: (details) {
            if (controlled == null) {
              return;
            }
            _extraOffset.forward(0, Curves.easeOut);
            if (controlled.value + _extraOffset.value < 0.5) {
              controlled.forward(0, Curves.easeOut).then((value) {
                closeDrawer(context);
              });
            } else {
              controlled.forward(1, Curves.easeOut);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDragHandle) ...[
                Gap(widget.gapBeforeDragger ?? 12 * theme.scaling),
                buildDraggableBar(theme),
                Gap(widget.gapAfterDragger ?? 16 * theme.scaling),
              ],
              Flexible(
                child: AnimatedBuilder(
                  builder: (context, child) {
                    return Transform.scale(
                        scaleY: 1 +
                            _extraOffset.value / getSize(context).height / 4,
                        alignment: Alignment.topCenter,
                        child: child);
                  },
                  animation: _extraOffset,
                  child: child,
                ),
              ),
              AnimatedBuilder(
                  animation: _extraOffset,
                  builder: (context, child) {
                    return Gap(
                        widget.extraSize.height + _extraOffset.value.max(0));
                  }),
            ],
          ),
        );
      default:
        throw UnimplementedError('Unknown position');
    }
  }

  @override

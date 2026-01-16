part of '../dialog.dart';

/// A modal dialog component for displaying important alerts and confirmations.
///
/// AlertDialog provides a focused overlay interface for critical user
/// interactions that require immediate attention or confirmation. Built on top
/// of [ModalBackdrop] and [ModalContainer], it ensures proper accessibility and
/// visual hierarchy.
///
/// Example:
/// ```dart
/// AlertDialog(
///   title: Text('Delete Item'),
///   content: Text('Are you sure you want to delete this item?'),
///   actions: [
///     Button.ghost(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
///     Button.destructive(onPressed: _deleteItem, child: Text('Delete')),
///   ],
/// );
/// ```
class AlertDialog extends StatefulWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final double? surfaceBlur;
  final double? surfaceOpacity;
  final Color? barrierColor;
  final EdgeInsetsGeometry? padding;

  const AlertDialog({
    super.key,
    this.leading,
    this.title,
    this.content,
    this.actions,
    this.trailing,
    this.surfaceBlur,
    this.surfaceOpacity,
    this.barrierColor,
    this.padding,
  });

  @override
  State<AlertDialog> createState() => _AlertDialogState();
}

class _AlertDialogState extends State<AlertDialog> {
  Widget _wrapIcon(ThemeData theme, Widget icon) {
    return IconTheme(
      data: theme.iconTheme.xLarge
          .copyWith(color: theme.colorScheme.mutedForeground),
      child: icon,
    );
  }

  Widget _wrapTitle(ThemeData theme, Widget title) {
    final style = theme.typography.large.merge(theme.typography.semiBold);
    return DefaultTextStyle.merge(style: style, child: title);
  }

  Widget _wrapContent(ThemeData theme, Widget content) {
    final style = theme.typography.small
        .copyWith(color: theme.colorScheme.mutedForeground);
    return DefaultTextStyle.merge(style: style, child: content);
  }

  List<Widget> _buildHeaderRow(ThemeData theme, double spacing) {
    final children = <Widget>[];
    if (widget.leading != null) {
      children.add(_wrapIcon(theme, widget.leading!));
    }
    if (widget.title != null || widget.content != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: spacing));
      }
      final columnChildren = <Widget>[];
      if (widget.title != null) {
        columnChildren.add(_wrapTitle(theme, widget.title!));
      }
      if (widget.title != null && widget.content != null) {
        columnChildren.add(SizedBox(height: 8 * theme.scaling));
      }
      if (widget.content != null) {
        columnChildren.add(_wrapContent(theme, widget.content!));
      }
      children.add(
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columnChildren,
          ),
        ),
      );
    }
    if (widget.trailing != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: spacing));
      }
      children.add(_wrapIcon(theme, widget.trailing!));
    }
    return children;
  }

  List<Widget> _buildActions(double spacing) {
    final actions = widget.actions ?? const [];
    if (actions.isEmpty) {
      return const [];
    }
    final widgets = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      if (i > 0) {
        widgets.add(SizedBox(width: spacing));
      }
      widgets.add(actions[i]);
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final scaling = themeData.scaling;
    final headerChildren = _buildHeaderRow(themeData, 16 * scaling);
    final actionChildren = _buildActions(8 * scaling);

    return ModalBackdrop(
      borderRadius: themeData.borderRadiusXxl,
      barrierColor: widget.barrierColor ?? Colors.black.withValues(alpha: 0.8),
      surfaceClip: ModalBackdrop.shouldClipSurface(
        widget.surfaceOpacity ?? themeData.surfaceOpacity,
      ),
      child: ModalContainer(
        fillColor: themeData.colorScheme.popover,
        filled: true,
        borderRadius: themeData.borderRadiusXxl,
        borderWidth: 1 * scaling,
        borderColor: themeData.colorScheme.muted,
        padding: widget.padding ?? EdgeInsets.all(24 * scaling),
        surfaceBlur: widget.surfaceBlur ?? themeData.surfaceBlur,
        surfaceOpacity: widget.surfaceOpacity ?? themeData.surfaceOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (headerChildren.isNotEmpty)
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: headerChildren,
                ),
              ),
            if (headerChildren.isNotEmpty && actionChildren.isNotEmpty)
              SizedBox(height: 16 * scaling),
            if (actionChildren.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: actionChildren,
              ),
          ],
        ),
      ),
    );
  }
}

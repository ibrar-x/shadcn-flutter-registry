part of '../menu.dart';

class MenuDivider extends StatelessWidget implements MenuItem {
  /// Creates a menu divider.
  const MenuDivider({super.key});
  @override
  Widget build(BuildContext context) {
    final menuGroupData = Data.maybeOf<MenuGroupData>(context);
    final theme = Theme.of(context);
    final scaling = theme.scaling;
    return AnimatedPadding(
      duration: kDefaultDuration,
      padding:
          (menuGroupData == null || menuGroupData.direction == Axis.vertical
                  ? const EdgeInsets.symmetric(vertical: 4)
                  : const EdgeInsets.symmetric(horizontal: 4)) *
              scaling,
      child: menuGroupData == null || menuGroupData.direction == Axis.vertical
          ? Divider(
              height: 1 * scaling,
              thickness: 1 * scaling,
              indent: -4 * scaling,
              endIndent: -4 * scaling,
              color: theme.colorScheme.border,
            )
          : VerticalDivider(
              width: 1 * scaling,
              thickness: 1 * scaling,
              color: theme.colorScheme.border,
              indent: -4 * scaling,
              endIndent: -4 * scaling,
            ),
    );
  }

  @override
  bool get hasLeading => false;

  @override
  PopoverController? get popoverController => null;
}

/// Spacing gap between menu items.
///
/// Creates empty vertical or horizontal space within a menu, based on
/// the menu's direction. Useful for visually grouping related items.

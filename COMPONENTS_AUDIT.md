# Components Audit

Total component files: 120.
Files over 600 LOC: 51 (must split during refactor).

## Largest Files (Over 600 LOC)

- `control/button.dart` (6397 LOC)
- `layout/table.dart` (3340 LOC)
- `form/form.dart` (3262 LOC)
- `form/text_field.dart` (2867 LOC)
- `layout/window.dart` (2861 LOC)
- `layout/tree.dart` (2544 LOC)
- `overlay/drawer.dart` (2282 LOC)
- `form/select.dart` (2277 LOC)
- `navigation/navigation_bar.dart` (2266 LOC)
- `display/calendar.dart` (2061 LOC)
- `layout/resizable.dart` (1779 LOC)
- `layout/sortable.dart` (1774 LOC)
- `overlay/popover.dart` (1699 LOC)
- `layout/stepper.dart` (1468 LOC)
- `form/slider.dart` (1402 LOC)
- `menu/menu.dart` (1342 LOC)
- `display/chat.dart` (1335 LOC)
- `form/formatted_input.dart` (1297 LOC)
- `overlay/toast.dart` (1227 LOC)
- `overlay/dialog.dart` (1156 LOC)
- `layout/scaffold.dart` (1104 LOC)
- `text/text.dart` (1068 LOC)
- `display/avatar.dart` (1058 LOC)
- `form/object_input.dart` (1051 LOC)
- `form/color/color.dart` (1047 LOC)
- `display/carousel.dart` (1042 LOC)
- `form/color/solid/color_picker.dart` (1017 LOC)
- `form/input_otp.dart` (982 LOC)
- `control/clickable.dart` (968 LOC)
- `form/input.dart` (968 LOC)
- `form/time_picker.dart` (938 LOC)
- `form/radio_group.dart` (901 LOC)
- `form/checkbox.dart` (870 LOC)
- `menu/navigation_menu.dart` (829 LOC)
- `form/color/solid/slider/hsv.dart` (821 LOC)
- `form/item_picker.dart` (816 LOC)
- `form/color/solid/slider/hsl.dart` (810 LOC)
- `layout/outlined_container.dart` (772 LOC)
- `menu/context_menu.dart` (771 LOC)
- `overlay/refresh_trigger.dart` (770 LOC)
- `locale/shadcn_localizations.dart` (758 LOC)
- `form/chip_input.dart` (754 LOC)
- `form/star_rating.dart` (724 LOC)
- `layout/accordion.dart` (696 LOC)
- `control/command.dart` (665 LOC)
- `navigation/subfocus.dart` (651 LOC)
- `overlay/swiper.dart` (643 LOC)
- `navigation/tabs/tab_pane.dart` (642 LOC)
- `form/color/solid/color_input.dart` (633 LOC)
- `layout/overflow_marquee.dart` (624 LOC)
- `overlay/tooltip.dart` (613 LOC)

## Potential Duplication Hotspots

- Overlay patterns appear across `overlay/*` (popover, dialog, drawer, tooltip, toast); expect shared overlay positioning, focus/keyboard handling, and animation helpers.
- Form inputs in `form/*` share validation, formatting, and controller patterns (text_field, input, formatted_input, select, date/time pickers).
- Navigation and tabs (`navigation/*`) likely duplicate selection/state and focus handling.
- Layout containers (`layout/*`) show repeated sizing/scrolling logic (table, tree, resizable, sortable).

## Component Inventory

| Component Path | LOC | Internal Deps | Notes |
| --- | ---: | --- | --- |
| `async.dart` | 118 | - |  |
| `chart/tracker.dart` | 376 | - |  |
| `control/button.dart` | 6397 | - | split (>600 LOC) |
| `control/clickable.dart` | 968 | - | split (>600 LOC) |
| `control/command.dart` | 665 | - | split (>600 LOC) |
| `control/hover.dart` | 382 | - |  |
| `control/scrollbar.dart` | 270 | - |  |
| `control/scrollview.dart` | 172 | - |  |
| `debug.dart` | 82 | - |  |
| `display/avatar.dart` | 1058 | - | split (>600 LOC) |
| `display/badge.dart` | 328 | - |  |
| `display/calendar.dart` | 2061 | - | split (>600 LOC) |
| `display/carousel.dart` | 1042 | - | split (>600 LOC) |
| `display/chat.dart` | 1335 | - | split (>600 LOC) |
| `display/chip.dart` | 213 | - |  |
| `display/circular_progress_indicator.dart` | 277 | - |  |
| `display/code_snippet.dart` | 380 | - |  |
| `display/divider.dart` | 538 | - |  |
| `display/dot_indicator.dart` | 428 | - |  |
| `display/fade_scroll.dart` | 187 | - |  |
| `display/keyboard_shortcut.dart` | 393 | - |  |
| `display/linear_progress_indicator.dart` | 568 | - |  |
| `display/number_ticker.dart` | 313 | - |  |
| `display/progress.dart` | 226 | - |  |
| `display/skeleton.dart` | 358 | - |  |
| `display/spinner.dart` | 88 | - |  |
| `form/autocomplete.dart` | 530 | - |  |
| `form/checkbox.dart` | 870 | - | split (>600 LOC) |
| `form/chip_input.dart` | 754 | - | split (>600 LOC) |
| `form/color/color.dart` | 1047 | - | split (>600 LOC) |
| `form/color/solid/color_input.dart` | 633 | - | split (>600 LOC) |
| `form/color/solid/color_picker.dart` | 1017 | - | split (>600 LOC) |
| `form/color/solid/eye_dropper.dart` | 535 | - |  |
| `form/color/solid/history.dart` | 335 | - |  |
| `form/color/solid/slider/alpha.dart` | 48 | - |  |
| `form/color/solid/slider/hsl.dart` | 810 | - | split (>600 LOC) |
| `form/color/solid/slider/hsv.dart` | 821 | - | split (>600 LOC) |
| `form/control.dart` | 267 | - |  |
| `form/date_picker.dart` | 552 | - |  |
| `form/file_input.dart` | 167 | - |  |
| `form/file_picker.dart` | 146 | - |  |
| `form/form.dart` | 3262 | - | split (>600 LOC) |
| `form/form_field.dart` | 523 | - |  |
| `form/formatted_input.dart` | 1297 | - | split (>600 LOC) |
| `form/formatter.dart` | 344 | - |  |
| `form/image.dart` | 1 | - |  |
| `form/input.dart` | 968 | - | split (>600 LOC) |
| `form/input_otp.dart` | 982 | - | split (>600 LOC) |
| `form/item_picker.dart` | 816 | - | split (>600 LOC) |
| `form/multiple_choice.dart` | 549 | - |  |
| `form/object_input.dart` | 1051 | - | split (>600 LOC) |
| `form/phone_input.dart` | 520 | - |  |
| `form/radio_group.dart` | 901 | - | split (>600 LOC) |
| `form/select.dart` | 2277 | components/control | split (>600 LOC) |
| `form/slider.dart` | 1402 | - | split (>600 LOC) |
| `form/sortable.dart` | 364 | - |  |
| `form/star_rating.dart` | 724 | - | split (>600 LOC) |
| `form/switch.dart` | 475 | - |  |
| `form/text_area.dart` | 330 | - |  |
| `form/text_field.dart` | 2867 | components/layout | split (>600 LOC) |
| `form/time_picker.dart` | 938 | - | split (>600 LOC) |
| `form/validated.dart` | 81 | - |  |
| `icon/icon.dart` | 215 | - |  |
| `icon/triple_dots.dart` | 111 | - |  |
| `layout/accordion.dart` | 696 | - | split (>600 LOC) |
| `layout/alert.dart` | 245 | - |  |
| `layout/basic.dart` | 520 | - |  |
| `layout/breadcrumb.dart` | 190 | - |  |
| `layout/card.dart` | 461 | - |  |
| `layout/card_image.dart` | 335 | - |  |
| `layout/collapsible.dart` | 499 | - |  |
| `layout/dialog/alert_dialog.dart` | 198 | - |  |
| `layout/focus_outline.dart` | 205 | - |  |
| `layout/group.dart` | 312 | - |  |
| `layout/hidden.dart` | 447 | - |  |
| `layout/media_query.dart` | 115 | - |  |
| `layout/outlined_container.dart` | 772 | - | split (>600 LOC) |
| `layout/overflow_marquee.dart` | 624 | - | split (>600 LOC) |
| `layout/resizable.dart` | 1779 | - | split (>600 LOC) |
| `layout/scaffold.dart` | 1104 | - | split (>600 LOC) |
| `layout/scrollable_client.dart` | 396 | - |  |
| `layout/sortable.dart` | 1774 | - | split (>600 LOC) |
| `layout/stage_container.dart` | 270 | - |  |
| `layout/stepper.dart` | 1468 | - | split (>600 LOC) |
| `layout/steps.dart` | 232 | - |  |
| `layout/table.dart` | 3340 | - | split (>600 LOC) |
| `layout/timeline.dart` | 367 | - |  |
| `layout/tree.dart` | 2544 | - | split (>600 LOC) |
| `layout/window.dart` | 2861 | components/layout, components/patch.dart | split (>600 LOC) |
| `locale/locale_utils.dart` | 211 | - |  |
| `locale/shadcn_localizations.dart` | 758 | - | split (>600 LOC) |
| `locale/shadcn_localizations_en.dart` | 376 | - |  |
| `locale/shadcn_localizations_extensions.dart` | 277 | - |  |
| `menu/context_menu.dart` | 771 | - | split (>600 LOC) |
| `menu/dropdown_menu.dart` | 284 | - |  |
| `menu/menu.dart` | 1342 | - | split (>600 LOC) |
| `menu/menubar.dart` | 313 | - |  |
| `menu/navigation_menu.dart` | 829 | - | split (>600 LOC) |
| `menu/popup.dart` | 231 | - |  |
| `navigation/navigation_bar.dart` | 2266 | components/layout | split (>600 LOC) |
| `navigation/pagination.dart` | 337 | - |  |
| `navigation/subfocus.dart` | 651 | - | split (>600 LOC) |
| `navigation/switcher.dart` | 379 | - |  |
| `navigation/tabs/tab_container.dart` | 338 | - |  |
| `navigation/tabs/tab_list.dart` | 267 | - |  |
| `navigation/tabs/tab_pane.dart` | 642 | components/display | split (>600 LOC) |
| `navigation/tabs/tabs.dart` | 262 | - |  |
| `overlay/dialog.dart` | 1156 | - | split (>600 LOC) |
| `overlay/drawer.dart` | 2282 | - | split (>600 LOC) |
| `overlay/hover_card.dart` | 352 | - |  |
| `overlay/overlay.dart` | 566 | - |  |
| `overlay/popover.dart` | 1699 | - | split (>600 LOC) |
| `overlay/refresh_trigger.dart` | 770 | - | split (>600 LOC) |
| `overlay/swiper.dart` | 643 | - | split (>600 LOC) |
| `overlay/toast.dart` | 1227 | - | split (>600 LOC) |
| `overlay/tooltip.dart` | 613 | components/control | split (>600 LOC) |
| `patch.dart` | 141 | - |  |
| `text/selectable.dart` | 541 | - |  |
| `text/text.dart` | 1068 | - | split (>600 LOC) |
| `wrapper.dart` | 91 | - |  |

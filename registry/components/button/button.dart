library shadcn_button;

import 'dart:math';

import 'package:data_widget/data_widget.dart';
import 'package:data_widget/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';

import '../../shared/primitives/clickable.dart';
import '../../shared/primitives/form_control.dart';
import '../../shared/primitives/form_value_supplier.dart';
import '../../shared/primitives/menu_group.dart';
import '../../shared/theme/color_scheme.dart';
import '../../shared/theme/generated_colors.dart';
import '../../shared/theme/theme.dart';
import '../../shared/theme/typography.dart';
import '../../shared/utils/color_extensions.dart';

part '_impl/toggle_controller.dart';
part '_impl/toggle.dart';
part '_impl/selected_button.dart';
part '_impl/button_core.dart';
part '_impl/button_style.dart';
part '_impl/button_theme.dart';
part '_impl/button_variance.dart';
part '_impl/button_helpers.dart';
part '_impl/button_variants.dart';
part '_impl/button_icon.dart';
part '_impl/button_overrides.dart';
part '_impl/button_group.dart';

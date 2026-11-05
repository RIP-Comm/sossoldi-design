import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';

/// The headline row of the M and L Dashboard widgets: the title at the left
/// and, at the right, the chip that chooses the type (a
/// [DashboardTypeSelector]).
class DashboardWidgetHeader extends StatelessWidget {
  const DashboardWidgetHeader({
    super.key,
    required this.title,
    required this.selector,
  });

  final String title;
  final Widget selector;

  static const double height = 24;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.labelBoldLarge.copyWith(
                color: context.colors.textHigh,
              ),
            ),
          ),
          selector,
        ],
      ),
    );
  }
}

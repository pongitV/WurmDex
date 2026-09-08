import 'package:flutter/material.dart';
import '../utils/card_condition_helper.dart';

class ConditionBadge extends StatelessWidget {
  final String condition;
  final bool compact;
  final VoidCallback? onTap;

  const ConditionBadge({
    super.key,
    required this.condition,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final short = CardConditionHelper.getShortCondition(condition);
    final color = CardConditionHelper.getConditionColor(short);
    final isGraded = short.toUpperCase().contains('GRADUADA');

    final badgeWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4.5 : 7.0,
        vertical: compact ? 1.0 : 2.5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(compact ? 4.0 : 6.0),
        border: Border.all(
          color: color.withValues(alpha: 0.75),
          width: compact ? 0.7 : 1.0,
        ),
        boxShadow: isGraded
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isGraded) ...[
            Icon(
              Icons.workspace_premium,
              size: compact ? 9 : 12,
              color: color,
            ),
            SizedBox(width: compact ? 2 : 4),
          ],
          Text(
            short,
            style: TextStyle(
              fontSize: compact ? 8.5 : 10.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 4.0 : 6.0),
        child: badgeWidget,
      );
    }

    return badgeWidget;
  }
}

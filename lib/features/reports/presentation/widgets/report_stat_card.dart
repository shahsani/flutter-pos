import 'package:flutter/material.dart';

class ReportStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const ReportStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isTablet ? 20.0 : 8.0;
    final iconSize = isTablet ? 20.0 : 16.0;
    final titleFontSize = isTablet ? 14.0 : 12.0;
    final valueStyle = isTablet
        ? Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.9),
          )
        : Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.9),
          );

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.05), // Subtle tint
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        side: BorderSide(color: color.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: titleFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: iconSize, color: color),
              ],
            ),
            SizedBox(height: isTablet ? 12 : 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: valueStyle),
            ),
          ],
        ),
      ),
    );
  }
}

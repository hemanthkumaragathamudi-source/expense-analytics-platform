import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/dashboard.dart';

class InsightCard extends StatelessWidget {
  final DashboardInsight insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    if (insight.type == 'none' || insight.description == null || insight.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.grey.shade800),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (insight.title != null && insight.title!.isNotEmpty)
                    Text(
                      insight.title!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  if (insight.title != null && insight.title!.isNotEmpty)
                    const SizedBox(height: AppSpacing.xs),
                  Text(
                    insight.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

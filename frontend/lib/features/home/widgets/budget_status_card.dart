import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/dashboard.dart';

class BudgetStatusCard extends StatelessWidget {
  final DashboardBudget budget;

  const BudgetStatusCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Budget', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '\$${budget.totalBudget.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'IBM Plex Mono',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '\$${budget.totalExpenses.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'IBM Plex Mono',
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.isOverBudget ? 'Over Budget By' : 'Remaining',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: budget.isOverBudget ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
                Text(
                  '\$${budget.remaining.abs().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontFamily: 'IBM Plex Mono',
                    color: budget.isOverBudget ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: budget.percentageUsed / 100.0,
              backgroundColor: Colors.grey.shade300,
              color: budget.isOverBudget ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${budget.percentageUsed.toStringAsFixed(1)}% Used',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

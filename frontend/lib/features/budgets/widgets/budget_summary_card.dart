import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../home/models/dashboard.dart';

class BudgetSummaryCard extends StatelessWidget {
  final DashboardBudget? budgetSummary;

  const BudgetSummaryCard({super.key, this.budgetSummary});

  @override
  Widget build(BuildContext context) {
    if (budgetSummary == null) {
      return const SizedBox.shrink();
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final theme = Theme.of(context);
    final isOverBudget = budgetSummary!.isOverBudget;

    // We only care about displaying total budget, spending, and remaining here.
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryItem(
                  label: 'Total Budget',
                  amount: currencyFormat.format(budgetSummary!.totalBudget),
                  color: theme.colorScheme.onSurface,
                ),
                _SummaryItem(
                  label: 'Total Spending',
                  amount: currencyFormat.format(budgetSummary!.totalExpenses),
                  color: isOverBudget ? theme.colorScheme.error : theme.colorScheme.onSurface,
                ),
                _SummaryItem(
                  label: 'Remaining',
                  amount: currencyFormat.format(budgetSummary!.remaining.abs()),
                  color: isOverBudget ? theme.colorScheme.error : theme.colorScheme.primary,
                  subLabel: isOverBudget ? 'Over' : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final String? subLabel;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              amount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'IBM Plex Mono',
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                subLabel!,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

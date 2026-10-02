import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/budget.dart';
import '../../transactions/models/category.dart';
import '../../home/models/dashboard.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final Category? category;
  final CategorySpending? categorySpending;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    this.category,
    this.categorySpending,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    final categoryName = category?.name ?? 'Unknown Category';
    final amountSpent = categorySpending?.amount ?? 0.0;
    final remaining = budget.amount - amountSpent;
    final isOverBudget = remaining < 0;

    double progress = budget.amount > 0 ? (amountSpent / budget.amount) : 0;
    if (progress > 1.0) progress = 1.0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget: ${currencyFormat.format(budget.amount)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'IBM Plex Mono',
                  ),
                ),
                Text(
                  'Spent: ${currencyFormat.format(amountSpent)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'IBM Plex Mono',
                    color: isOverBudget ? theme.colorScheme.error : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: isOverBudget ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isOverBudget
                  ? '${currencyFormat.format(remaining.abs())} Over Budget'
                  : '${currencyFormat.format(remaining)} Remaining',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOverBudget ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

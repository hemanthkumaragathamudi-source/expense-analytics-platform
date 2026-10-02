import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final String categoryName;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.categoryName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.transactionType.toUpperCase() == 'INCOME';
    final amountColor = isIncome ? Colors.green.shade700 : null;
    final sign = isIncome ? '+' : '-';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.grey.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (transaction.description != null && transaction.description!.isNotEmpty)
                    Text(
                      transaction.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign\$${transaction.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'IBM Plex Mono',
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
                Text(
                  DateFormat('MMM d, y').format(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

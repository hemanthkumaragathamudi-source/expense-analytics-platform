import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/dashboard.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<DashboardRecentTransaction> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Center(
            child: Text(
              'No recent transactions.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...transactions.take(5).map((tx) => _buildTransactionRow(tx, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(DashboardRecentTransaction tx, BuildContext context) {
    final isIncome = tx.transactionType.toUpperCase() == 'INCOME';
    final amountColor = isIncome ? Colors.green.shade700 : null;
    final sign = isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.grey.shade700,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.categoryName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tx.description != null && tx.description!.isNotEmpty)
                  Text(
                    tx.description!,
                    style: Theme.of(context).textTheme.bodySmall,
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
                '$sign\$${tx.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'IBM Plex Mono',
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              Text(
                DateFormat('MMM d, y').format(tx.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

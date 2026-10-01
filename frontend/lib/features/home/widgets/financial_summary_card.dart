import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/dashboard.dart';

class FinancialSummaryCard extends StatelessWidget {
  final DashboardSummary summary;

  const FinancialSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          children: [
            _buildRow('Balance', summary.balance, context, isBold: true),
            const Divider(height: AppSpacing.xl),
            _buildRow('Income', summary.income, context),
            const SizedBox(height: AppSpacing.sm),
            _buildRow('Expenses', summary.expenses, context),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transactions', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '${summary.transactionCount}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'IBM Plex Mono',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount, BuildContext context, {bool isBold = false}) {
    final textStyle = isBold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    final monoStyle = isBold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'IBM Plex Mono')
        : Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'IBM Plex Mono');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: monoStyle,
        ),
      ],
    );
  }
}

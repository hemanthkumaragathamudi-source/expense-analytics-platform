import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_spacing.dart';
import '../../home/models/dashboard.dart';
import 'package:intl/intl.dart';

class AnalyticsSpendingBreakdown extends StatelessWidget {
  final List<CategorySpending> spending;

  const AnalyticsSpendingBreakdown({super.key, required this.spending});

  @override
  Widget build(BuildContext context) {
    if (spending.isEmpty) {
      return Card(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Center(
            child: Text(
              'No spending data for this month.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final colors = [
      Colors.grey.shade900,
      Colors.grey.shade800,
      Colors.grey.shade700,
      Colors.grey.shade600,
      Colors.grey.shade500,
      Colors.grey.shade400,
    ];

    final sortedSpending = List<CategorySpending>.from(spending)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: sortedSpending.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: data.percentage,
                          title: '',
                          radius: 30,
                        );
                      }).toList(),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Expenses',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Text('Category Details', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.md),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedSpending.length,
              itemBuilder: (context, index) {
                final data = sortedSpending[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          data.categoryName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(data.amount),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'IBM Plex Mono',
                            ),
                          ),
                          Text(
                            '${data.percentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

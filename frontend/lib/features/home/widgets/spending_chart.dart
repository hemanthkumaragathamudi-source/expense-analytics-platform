import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/dashboard.dart';
import 'package:intl/intl.dart';

class SpendingChart extends StatelessWidget {
  final List<CategorySpending> spending;

  const SpendingChart({super.key, required this.spending});

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
            Text('Spending by Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: sortedSpending.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          return PieChartSectionData(
                            color: colors[index % colors.length],
                            value: data.percentage,
                            title: '',
                            radius: 20,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedSpending.length,
                      itemBuilder: (context, index) {
                        final data = sortedSpending[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: colors[index % colors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${data.categoryName} — ${currencyFormatter.format(data.amount)} — ${data.percentage.toStringAsFixed(2)}%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'IBM Plex Mono',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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

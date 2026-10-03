import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_spacing.dart';
import 'states/analytics_state.dart';
import 'widgets/analytics_spending_breakdown.dart';
import '../home/widgets/financial_summary_card.dart';
import '../home/widgets/budget_status_card.dart';
import '../home/widgets/insight_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final AnalyticsState _analyticsState;

  @override
  void initState() {
    super.initState();
    _analyticsState = AnalyticsState();
    _analyticsState.loadData();
  }

  @override
  void dispose() {
    _analyticsState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: _analyticsState,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: _analyticsState.loadData,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: AppSpacing.paddingLg,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMonthSelector(context),
                      const SizedBox(height: AppSpacing.lg),
                      if (_analyticsState.isLoading && _analyticsState.analyticsData == null)
                        const Center(child: CircularProgressIndicator())
                      else if (_analyticsState.error != null && _analyticsState.analyticsData == null)
                        Center(
                          child: Column(
                            children: [
                              Text('Failed to load data', style: Theme.of(context).textTheme.bodyLarge),
                              TextButton(
                                onPressed: _analyticsState.loadData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else if (_analyticsState.analyticsData != null) ...[
                        FinancialSummaryCard(summary: _analyticsState.analyticsData!.summary),
                        const SizedBox(height: AppSpacing.lg),
                        AnalyticsSpendingBreakdown(spending: _analyticsState.analyticsData!.spendingByCategory),
                        const SizedBox(height: AppSpacing.lg),
                        BudgetStatusCard(budget: _analyticsState.analyticsData!.budget),
                        const SizedBox(height: AppSpacing.lg),
                        if (_analyticsState.analyticsData!.insight.type != 'none') ...[
                          InsightCard(insight: _analyticsState.analyticsData!.insight),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ]
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _analyticsState.previousMonth,
        ),
        Text(
          dateFormat.format(_analyticsState.currentMonth),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _analyticsState.canGoToNextMonth ? _analyticsState.nextMonth : null,
        ),
      ],
    );
  }
}

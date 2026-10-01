import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_spacing.dart';
import 'home_state.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/spending_chart.dart';
import 'widgets/budget_status_card.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/insight_card.dart';
import '../auth/auth_state.dart';

class HomeScreen extends StatefulWidget {
  final AuthState? authState;

  const HomeScreen({super.key, this.authState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeState _homeState;

  @override
  void initState() {
    super.initState();
    _homeState = HomeState();
    _homeState.loadDashboard();
  }

  @override
  void dispose() {
    _homeState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: _homeState,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: _homeState.loadDashboard,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: AppSpacing.paddingLg,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(context),
                      const SizedBox(height: AppSpacing.lg),
                      _buildMonthSelector(context),
                      const SizedBox(height: AppSpacing.lg),
                      if (_homeState.isLoading && _homeState.dashboardData == null)
                        const Center(child: CircularProgressIndicator())
                      else if (_homeState.error != null && _homeState.dashboardData == null)
                        Center(
                          child: Column(
                            children: [
                              Text('Failed to load data', style: Theme.of(context).textTheme.bodyLarge),
                              TextButton(
                                onPressed: _homeState.loadDashboard,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else if (_homeState.dashboardData != null) ...[
                        if (_homeState.dashboardData!.insight.type != 'none') ...[
                          InsightCard(insight: _homeState.dashboardData!.insight),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        FinancialSummaryCard(summary: _homeState.dashboardData!.summary),
                        const SizedBox(height: AppSpacing.lg),
                        SpendingChart(spending: _homeState.dashboardData!.spendingByCategory),
                        const SizedBox(height: AppSpacing.lg),
                        BudgetStatusCard(budget: _homeState.dashboardData!.budget),
                        const SizedBox(height: AppSpacing.lg),
                        RecentTransactionsList(transactions: _homeState.dashboardData!.recentTransactions),
                        const SizedBox(height: AppSpacing.xxl), // padding at the bottom
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

  Widget _buildHeader(BuildContext context) {
    final username = widget.authState?.user?.username;
    final displayName = (username != null && username.isNotEmpty) ? username : 'there';

    return Text(
      'Hello, $displayName',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _homeState.previousMonth,
        ),
        Text(
          dateFormat.format(_homeState.currentMonth),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _homeState.canGoToNextMonth ? _homeState.nextMonth : null,
        ),
      ],
    );
  }
}

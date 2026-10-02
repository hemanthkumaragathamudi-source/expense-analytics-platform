import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_spacing.dart';
import 'states/budgets_state.dart';
import 'models/budget.dart';
import 'widgets/budget_card.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/budget_form_modal.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  late final BudgetsState _budgetsState;

  @override
  void initState() {
    super.initState();
    _budgetsState = BudgetsState();
    _budgetsState.loadData();
  }

  @override
  void dispose() {
    _budgetsState.dispose();
    super.dispose();
  }

  void _showBudgetForm([Budget? budget]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
      ),
      builder: (context) {
        return BudgetFormModal(
          budget: budget,
          categories: _budgetsState.categories,
          currentMonth: _budgetsState.currentMonth,
          onSave: (categoryId, amount, month, year) async {
            if (budget == null) {
              await _budgetsState.addBudget(
                categoryId: categoryId,
                amount: amount,
                month: month,
                year: year,
              );
            } else {
              await _budgetsState.editBudget(
                budget.id,
                categoryId: categoryId,
                amount: amount,
                month: month,
                year: year,
              );
            }
          },
        );
      },
    );
  }

  void _confirmDelete(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _budgetsState.deleteBudget(budget.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: _budgetsState,
        builder: (context, _) {
          if (_budgetsState.isLoading && _budgetsState.budgets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_budgetsState.error != null && _budgetsState.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load budgets', style: theme.textTheme.bodyLarge),
                  TextButton(
                    onPressed: _budgetsState.loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final currentBudgets = _budgetsState.currentMonthBudgets;
          final dashboardData = _budgetsState.dashboardData;

          return RefreshIndicator(
            onRefresh: _budgetsState.loadData,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: AppSpacing.paddingLg,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMonthSelector(context),
                      const SizedBox(height: AppSpacing.lg),
                      BudgetSummaryCard(budgetSummary: dashboardData?.budget),
                      const SizedBox(height: AppSpacing.lg),
                      if (currentBudgets.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                            child: Text(
                              'No budgets for this month',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        ...currentBudgets.map((budget) {
                          final category = _budgetsState.categories.where((c) => c.id == budget.categoryId).firstOrNull;
                          final spending = dashboardData?.spendingByCategory.where((s) => s.categoryId == budget.categoryId).firstOrNull;
                          return BudgetCard(
                            budget: budget,
                            category: category,
                            categorySpending: spending,
                            onEdit: () => _showBudgetForm(budget),
                            onDelete: () => _confirmDelete(budget),
                          );
                        }),
                      const SizedBox(height: 80), // padding for FAB
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBudgetForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy');
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _budgetsState.previousMonth,
        ),
        Text(
          dateFormat.format(_budgetsState.currentMonth),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _budgetsState.canGoToNextMonth ? _budgetsState.nextMonth : null,
        ),
      ],
    );
  }
}

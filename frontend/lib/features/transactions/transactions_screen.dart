import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import 'states/transactions_state.dart';
import 'widgets/transaction_list_item.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final TransactionsState _transactionsState;

  @override
  void initState() {
    super.initState();
    _transactionsState = TransactionsState();
    _transactionsState.loadData();
  }

  @override
  void dispose() {
    _transactionsState.dispose();
    super.dispose();
  }

  Future<void> _showDeleteConfirmation(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _transactionsState.deleteTransaction(id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _showTransactionOptions(int id) {
    final transaction = _transactionsState.transactions.firstWhere((t) => t.id == id);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                context.push('/transactions/$id/edit', extra: transaction).then((value) {
                  if (value == true) {
                    _transactionsState.loadData();
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: _transactionsState,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: _transactionsState.loadData,
            child: Column(
              children: [
                _buildFilters(context),
                if (_transactionsState.isLoading && _transactionsState.transactions.isEmpty)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (_transactionsState.error != null && _transactionsState.transactions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load data', style: Theme.of(context).textTheme.bodyLarge),
                          TextButton(
                            onPressed: _transactionsState.loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_transactionsState.transactions.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No transactions found.'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80), // space for FAB
                      itemCount: _transactionsState.transactions.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = _transactionsState.transactions[index];
                        final categoryName = _transactionsState.getCategoryName(tx.categoryId);
                        return TransactionListItem(
                          transaction: tx,
                          categoryName: categoryName,
                          onTap: () => _showTransactionOptions(tx.id),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/transactions/add');
          if (result == true) {
            _transactionsState.loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy');

    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _transactionsState.previousMonth,
              ),
              Text(
                dateFormat.format(_transactionsState.currentMonth),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _transactionsState.canGoToNextMonth ? _transactionsState.nextMonth : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<TransactionFilterType>(
            segments: const [
              ButtonSegment(value: TransactionFilterType.all, label: Text('All')),
              ButtonSegment(value: TransactionFilterType.expense, label: Text('Expense')),
              ButtonSegment(value: TransactionFilterType.income, label: Text('Income')),
            ],
            selected: {_transactionsState.filterType},
            onSelectionChanged: (Set<TransactionFilterType> newSelection) {
              _transactionsState.setFilterType(newSelection.first);
            },
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }
}

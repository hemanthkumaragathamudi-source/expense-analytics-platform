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
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _transactionsState = TransactionsState();
    _transactionsState.loadData();
    _searchController = TextEditingController(text: _transactionsState.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          final displayedTransactions = _transactionsState.displayedTransactions;

          return RefreshIndicator(
            onRefresh: _transactionsState.loadData,
            child: Column(
              children: [
                _buildSearch(context),
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
                else if (displayedTransactions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No transactions match your filters.'),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: _transactionsState.clearFilters,
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80), // space for FAB
                      itemCount: displayedTransactions.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = displayedTransactions[index];
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

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingMd,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _transactionsState.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _transactionsState.setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSpacing.md),
        ),
        onChanged: _transactionsState.setSearchQuery,
        controller: _searchController,
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
          Row(
            children: [
              Expanded(
                child: SegmentedButton<TransactionFilterType>(
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
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.filledTonal(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showAdvancedFiltersDialog(context),
              ),
            ],
          ),
          _buildActiveFiltersRow(),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersRow() {
    List<Widget> chips = [];

    if (_transactionsState.selectedCategoryId != null) {
      final categoryName = _transactionsState.getCategoryName(_transactionsState.selectedCategoryId!);
      chips.add(InputChip(
        label: Text('Cat: $categoryName'),
        onDeleted: () => _transactionsState.setCategoryId(null),
      ));
    }

    if (_transactionsState.selectedPaymentMethodId != null) {
      final pmName = _transactionsState.paymentMethods
          .where((p) => p.id == _transactionsState.selectedPaymentMethodId)
          .firstOrNull?.name ?? 'Unknown';
      chips.add(InputChip(
        label: Text('Pay: $pmName'),
        onDeleted: () => _transactionsState.setPaymentMethodId(null),
      ));
    }

    if (_transactionsState.sortOption != TransactionSortOption.newest) {
      String sortLabel;
      switch (_transactionsState.sortOption) {
        case TransactionSortOption.oldest: sortLabel = 'Oldest'; break;
        case TransactionSortOption.amountHighest: sortLabel = 'Highest'; break;
        case TransactionSortOption.amountLowest: sortLabel = 'Lowest'; break;
        default: sortLabel = 'Newest';
      }
      chips.add(InputChip(
        label: Text('Sort: $sortLabel'),
        onDeleted: () => _transactionsState.setSortOption(TransactionSortOption.newest),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        children: chips,
      ),
    );
  }

  void _showAdvancedFiltersDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ListenableBuilder(
          listenable: _transactionsState,
          builder: (context, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filters & Sorting', style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            _transactionsState.clearFilters();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Category', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownMenu<int?>(
                      initialSelection: _transactionsState.selectedCategoryId,
                      onSelected: (value) => _transactionsState.setCategoryId(value),
                      dropdownMenuEntries: [
                        const DropdownMenuEntry(value: null, label: 'All Categories'),
                        ..._transactionsState.categories.map((c) => DropdownMenuEntry(value: c.id, label: c.name)),
                      ],
                      expandedInsets: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Payment Method', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownMenu<int?>(
                      initialSelection: _transactionsState.selectedPaymentMethodId,
                      onSelected: (value) => _transactionsState.setPaymentMethodId(value),
                      dropdownMenuEntries: [
                        const DropdownMenuEntry(value: null, label: 'All Payment Methods'),
                        ..._transactionsState.paymentMethods.map((p) => DropdownMenuEntry(value: p.id, label: p.name)),
                      ],
                      expandedInsets: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownMenu<TransactionSortOption>(
                      initialSelection: _transactionsState.sortOption,
                      onSelected: (value) {
                        if (value != null) _transactionsState.setSortOption(value);
                      },
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: TransactionSortOption.newest, label: 'Newest first'),
                        DropdownMenuEntry(value: TransactionSortOption.oldest, label: 'Oldest first'),
                        DropdownMenuEntry(value: TransactionSortOption.amountHighest, label: 'Amount: highest first'),
                        DropdownMenuEntry(value: TransactionSortOption.amountLowest, label: 'Amount: lowest first'),
                      ],
                      expandedInsets: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

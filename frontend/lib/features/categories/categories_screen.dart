import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import 'categories_state.dart';
import 'models/category.dart';
import 'widgets/category_form_modal.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoriesState _state;

  @override
  void initState() {
    super.initState();
    _state = CategoriesState();
    _state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  void _showCategoryForm([Category? category]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryFormModal(
        state: _state,
        category: category,
      ),
    );
  }

  Future<void> _confirmDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _state.deleteCategory(category.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildCategoryList(List<Category> categoriesList, String title) {
    if (categoriesList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoriesList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = categoriesList[index];
              return ListTile(
                title: Text(category.name),
                subtitle: Text(
                  category.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showCategoryForm(category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () => _confirmDelete(category),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        AppSpacing.gapLg,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryForm(),
          ),
        ],
      ),
      body: _state.isLoading && _state.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _state.error != null && _state.categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load categories',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                      AppSpacing.gapMd,
                      ElevatedButton(
                        onPressed: _state.loadCategories,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _state.categories.isEmpty
                  ? const Center(
                      child: Text('No categories found. Add one to get started!'),
                    )
                  : RefreshIndicator(
                      onRefresh: _state.loadCategories,
                      child: SingleChildScrollView(
                        padding: AppSpacing.paddingLg,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCategoryList(_state.expenseCategories, 'Expenses'),
                            _buildCategoryList(_state.incomeCategories, 'Income'),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

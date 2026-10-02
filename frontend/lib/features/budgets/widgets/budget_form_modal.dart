import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../transactions/models/category.dart';
import '../models/budget.dart';

class BudgetFormModal extends StatefulWidget {
  final Budget? budget;
  final List<Category> categories;
  final DateTime currentMonth;
  final Function(int categoryId, double amount, int month, int year) onSave;

  const BudgetFormModal({
    super.key,
    this.budget,
    required this.categories,
    required this.currentMonth,
    required this.onSave,
  });

  @override
  State<BudgetFormModal> createState() => _BudgetFormModalState();
}

class _BudgetFormModalState extends State<BudgetFormModal> {
  final _formKey = GlobalKey<FormState>();

  late int? _selectedCategoryId;
  late TextEditingController _amountController;
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.budget?.categoryId;
    _amountController = TextEditingController(
      text: widget.budget != null ? widget.budget!.amount.toString() : '',
    );
    _selectedMonth = widget.budget?.month ?? widget.currentMonth.month;
    _selectedYear = widget.budget?.year ?? widget.currentMonth.year;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid positive amount')),
        );
        return;
      }

      widget.onSave(_selectedCategoryId!, amount, _selectedMonth, _selectedYear);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only allow selecting expense categories for budgets
    final expenseCategories = widget.categories.where((c) => c.type == 'EXPENSE').toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.budget == null ? 'Create Budget' : 'Edit Budget',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: expenseCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  if (amount < 0) {
                    return 'Amount must be greater than or equal to 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text((index + 1).toString()),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMonth = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      initialValue: _selectedYear.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final year = int.tryParse(value);
                        if (year != null) {
                          _selectedYear = year;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a year';
                        }
                        final year = int.tryParse(value);
                        if (year == null || year < 1900 || year > 2100) {
                          return 'Valid year required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Save'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

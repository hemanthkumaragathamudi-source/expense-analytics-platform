import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'states/transaction_form_state.dart';
import '../auth/auth_state.dart';
import 'models/transaction.dart';

class TransactionFormScreen extends StatefulWidget {
  final AuthState authState;
  final Transaction? transaction;

  const TransactionFormScreen({
    super.key,
    required this.authState,
    this.transaction,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late TransactionFormState _formState;
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formState = TransactionFormState(
      userId: widget.authState.user!.id,
      initialTransaction: widget.transaction,
    );
    _formState.loadData();

    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description ?? '';
      _notesController.text = widget.transaction!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _formState.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _formState.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _formState.date) {
      _formState.setDate(picked);
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formState.setDescription(_descriptionController.text);
      _formState.setNotes(_notesController.text);

      final success = await _formState.save();
      if (success && mounted) {
        context.pop(true); // Return true to indicate success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: ListenableBuilder(
        listenable: _formState,
        builder: (context, _) {
          if (_formState.isLoadingData) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_formState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        _formState.error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),

                  // Transaction Type Segmented Control
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'EXPENSE', label: Text('Expense')),
                        ButtonSegment(value: 'INCOME', label: Text('Income')),
                      ],
                      selected: {_formState.transactionType},
                      onSelectionChanged: (Set<String> newSelection) {
                        _formState.setTransactionType(newSelection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    labelText: 'Amount',
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.attach_money),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter an amount';
                      final val = double.tryParse(value);
                      if (val == null || val <= 0) return 'Please enter a valid amount greater than 0';
                      return null;
                    },
                    onChanged: (value) {
                      final val = double.tryParse(value);
                      if (val != null) _formState.setAmount(val);
                    },
                  ),

                  // Category Dropdown
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    initialValue: _formState.categoryId,
                    items: _formState.categories.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (val) => _formState.setCategoryId(val),
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Date Picker
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM d, yyyy').format(_formState.date)),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    labelText: 'Description (Optional)',
                    controller: _descriptionController,
                  ),

                  // Payment Method Dropdown (Optional)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Payment Method (Optional)',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    initialValue: _formState.paymentMethodId,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('None'),
                      ),
                      ..._formState.paymentMethods.map((pm) {
                        return DropdownMenuItem<int>(
                          value: pm.id,
                          child: Text(pm.name),
                        );
                      }),
                    ],
                    onChanged: (val) => _formState.setPaymentMethodId(val),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    labelText: 'Notes (Optional)',
                    controller: _notesController,
                    keyboardType: TextInputType.multiline,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    text: isEditing ? 'Save Changes' : 'Add Transaction',
                    onPressed: _save,
                    isLoading: _formState.isSaving,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/payment_method.dart';
import '../payment_methods_state.dart';

class PaymentMethodFormDialog extends StatefulWidget {
  final PaymentMethodsState state;
  final PaymentMethod? paymentMethod;

  const PaymentMethodFormDialog({
    super.key,
    required this.state,
    this.paymentMethod,
  });

  @override
  State<PaymentMethodFormDialog> createState() => _PaymentMethodFormDialogState();
}

class _PaymentMethodFormDialogState extends State<PaymentMethodFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.paymentMethod?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final isEditing = widget.paymentMethod != null;

    final success = isEditing
        ? await widget.state.updatePaymentMethod(widget.paymentMethod!.id, name)
        : await widget.state.createPaymentMethod(name);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Payment method updated successfully'
                : 'Payment method created successfully',
          ),
        ),
      );
    } else if (mounted && widget.state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.state.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      widget.state.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.paymentMethod == null
          ? 'Add Payment Method'
          : 'Edit Payment Method'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController,
              labelText: 'Name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.state.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Save',
          isLoading: widget.state.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}

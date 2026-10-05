import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import 'payment_methods_state.dart';
import 'widgets/payment_method_form_dialog.dart';
import 'models/payment_method.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _state = PaymentMethodsState();

  @override
  void initState() {
    super.initState();
    _state.loadPaymentMethods();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _showForm([PaymentMethod? paymentMethod]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ListenableBuilder(
        listenable: _state,
        builder: (context, _) => PaymentMethodFormDialog(
          state: _state,
          paymentMethod: paymentMethod,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(PaymentMethod paymentMethod) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete "${paymentMethod.name}"?'),
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

    if (confirm == true && mounted) {
      final success = await _state.deletePaymentMethod(paymentMethod.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method deleted successfully')),
        );
      } else if (mounted && _state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_state.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        _state.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          if (_state.isLoading && _state.paymentMethods.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_state.error != null && _state.paymentMethods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _state.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapMd,
                  ElevatedButton(
                    onPressed: _state.loadPaymentMethods,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_state.paymentMethods.isEmpty) {
            return RefreshIndicator(
              onRefresh: _state.loadPaymentMethods,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(
                      child: Text('No payment methods found. Add one!'),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _state.loadPaymentMethods,
            child: ListView.separated(
              padding: AppSpacing.paddingLg,
              itemCount: _state.paymentMethods.length,
              separatorBuilder: (context, index) => AppSpacing.gapMd,
              itemBuilder: (context, index) {
                final method = _state.paymentMethods[index];
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(method.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showForm(method),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(method),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Text('Transactions Screen (Placeholder)'),
        ),
      ),
    );
  }
}

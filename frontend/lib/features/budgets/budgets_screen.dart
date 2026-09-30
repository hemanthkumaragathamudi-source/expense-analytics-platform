import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Text('Budgets Screen (Placeholder)'),
        ),
      ),
    );
  }
}

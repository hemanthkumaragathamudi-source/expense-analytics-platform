import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Text('Analytics Screen (Placeholder)'),
        ),
      ),
    );
  }
}

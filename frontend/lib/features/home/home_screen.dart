import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Text('Home Screen (Placeholder)'),
        ),
      ),
    );
  }
}

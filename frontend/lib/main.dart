import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_spacing.dart';
import 'core/widgets/app_button.dart';
import 'core/widgets/app_card.dart';
import 'core/widgets/app_text_field.dart';
import 'core/theme/app_typography.dart';

void main() {
  runApp(const ETrackerApp());
}

class ETrackerApp extends StatelessWidget {
  const ETrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const FoundationShowcase(),
    );
  }
}

class FoundationShowcase extends StatelessWidget {
  const FoundationShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Tracker Foundation'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Typography', style: Theme.of(context).textTheme.headlineMedium),
            AppSpacing.gapMd,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Headline Large', style: Theme.of(context).textTheme.headlineLarge),
                  Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
                  Text('Financial Value: \$1,234.56', style: AppTypography.monoTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
                ],
              ),
            ),
            AppSpacing.gapLg,
            Text('Inputs & Buttons', style: Theme.of(context).textTheme.headlineMedium),
            AppSpacing.gapMd,
            AppCard(
              child: Column(
                children: [
                  const AppTextField(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const AppTextField(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: true,
                  ),
                  AppSpacing.gapMd,
                  AppButton(
                    text: 'Primary Action',
                    onPressed: () {},
                  ),
                  AppSpacing.gapMd,
                  const AppButton(
                    text: 'Disabled Action',
                    onPressed: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

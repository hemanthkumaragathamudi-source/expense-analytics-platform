import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_state.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/auth_state.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authState = AuthState();
  authState.checkAuthentication();

  final themeState = ThemeState();
  await themeState.init();

  final appRouter = AppRouter(authState);

  runApp(ETrackerApp(
    authState: authState,
    themeState: themeState,
    appRouter: appRouter,
  ));
}

class ETrackerApp extends StatelessWidget {
  final AuthState authState;
  final ThemeState themeState;
  final AppRouter appRouter;

  const ETrackerApp({
    super.key,
    required this.authState,
    required this.themeState,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeState: themeState,
      child: ListenableBuilder(
        listenable: authState,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: themeState,
            builder: (context, _) {
              return MaterialApp.router(
                title: 'E-Tracker',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                routerConfig: appRouter.router,
              );
            }
          );
        },
      ),
    );
  }
}

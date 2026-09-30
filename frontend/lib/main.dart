import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_state.dart';
import 'routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authState = AuthState();
  authState.checkAuthentication();

  final appRouter = AppRouter(authState);

  runApp(ETrackerApp(
    authState: authState,
    appRouter: appRouter,
  ));
}

class ETrackerApp extends StatelessWidget {
  final AuthState authState;
  final AppRouter appRouter;

  const ETrackerApp({
    super.key,
    required this.authState,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authState,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'E-Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: appRouter.router,
        );
      },
    );
  }
}

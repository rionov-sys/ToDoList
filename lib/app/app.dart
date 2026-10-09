import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/network/api_client.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/main_navigation/screens/main_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/focus_timer_provider.dart';
import '../providers/task_provider.dart';
import '../providers/timeline_provider.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/task_service.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class ChronosApp extends StatelessWidget {
  final LocalStorageService localStorageService;
  final ApiClient apiClient;

  const ChronosApp({
    super.key,
    required this.localStorageService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(
      apiClient: apiClient,
      localStorage: localStorageService,
    );

    final taskService = TaskService(
      apiClient: apiClient,
      localStorage: localStorageService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService)..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskService: taskService)..loadTasks(),
        ),
        ChangeNotifierProvider(
          create: (_) => TimelineProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CalendarProvider(taskService: taskService)..loadCalendarSummary(),
        ),
        ChangeNotifierProvider(
          create: (_) => FocusTimerProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Chronos - Kinetic Focus OS & Timeline Tracking',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            home: auth.isAuthenticated ? const MainScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}

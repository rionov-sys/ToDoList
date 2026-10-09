import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/main_navigation/screens/main_screen.dart';
import '../../features/tasks/screens/create_task_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/kinetic_focus/screens/kinetic_focus_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String createTask = '/create-task';
  static const String taskDetail = '/task-detail';
  static const String focus = '/focus';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case createTask:
        return MaterialPageRoute(builder: (_) => const CreateTaskScreen());
      case taskDetail:
        final taskId = settings.arguments as String? ?? 'task_1';
        return MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: taskId));
      case focus:
        return MaterialPageRoute(builder: (_) => const KineticFocusScreen());
      default:
        return MaterialPageRoute(builder: (_) => const MainScreen());
    }
  }
}

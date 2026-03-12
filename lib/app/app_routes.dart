import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/user_queue/generate_token_screen.dart';
import '../features/user_queue/queue_status_screen.dart';
import '../features/user_queue/user_dashboard_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';


class AppRoutes {
  
  static const String splash         = '/';              
  static const String login          = '/login';
  static const String userDashboard  = '/user_dashboard';
  static const String adminDashboard = '/admin_dashboard';
  static const String generateToken  = '/generate_token';
  static const String queueStatus    = '/queue_status';

 
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case userDashboard:
        return MaterialPageRoute(builder: (_) => const UserDashboardScreen());

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case generateToken:
        return MaterialPageRoute(builder: (_) => const GenerateTokenScreen());

      case queueStatus:
        return MaterialPageRoute(builder: (_) => const QueueStatusScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                '⚠️ No route defined for: ${settings.name}\n'
                'Add it to AppRoutes.generateRoute()',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }
}

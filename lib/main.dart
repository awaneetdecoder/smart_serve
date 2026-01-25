import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'features/user_queue/queue_provider.dart';
import 'features/auth/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
      ],
      child: const SmartServeApp(),
    ),
  );
}

class SmartServeApp extends StatelessWidget {
  const SmartServeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartServe',
      theme: AppTheme.lightTheme, // Use the theme I gave you earlier
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/user_queue/queue_provider.dart';
import 'features/admin/admin_provider.dart';
import 'features/settings/settings_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// m
void main() {
 
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
   
    MultiProvider(
      providers: [
       
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => QueueProvider()),

        
        ChangeNotifierProvider(create: (_) => AdminProvider()),

        
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
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
      theme: AppTheme.lightTheme,     
      initialRoute: AppRoutes.splash,     
      onGenerateRoute: AppRoutes.generateRoute,      
      debugShowCheckedModeBanner: false,
    );
  }
}
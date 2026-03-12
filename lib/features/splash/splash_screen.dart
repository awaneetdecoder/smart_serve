import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../auth/auth_provider.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // We can't do async work directly in initState, but we can call
    // an async helper method from it.
    _checkLoginAndNavigate();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _checkLoginAndNavigate()
  // FLOW:
  //   1. Wait 1.5 seconds (shows the splash logo)
  //   2. Ask AuthProvider to check SharedPreferences for saved login data
  //   3. If user was logged in before → go to the correct dashboard
  //   4. If not → go to login screen
  //
  // WHY 1.5 second delay?
  //   tryAutoLogin() is very fast (just reads from local storage).
  //   Without the delay, the splash would flash for 50ms — barely visible.
  //   1.5s is enough to show branding without feeling slow.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _checkLoginAndNavigate() async {
  await Future.delayed(const Duration(milliseconds: 1500));

  if (!mounted) return;

  final auth = Provider.of<AuthProvider>(context, listen: false);

  try {
    final wasLoggedIn = await auth.tryAutoLogin();

    if (!mounted) return;

    if (wasLoggedIn) {
      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.userDashboard);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  } catch (e) {
    // ✅ If ANYTHING goes wrong, go to login screen
    // WHY: Without this, any error silently freezes the splash screen forever
    print('Auto login failed: $e');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon / Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.confirmation_number,
                size: 56,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              'SmartServe',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            Text(
              'Intelligent Queue Management',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator — shows while checking auto-login
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

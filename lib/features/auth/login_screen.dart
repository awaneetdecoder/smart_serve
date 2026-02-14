import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import 'auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;
  // Renamed variable for clarity
  bool _isAdmin = false; 
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // leading: const BackButton(color: Colors.black),
        title: const Text("SmartServe", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              _isAdmin ? "Sign in to manage queues." : "Sign in to join the queue.", 
              style: Theme.of(context).textTheme.bodyMedium
            ),
            const SizedBox(height: 32),

            // --- FUNCTIONAL TOGGLE SWITCH ---
            Container(
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  // User Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAdmin = false),
                      child: _buildToggleOption("User", !_isAdmin),
                    ),
                  ),
                  // Admin Button (Updated Name)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAdmin = true),
                      child: _buildToggleOption("Admin", _isAdmin),
                    ),
                  ),
                ],
              ),
            ),
            // --------------------------------

            const SizedBox(height: 24),

            const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: _isAdmin ? "admin@college.edu" : "student@college.edu",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: "Enter your password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  
                  // Use inputs or defaults for demo
                  final email = _emailController.text.isEmpty ? (_isAdmin ? "admin" : "student") : _emailController.text;
                  final password = _passwordController.text.isEmpty ? "password" : _passwordController.text;

                  // Force "Admin" mode if they selected the Admin tab
                  String finalEmail = _isAdmin ? "admin@college.edu" : email;

                  bool success = await auth.login(finalEmail, password);
                  
                  if (!context.mounted) return;

                  if (success) {
                    if (_isAdmin || auth.status == AuthStatus.admin) {
                       Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
                    } else {
                       Navigator.pushReplacementNamed(context, AppRoutes.userDashboard);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login Failed")),
                    );
                  }
                },
                child: Text(_isAdmin ? "Log In as Admin" : "Log In"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isSelected 
        ? BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(10), 
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)]
          )
        : null, 
      child: Text(
        text, 
        textAlign: TextAlign.center, 
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: isSelected ? Colors.black : Colors.grey
        )
      ),
    );
  }
}
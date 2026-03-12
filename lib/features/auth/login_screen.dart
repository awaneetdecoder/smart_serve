import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import 'auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoginScreen
// WHAT: The screen where users login OR register a new account.
//
// TABS: Login | Register | Admin
//   - Login: existing users sign in
//   - Register: new users create an account  ← NEW
//   - Admin: special login for admins (uses role check)
//
// CHANGES FROM OLD VERSION:
//   Old: Mock logic — always "succeeds" by checking if email contains "admin"
//   New: Calls real Spring Boot /api/auth/login and /api/auth/register
// ─────────────────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Which tab is active: 0 = Login, 1 = Register, 2 = Admin
  int _selectedTab = 0;

  bool _isObscure = true; // Controls password visibility toggle

  // Text controllers: these "hold" what the user types in the fields
  // WHY controllers and not just reading the field value?
  //   Controllers give you the text value at any time (e.g., when button pressed)
  //   and let you clear the fields programmatically.
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController(); // For Register tab only

  // ─────────────────────────────────────────────────────────────────────────
  // dispose()
  // WHY MUST we call dispose? TextEditingControllers allocate memory.
  //     If we don't dispose them, they keep existing after the screen closes.
  //     Multiply this by every screen you navigate to → memory leak.
  //     Always dispose controllers in the dispose() lifecycle method.
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<AuthProvider>() — subscribe to AuthProvider changes
    // WHY watch and not read?
    //   watch: rebuilds this widget when AuthProvider notifies (e.g., isLoading changes)
    //   read:  reads once without subscribing (used for one-off actions)
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // No back button on login screen
        title: const Text(
          'SmartServe',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen title changes based on selected tab
            Text(
              _selectedTab == 1 ? 'Create Account' : 'Welcome Back',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 1
                  ? 'Register to start using SmartServe'
                  : _selectedTab == 2
                      ? 'Sign in to manage queues.'
                      : 'Sign in to join the queue.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // ── TAB SWITCHER ───────────────────────────────────────────────
            // 3 options: User Login | Register | Admin Login
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: _buildTabOption('Login', _selectedTab == 0),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: _buildTabOption('Register', _selectedTab == 1),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 2),
                      child: _buildTabOption('Admin', _selectedTab == 2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── FULL NAME FIELD (only on Register tab) ────────────────────
            if (_selectedTab == 1) ...[
              const Text('Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _fullNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── EMAIL FIELD ───────────────────────────────────────────────
            const Text('Email Address',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: _selectedTab == 2
                    ? 'admin@college.edu'
                    : 'student@college.edu',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // ── PASSWORD FIELD ────────────────────────────────────────────
            const Text('Password',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                // Toggle password visibility
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _isObscure = !_isObscure),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),

            // ── ERROR MESSAGE ─────────────────────────────────────────────
            // Show the error from AuthProvider if login/register fails
            if (auth.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── SUBMIT BUTTON ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                // auth.isLoading: disable button while API call is in progress
                // WHY? Without this, user could tap 10 times and send 10 requests
                onPressed: auth.isLoading ? null : _handleSubmit,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _selectedTab == 0
                            ? 'Log In'
                            : _selectedTab == 1
                                ? 'Create Account'
                                : 'Log In as Admin',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _handleSubmit()
  // WHAT: Called when the submit button is pressed.
  //       Validates inputs, calls the right auth method, navigates on success.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    // Basic client-side validation before hitting the server
    // WHY validate here? Saves a network round trip for obvious errors.
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter your email and password.');
      return;
    }

    if (_selectedTab == 1 && fullName.isEmpty) {
      _showSnackBar('Please enter your full name to register.');
      return;
    }

    // Get AuthProvider without listening (we just need to call a method)
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (_selectedTab == 0) {
      // ── LOGIN ──
      // Calls POST /api/auth/login with real email + password
      success = await auth.login(email, password);
    } else if (_selectedTab == 1) {
      // ── REGISTER ──
      // Calls POST /api/auth/register, then auto-logs in
      success = await auth.register(
        fullName: fullName,
        email:    email,
        password: password,
        role:     'STUDENT',
      );
    } else {
      // ── ADMIN LOGIN ──
      // Same as regular login — backend checks role field
      success = await auth.login(email, password);
    }

    // Check if widget still exists before navigating
    if (!mounted) return;

    if (success) {
      // Navigate based on role
      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.userDashboard);
      }
    }
    // If failed: AuthProvider has set errorMessage, the build() above shows it
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildTabOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                const BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
            )
          : null,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isSelected ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
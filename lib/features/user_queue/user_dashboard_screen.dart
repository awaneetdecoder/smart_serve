import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../auth/auth_provider.dart';
import 'queue_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserDashboardScreen
// WHAT: The home screen for regular users after they log in.
//
// WHAT IT SHOWS:
//   - Greeting with the user's actual name (from backend, not hardcoded "Student")
//   - If user has an active token → shows the token card with real data
//   - If no active token → shows "Join Queue" button
//
// KEY CHANGES FROM OLD VERSION:
//   Old: Hardcoded "Hello, Student" greeting
//        Token data was mock data
//        No API call on screen open
//   New: Real name from AuthProvider.currentUser.fullName
//        Real token data from QueueProvider (loaded from backend on init)
//        Calls loadUserTokens() when screen opens to get current status
// ─────────────────────────────────────────────────────────────────────────────
class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

// WHY StatefulWidget now (was StatelessWidget)?
// We need initState() to trigger the API call when the screen opens.
// StatelessWidget has no lifecycle methods like initState().
class _UserDashboardScreenState extends State<UserDashboardScreen> {

  @override
  void initState() {
    super.initState();
    // Load user's active tokens when screen opens
    // WHY here and not in the build() method?
    //   build() runs EVERY time the widget rebuilds (which can be many times).
    //   initState() runs ONLY ONCE when the screen first appears.
    //   We don't want to make an API call on every rebuild — that would be
    //   dozens of unnecessary requests per second!
    _loadData();
  }

  Future<void> _loadData() async {
    // listen: false because we're calling a method, not subscribing to changes
    final auth  = Provider.of<AuthProvider>(context, listen: false);
    final queue = Provider.of<QueueProvider>(context, listen: false);

    // Only load if user is logged in (safety check)
    if (auth.currentUser != null) {
      await queue.loadUserTokens(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch → rebuilds this screen when auth or queue state changes
    final auth  = context.watch<AuthProvider>();
    final queue = context.watch<QueueProvider>();

    // Get the first name only for a friendly greeting
    // WHY? "Hello, Muhammad Ali Khan" is too long. "Hello, Muhammad" is friendly.
    final firstName = auth.currentUser?.fullName.split(' ').first ?? 'there';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              // Clear queue state first, then logout
              Provider.of<QueueProvider>(context, listen: false).clearQueue();
              await auth.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        // Pull-to-refresh: user can swipe down to reload queue data
        // WHY? Queue position changes constantly. Let users manually refresh.
        onRefresh: _loadData,
        child: SingleChildScrollView(
          // physics needed for RefreshIndicator to work even when content
          // doesn't fill the screen
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real greeting using actual user's name from backend
              Text(
                'Hello, $firstName 👋',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                auth.currentUser?.email ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // ── QUEUE STATE ─────────────────────────────────────────────
              // Show loading spinner, active token, or join queue button
              if (queue.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (queue.activeToken != null)
                // User has an active token — show it
                _buildActiveTokenCard(context, queue)
              else
                // No active token — show join queue prompt
                _buildJoinQueueCard(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _buildActiveTokenCard()
  // Shows the user's current token number and wait time.
  // All data comes from QueueProvider.activeToken (which got it from backend).
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildActiveTokenCard(BuildContext context, QueueProvider queue) {
    final token = queue.activeToken!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            'YOUR TOKEN',
            style: TextStyle(
                color: Colors.white70, letterSpacing: 1.2, fontSize: 12),
          ),
          const SizedBox(height: 8),

          // Real token number from backend (e.g., "T-101")
          Text(
            token.tokenNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          // Token type (department)
          Text(
            token.tokenType,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Wait time — real value from /api/queue/user/{id}/wait-time
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              token.estimatedWaitMinutes > 0
                  ? '⏱  ~${token.estimatedWaitMinutes} min wait'
                  : '⏱  Calculating wait...',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // View Full Status button
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.queueStatus),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryBlue,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View Full Status'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _buildJoinQueueCard()
  // Shows a prompt to join the queue when user has no active token.
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildJoinQueueCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.generateToken),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryBlue,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Join a Queue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to select a department and get your token number',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

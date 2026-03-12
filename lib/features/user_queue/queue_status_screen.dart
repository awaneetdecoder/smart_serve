import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_theme.dart';
import '../auth/auth_provider.dart';
import 'queue_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QueueStatusScreen
// WHAT: Shows the user their real queue position and wait time.
//
// KEY CHANGES FROM OLD VERSION:
//   Old: All data was hardcoded ("A-106", "A-102", "3 people ahead", "12 mins")
//   New: Real data from QueueProvider.activeToken (loaded from backend)
//
// DATA SOURCES:
//   token.tokenNumber       → e.g. "T-106"  (from POST /api/queue/join)
//   token.tokenType         → e.g. "General Consultation"
//   token.estimatedWaitMinutes → e.g. 15   (from GET /api/queue/user/{id}/wait-time)
//   token.peopleAhead       → e.g. 3       (calculated from wait time)
//   token.status            → e.g. "waiting"
// ─────────────────────────────────────────────────────────────────────────────
class QueueStatusScreen extends StatefulWidget {
  const QueueStatusScreen({super.key});

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {

  @override
  void initState() {
    super.initState();
    // Refresh wait time when screen opens
    // WHY? Wait time changes constantly as people are served.
    //      We want the latest estimate when user opens this screen.
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final auth  = Provider.of<AuthProvider>(context, listen: false);
    final queue = Provider.of<QueueProvider>(context, listen: false);

    if (auth.currentUser != null) {
      await queue.loadUserTokens(auth.currentUser!.id as int); ;
    }
  }

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueProvider>();
    final token = queue.activeToken;

    // If no active token (user cancelled or was never in queue)
    // show a "no active token" message
    if (token == null && !queue.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No active token', style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text('Generate a token to join the queue.',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: queue.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // ── LIVE UPDATE INDICATOR ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00BFA5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── YOUR TOKEN NUMBER ──────────────────────────────────
                    const Text(
                      'YOUR TOKEN NUMBER',
                      style: TextStyle(
                          letterSpacing: 1.2,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                    ),
                    // Real token number from backend
                    Text(
                      token?.tokenNumber ?? '---',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),

                    // Token type (department)
                    Text(
                      token?.tokenType ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 32),

                    // ── QUEUE INFO CARD ────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'STATUS',
                            style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          // Real status from backend (WAITING, SERVING, etc.)
                          Text(
                            token?.status.toUpperCase() ?? 'WAITING',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                    fontSize: 32,
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.access_time_filled,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              // Real wait time from /wait-time endpoint
                              Text(
                                token?.estimatedWaitMinutes != null &&
                                        token!.estimatedWaitMinutes > 0
                                    ? 'Approx. ${token.estimatedWaitMinutes} min wait'
                                    : 'Calculating wait time...',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── PEOPLE AHEAD ───────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Queue Info',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        // Real people count from backend calculation
                        token?.peopleAhead != null && token!.peopleAhead > 0
                            ? 'There are ${token.peopleAhead} people ahead of you'
                            : 'You are next in line! 🎉',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── ACTIONS ────────────────────────────────────────────
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement push notifications
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Notifications coming soon! Pull down to manually refresh.')),
                        );
                      },
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text("Notify me when I'm next"),
                    ),
                    const SizedBox(height: 16),

                    // Cancel button — calls DELETE /api/queue/{id}
                    TextButton(
                      onPressed: queue.isLoading
                          ? null
                          : () async {
                              // Show confirmation dialog before cancelling
                              // WHY? Accidental taps happen. Confirm saves frustration.
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Cancel Token?'),
                                  content: const Text(
                                      'Are you sure you want to cancel your queue position? This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Keep my spot'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Yes, cancel',
                                          style:
                                              TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && mounted) {
                                final queue = Provider.of<QueueProvider>(
                                    context,
                                    listen: false);
                                await queue.cancelToken();
                                if (mounted) Navigator.pop(context);
                              }
                            },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel Appointment',
                          style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'By remaining in the queue, you agree to receive updates.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const BackButton(color: Colors.black),
      title: const Text('Queue Status',
          style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: _refreshStatus,
        )
      ],
    );
  }
}

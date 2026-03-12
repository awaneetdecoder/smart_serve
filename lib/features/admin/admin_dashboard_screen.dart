import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../auth/auth_provider.dart';
import 'admin_provider.dart';
import '../../models/token_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminDashboardScreen
// WHAT: The home screen for admins.
//       Shows all queue tokens with real-time data from the backend.
//
// KEY CHANGES FROM OLD VERSION:
//   Old: Hardcoded tokens (A-102, B-449, A-105), no working buttons,
//        stats were fake numbers, AdminProvider not registered or connected
//   New: Real tokens from GET /api/queue/all
//        Serve Next → PUT /api/queue/{id}/status?status=SERVING (real API call)
//        Skip → real status update
//        Hold → real status update
//        Stats show real waiting count
// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load all queue data when admin opens the dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // WHY addPostFrameCallback?
      //   initState() runs BEFORE the widget is fully built.
      //   Calling Provider.of here would fail because the context isn't ready.
      //   addPostFrameCallback runs AFTER the first frame is built —
      //   so the context is fully available.
      Provider.of<AdminProvider>(context, listen: false).loadAllTokens();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final admin = context.watch<AdminProvider>();

    // Filter tokens based on search query
    // WHY compute this inside build()? It's fast (no API call) and
    //     automatically uses the latest _searchQuery and admin.allTokens
    final displayedTokens = _searchQuery.isEmpty
        ? admin.waitingTokens  // Default: show only WAITING tokens
        : admin.allTokens.where((t) {
            final q = _searchQuery.toLowerCase();
            return t.tokenNumber.toLowerCase().contains(q) ||
                t.tokenType.toLowerCase().contains(q) ||
                (t.user?.fullName.toLowerCase().contains(q) ?? false);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.admin_panel_settings,
                color: AppTheme.primaryBlue),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            // Show admin's email below the title
            Text(
              auth.currentUser?.email ?? 'Admin',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          // Refresh button — reload all tokens
          IconButton(
            onPressed: () => admin.loadAllTokens(),
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
          // Logout
          IconButton(
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── ERROR MESSAGE ──────────────────────────────────────────
                if (admin.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(admin.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700)),
                  ),

                // ── STATS ROW ──────────────────────────────────────────────
                Row(
                  children: [
                    // Real waiting count from AdminProvider.waitingCount
                    Expanded(
                      child: _buildStatCard(
                        'IN QUEUE',
                        admin.waitingCount.toString(), // REAL COUNT
                        'Waiting customers',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'TOTAL TODAY',
                        admin.allTokens.length.toString(), // All tokens ever
                        'Tokens generated',
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── SEARCH BAR ─────────────────────────────────────────────
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by token, department, or name...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (val) =>
                      setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 24),

                // ── TOKEN LIST HEADER ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchQuery.isEmpty
                          ? 'Waiting Tokens (${admin.waitingCount})'
                          : 'Search Results (${displayedTokens.length})',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _searchQuery = '');
                      },
                      child: const Text('All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── LOADING STATE ──────────────────────────────────────────
                if (admin.isLoading)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ))
                // ── EMPTY STATE ────────────────────────────────────────────
                else if (displayedTokens.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.inbox_outlined,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No customers waiting'
                                : 'No results for "$_searchQuery"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                // ── TOKEN LIST ─────────────────────────────────────────────
                else
                  ...displayedTokens.map((token) => _buildTokenCard(
                        context: context,
                        token: token,
                        adminProvider: admin,
                      )),
              ],
            ),
          ),

          // ── SERVE NEXT STICKY BUTTON ─────────────────────────────────────
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: (admin.isLoading || admin.waitingCount == 0)
                  ? null
                  : () async {
                      // Call PUT /api/queue/{id}/status?status=SERVING
                      final success = await admin.serveNextCustomer();
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  admin.errorMessage ?? 'Failed to serve next')),
                        );
                      }
                    },
              icon: admin.isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.play_arrow),
              label: Text(admin.waitingCount == 0
                  ? 'No customers waiting'
                  : 'Serve Next Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _buildStatCard()
  // Reusable stat card widget for the top row (IN QUEUE, TOTAL TODAY)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatCard(
      String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // _buildTokenCard()
  // Shows one token with Skip / Hold buttons wired to real API calls.
  //
  // KEY CHANGE: Skip and Hold buttons now call AdminProvider methods
  //             which call PUT /api/queue/{id}/status
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTokenCard({
    required BuildContext context,
    required TokenModel token,
    required AdminProvider adminProvider,
  }) {
    // Color coding by status
    Color statusColor;
    switch (token.status.toUpperCase()) {
      case 'SERVING':
        statusColor = Colors.green;
        break;
      case 'ON_HOLD':
        statusColor = Colors.orange;
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppTheme.primaryBlue; // WAITING
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.confirmation_number_outlined,
                    color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Real token number from backend (e.g., "T-101")
                    Text('Token #${token.tokenNumber}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    // User's name if available
                    Text(
                      token.user?.fullName.isNotEmpty == true
                          ? token.user!.fullName
                          : 'Unknown user',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    Text('Dept: ${token.tokenType}',
                        style:
                            TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
              // Status badge with real status from backend
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  token.status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons — all wired to real API calls
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    // PUT /api/queue/{id}/status?status=DONE (skip)
                    await adminProvider.skipToken(token.id);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Skip',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    // PUT /api/queue/{id}/status?status=ON_HOLD
                    await adminProvider.holdToken(token.id);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Hold',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              // If token is SERVING, show "Done" button
              if (token.isServing) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // PUT /api/queue/{id}/status?status=DONE
                      await adminProvider.markAsDone(token.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
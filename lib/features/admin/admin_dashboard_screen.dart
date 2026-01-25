import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.person, color: AppTheme.primaryBlue),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Admin Dashboard", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                const Text("Main Branch", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 4),
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text("Active", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: Colors.black))
        ],
      ),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Bottom padding for sticky button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatCard("IN QUEUE", "24", "+12% vs last hr", Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard("AVG. WAIT", "12m", "-2% vs today", Colors.red)),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search tokens or customers...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Active Tokens Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Active Tokens", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text("View All")),
                  ],
                ),
                const SizedBox(height: 8),

                // 4. Token List Items
                _buildTokenCard(
                  token: "A-102",
                  service: "General Consultation",
                  status: "15 mins",
                  isPriority: true,
                ),
                _buildTokenCard(
                  token: "B-449",
                  service: "Account Support",
                  status: "8 mins",
                  isPriority: false,
                ),
                 _buildTokenCard(
                  token: "A-105",
                  service: "General Consultation",
                  status: "5 mins",
                  isPriority: false,
                ),
              ],
            ),
          ),

          // Sticky Bottom Button
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Call API to serve next
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Serve Next Customer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- THESE ARE THE METHODS YOU MISSED LAST TIME ---
  // They must be INSIDE the class, but OUTSIDE the build() function.

  Widget _buildStatCard(String title, String value, String trend, Color trendColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              if (title == "IN QUEUE") Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(trendColor == Colors.green ? Icons.trending_up : Icons.trending_down, size: 14, color: trendColor),
              const SizedBox(width: 4),
              Text(trend, style: TextStyle(color: trendColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTokenCard({required String token, required String service, required String status, required bool isPriority}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.confirmation_number_outlined, color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Token #$token", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (isPriority) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                            child: const Text("PRIORITY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                          )
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("Service: $service", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(status, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                  const Text("WAITING", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Skip", style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Hold", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
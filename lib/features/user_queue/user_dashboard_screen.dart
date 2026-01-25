import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import 'queue_provider.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the Provider
    final queue = Provider.of<QueueProvider>(context);
    // 2. Get the Token Model (Safe Access)
    final token = queue.activeToken; 

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, Student", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
            const SizedBox(height: 32),

            // 3. Logic: If token exists, show status. Else, show join button.
            if (token != null) 
              _buildActiveTokenCard(context, token.tokenNumber, token.estimatedWaitMinutes)
            else 
              _buildJoinQueueCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTokenCard(BuildContext context, String number, int minutes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text("YOUR TOKEN", style: TextStyle(color: Colors.white70)),
          Text(number, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          Text("Wait: $minutes mins", style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.queueStatus),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryBlue),
            child: const Text("View Full Status"),
          )
        ],
      ),
    );
  }

  Widget _buildJoinQueueCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.generateToken),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: const [
            Icon(Icons.add_circle, color: AppTheme.primaryBlue, size: 40),
            SizedBox(width: 16),
            Text("Join a Queue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
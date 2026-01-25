import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Queue Status",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Live Update Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00BFA5), // Teal dot
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text("Live Updates", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 16),
            
            // 2. Your Token (The Big Number)
            const Text("YOUR TOKEN NUMBER", 
                style: TextStyle(letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            Text("A-106", style: Theme.of(context).textTheme.displayLarge),
            
            const SizedBox(height: 32),

            // 3. Now Serving Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Light Blue bg
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  const Text("NOW SERVING", 
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text("A-102", 
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 40)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.access_time_filled, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Approx. 12 mins wait", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Queue Progress List (The complex part)
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Queue Progress", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text("There are 3 people ahead of you", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 24),

            // THE TIMELINE WIDGETS
            _buildTimelineItem(
              context, 
              token: "A-102", 
              status: "Currently at Counter 04", 
              isCompleted: true,
              isLast: false
            ),
            _buildTimelineItem(
              context, 
              token: "A-103", 
              status: "Preparing next", 
              isActive: true,
              isLast: false
            ),
            _buildTimelineItem(
              context, 
              token: "A-104", 
              status: "Waiting in line", 
              isLast: false
            ),
            _buildTimelineItem(
              context, 
              token: "A-106 (You)", 
              status: "Expected: ~11:45 AM", 
              isHighlight: true,
              isLast: true
            ),

            const SizedBox(height: 40),

            // 5. Actions
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text("Notify me when I'm next"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Cancel Appointment", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 24),
            const Text(
              "By remaining in the queue, you agree to receive real-time notifications.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // --- RUTHLESS NOTE: Extract this to a separate widget file in production ---
  Widget _buildTimelineItem(BuildContext context, 
      {required String token, required String status, bool isCompleted = false, bool isActive = false, bool isHighlight = false, required bool isLast}) {
    
    Color dotColor;
    Color iconColor = Colors.white;
    IconData icon = Icons.circle; // Default dot

    if (isCompleted) {
      dotColor = AppTheme.primaryBlue;
      icon = Icons.check;
    } else if (isActive) {
      dotColor = Colors.white; // Ring effect
      icon = Icons.circle; 
    } else if (isHighlight) {
      dotColor = AppTheme.primaryBlue;
      icon = Icons.person;
    } else {
      dotColor = Colors.grey.shade200;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The Timeline Line & Dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // The Dot
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : dotColor,
                    shape: BoxShape.circle,
                    border: isActive ? Border.all(color: AppTheme.primaryBlue, width: 2) : null,
                  ),
                  child: Center(
                     child: isActive 
                      ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle))
                      : Icon(icon, size: 16, color: isCompleted || isHighlight ? Colors.white : Colors.transparent),
                  ),
                ),
                // The Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // The Text Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(token, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: isHighlight ? AppTheme.primaryBlue : Colors.black
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(status, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
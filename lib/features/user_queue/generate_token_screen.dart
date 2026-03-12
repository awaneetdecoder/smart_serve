import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../auth/auth_provider.dart';
import 'queue_provider.dart';


class GenerateTokenScreen extends StatefulWidget {
  const GenerateTokenScreen({super.key});

  @override
  State<GenerateTokenScreen> createState() => _GenerateTokenScreenState();
}

class _GenerateTokenScreenState extends State<GenerateTokenScreen> {
  String? selectedDepartment;

  // These match departments you'd have in your system
  // Stored as tokenType in the backend QueueEntry.tokenType field
  final List<String> departments = [
    'General Consultation',
    'Admissions',
    'Accounts',
    'Library',
    'IT Support',
  ];

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final queue = context.watch<QueueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Token',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Your Token',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the service department you wish to visit.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            const Text('Select Department',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // Department Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDepartment,
                  hint: const Text('Choose a department...'),
                  isExpanded: true,
                  items: departments.map((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => selectedDepartment = val),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Estimated Wait Time',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(text: 'Avg wait: '),
                            TextSpan(
                              text: '~5 min per person',
                              style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ], style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.people, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
            ),

            // Error message if join fails
            if (queue.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    queue.errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ),

            const Spacer(),

            // Generate Token Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: queue.isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.confirmation_number),
                label: Text(
                    queue.isLoading ? 'Generating...' : 'Generate Token'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                // Disable button if no department selected OR loading
                onPressed: (selectedDepartment == null || queue.isLoading)
                    ? null
                    : () async {
    // ✅ ?? 0 makes it plain int — never nullable
    final int userId =( auth.currentUser?.id ?? 0) as int;

    if (userId == 0) {      // ✅ ) is now correct
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login again.'),
        ),
      );
      return;
    }

    final success = await queue.joinQueue(
      userId:    userId,        // ✅ plain int, no ! needed
      tokenType: selectedDepartment!,
    );

    if (success && mounted) {
      Navigator.pushNamed(context, AppRoutes.queueStatus);
    }
  },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'By generating a token, you agree to our queue management terms.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sidebar.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/stats_card.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      drawer: const Sidebar(role: 'manager'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales & Stock Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildStatsGrid(),
          ],
        ),
      ),
    );
  }

  // 🔹 Fetch Stats from Firestore
  Widget _buildStatsGrid() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('stats').doc('manager_dashboard').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No data available'));
        }

        var stats = snapshot.data!.data() as Map<String, dynamic>;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StatsCard(title: 'Sales Today', value: stats['salesToday'].toString(), icon: Icons.show_chart),
            StatsCard(title: 'Stock Levels', value: stats['stockLevels'].toString(), icon: Icons.inventory_2),
          ],
        );
      },
    );
  }
}

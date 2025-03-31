import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sidebar.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/stats_card.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: const Sidebar(role: 'admin'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('stats').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var stats = snapshot.data!.docs.first.data();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StatsCard(title: 'Total Sales', value: stats['totalSales'].toString(), icon: Icons.bar_chart),
            StatsCard(title: 'Stock Items', value: stats['totalStockItems'].toString(), icon: Icons.inventory),
            StatsCard(title: 'Users', value: stats['totalUsers'].toString(), icon: Icons.people),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('activities').orderBy('timestamp', descending: true).limit(5).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(docs[index]['message']),
                subtitle: Text(docs[index]['timestamp'].toDate().toString()),
              );
            },
          );
        },
      ),
    );
  }
}

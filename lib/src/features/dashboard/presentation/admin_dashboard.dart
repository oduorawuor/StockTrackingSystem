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

  // 🔹 Fetch and display key statistics for the admin from multiple collections
  Widget _buildStatsGrid() {
    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection('sales').get(),  // Fetch all sales documents
        FirebaseFirestore.instance.collection('users').get(),  // Fetch all users documents
        FirebaseFirestore.instance.collection('stock').get(),  // Fetch all stock documents
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Error loading data'));
        }

        // Extract data from each collection
        var salesDocs = snapshot.data![0].docs;
        var usersDocs = snapshot.data![1].docs;
        var stockDocs = snapshot.data![2].docs;

        // Process the data from each collection to get the required stats
        int totalSales = salesDocs.length;  // Example: Count total sales documents
        int totalUsers = usersDocs.length;  // Example: Count total users documents
        int totalStockItems = stockDocs.length;  // Example: Count total stock documents

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatsCard(title: 'Total Sales', value: totalSales.toString(), icon: Icons.bar_chart),
                StatsCard(title: 'Total Revenue', value: 'KES\${totalSales * 100}', icon: Icons.monetization_on), // Example revenue calculation
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatsCard(title: 'Total Users', value: totalUsers.toString(), icon: Icons.people),
                StatsCard(title: 'Stock Items', value: totalStockItems.toString(), icon: Icons.inventory),
              ],
            ),
          ],
        );
      },
    );
  }

  // 🔹 Fetch and display recent activities
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
        stream: FirebaseFirestore.instance
            .collection('activities')
            .orderBy('timestamp', descending: true)
            .limit(5)
            .snapshots(),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sidebar.dart';

class SalesDashboard extends StatelessWidget {
  const SalesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Dashboard')),
      drawer: const Sidebar(role: 'sales'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStatsCards(),
            const SizedBox(height: 20),
            const Text(
              'Recent Sales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(child: _buildRecentSales()),
          ],
        ),
      ),
    );
  }

  // 🔹 Display Sales Summary Cards
  Widget _buildStatsCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sales').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        int totalSales = snapshot.data!.docs.length;
        int salesToday = snapshot.data!.docs.where((doc) {
          var date = (doc['timestamp'] as Timestamp).toDate();
          return date.day == DateTime.now().day;
        }).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatsCard(title: 'Total Sales', value: totalSales.toString(), icon: Icons.shopping_cart),
            StatsCard(title: 'Sales Today', value: salesToday.toString(), icon: Icons.show_chart),
          ],
        );
      },
    );
  }

  // 🔹 List Recent Sales Transactions
  Widget _buildRecentSales() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sales').orderBy('timestamp', descending: true).limit(5).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var sales = snapshot.data!.docs;

        if (sales.isEmpty) {
          return const Center(child: Text('No recent sales.'));
        }

        return ListView.builder(
          itemCount: sales.length,
          itemBuilder: (context, index) {
            var sale = sales[index];
            String product = sale['product'];
            int quantity = sale['quantity'];
            DateTime date = (sale['timestamp'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                title: Text(product, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Quantity: $quantity\nDate: ${date.toLocal()}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

// 🔹 Stats Card Widget
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatsCard({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

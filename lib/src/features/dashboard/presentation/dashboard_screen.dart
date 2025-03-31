import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/stock_summary_card.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/recent_activities_list.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sales_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_tracking_app/firebase_options.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _StatsGrid(crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 2 : 1)),
            const SizedBox(height: 24),
            if (isLargeScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildSalesChart(),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    child: RecentActivitiesList(),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildSalesChart(),
                  const SizedBox(height: 24),
                  const RecentActivitiesList(),
                ],
              ),
            const SizedBox(height: 24),
            const StockSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(child: SalesChart()),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int crossAxisCount;

  const _StatsGrid({required this.crossAxisCount, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: fetchStats(), // Fetch data from Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loading state
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}")); // Error state
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No data available")); // No data found
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: snapshot.data!, // Populate grid with fetched data
        );
      },
    );
  }
}

Future<List<Widget>> fetchStats() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  try {
    QuerySnapshot snapshot = await firestore.collection('stats').get();
    if (snapshot.docs.isEmpty) {
      return []; // Return empty list if no data is found
    }

    List<Widget> statCards = snapshot.docs.map((doc) {
      return _StatCard(
        title: 'Total Stock Items',
        value: doc['totalStockItems'].toString(),
        icon: Icons.inventory,
        color: Colors.blue,
      );
    }).toList();

    return statCards;
  } catch (e) {
    print("Error fetching stats: $e");
    return [];
  }
}


class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RecentActivitiesList extends StatelessWidget {
  const RecentActivitiesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _mockActivities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = _mockActivities[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: activity.color.withOpacity(0.2),
                    child: Icon(
                      activity.icon,
                      color: activity.color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    activity.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    activity.time,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    activity.value,
                    style: TextStyle(
                      color: activity.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Activity {
  final String title;
  final String time;
  final String value;
  final IconData icon;
  final Color color;

  const _Activity({
    required this.title,
    required this.time,
    required this.value,
    required this.icon,
    required this.color,
  });
}

final List<_Activity> _mockActivities = [
  _Activity(
    title: 'New Stock Added',
    time: '2 minutes ago',
    value: '+50 units',
    icon: Icons.add_circle,
    color: Colors.green,
  ),
  _Activity(
    title: 'Stock Sold',
    time: '15 minutes ago',
    value: '-10 units',
    icon: Icons.shopping_cart,
    color: Colors.blue,
  ),
  _Activity(
    title: 'Low Stock Alert',
    time: '1 hour ago',
    value: '5 items',
    icon: Icons.warning,
    color: Colors.orange,
  ),
  _Activity(
    title: 'New Order',
    time: '2 hours ago',
    value: '\$1,234',
    icon: Icons.receipt,
    color: Colors.purple,
  ),
  _Activity(
    title: 'Stock Updated',
    time: '3 hours ago',
    value: '15 items',
    icon: Icons.update,
    color: Colors.teal,
  ),
];

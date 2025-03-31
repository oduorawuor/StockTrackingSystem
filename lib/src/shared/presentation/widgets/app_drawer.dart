import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Text(
            'Stock Tracking',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.inventory),
          label: Text('Inventory'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.shopping_cart),
          label: Text('Sales'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people),
          label: Text('Users'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.assessment),
          label: Text('Reports'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 10, 16, 10),
          child: _UserProfileTile(),
        ),
      ],
    );
  }
}

class _UserProfileTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          child: Icon(Icons.person),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'John Doe',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Admin',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            // TODO: Implement logout
          },
        ),
      ],
    );
  }
}

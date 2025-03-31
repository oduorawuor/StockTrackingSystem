import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String role;

  const Sidebar({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(child: _buildMenu(context)),
        ],
      ),
    );
  }

  // Sidebar Header
  Widget _buildHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            role.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Sidebar Menu
  Widget _buildMenu(BuildContext context) {
    List<Map<String, dynamic>> menuItems = _getMenuItems();

    return ListView(
      children: menuItems.map((item) {
        return ListTile(
          leading: Icon(item['icon'], color: Colors.blue),
          title: Text(item['title']),
          onTap: () {
            Navigator.pushNamed(context, item['route']);
          },
        );
      }).toList(),
    );
  }

  // Define Menu Items Based on Role
  List<Map<String, dynamic>> _getMenuItems() {
    switch (role) {
      case 'admin':
        return [
            {'title': 'Reports', 'icon': Icons.show_chart, 'route': '/sales_reports'},
          {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/admin_dashboard'},
          {'title': 'Manage Users', 'icon': Icons.people, 'route': '/manage_users'},
          {'title': 'Stock', 'icon': Icons.inventory, 'route': '/stock'},
          {'title': 'Sales History', 'icon': Icons.show_chart, 'route': '/sales_history'},
          {'title': 'Logout', 'icon': Icons.logout, 'route': '/login'},
        ];
      case 'manager':
        return [
          {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/manager_dashboard'},
          {'title': 'Sales Reports', 'icon': Icons.analytics, 'route': '/sales_reports'},
          {'title': 'Stock', 'icon': Icons.inventory, 'route': '/stock'},
          {'title': 'Suppliers', 'icon': Icons.local_shipping, 'route': '/suppliers'},
          {'title': 'Logout', 'icon': Icons.logout, 'route': '/login'},
        ];
      case 'sales':
        return [
          {'title': 'Sales Dashboard', 'icon': Icons.dashboard, 'route': '/sales_dashboard'},
          {'title': 'New Sale', 'icon': Icons.shopping_cart, 'route': '/sales'},
          {'title': 'Sales History', 'icon': Icons.history, 'route': '/sales_history'},
          {'title': 'Logout', 'icon': Icons.logout, 'route': '/login'},
        ];
      default:
        return [];
    }
  }
}

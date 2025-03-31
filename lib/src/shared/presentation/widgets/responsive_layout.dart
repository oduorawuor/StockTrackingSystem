import 'package:flutter/material.dart';
import 'package:stock_tracking_app/src/shared/presentation/widgets/app_drawer.dart';

class ResponsiveLayout extends StatefulWidget {
  final List<Widget> screens;

  const ResponsiveLayout({
    super.key,
    required this.screens,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;
    final isMediumScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isMediumScreen
          ? null
          : AppBar(
              title: const Text('Stock Tracking'),
              centerTitle: true,
            ),
      drawer: isMediumScreen
          ? null
          : AppDrawer(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
            ),
      body: Row(
        children: [
          if (isMediumScreen)
            AppDrawer(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
            ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: widget.screens[_selectedIndex],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 1: // Inventory
        return FloatingActionButton(
          onPressed: () {
            // TODO: Add new inventory item
          },
          child: const Icon(Icons.add),
        );
      case 2: // Sales
        return FloatingActionButton(
          onPressed: () {
            // TODO: Add new sale
          },
          child: const Icon(Icons.add_shopping_cart),
        );
      default:
        return null;
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

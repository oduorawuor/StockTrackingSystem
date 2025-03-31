import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_tracking_app/src/features/auth/presentation/login_screen.dart';
import 'package:stock_tracking_app/src/features/auth/providers/auth_provider.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:stock_tracking_app/src/features/inventory/presentation/inventory_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stock_tracking_app/firebase_options.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/admin_dashboard.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/manager_dashboard.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/sales_screen.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sidebar.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/sales_history.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/manage_users.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/stock_manager.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/sales_report.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/sales_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: StockTrackingApp()));
}

class StockTrackingApp extends ConsumerWidget {
  const StockTrackingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Tracking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routes: {
        '/dashboard':(context) => const SalesDashboard(),
        '/sales_dashboard':(context) => const SalesDashboard(),
        '/sales_reports': (context) => const ReportsScreen(),
        '/stock': (context) => const ManageStockScreen(),
        '/manage_users': (context) => const ManageUsersScreen(),
        '/sales_history': (context) => const SalesHistoryScreen(),
     '/login': (context) => const LoginScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/manager_dashboard': (context) => const ManagerDashboard(),
        '/sales': (context) => const SalesScreen(),
      },
      home: authState.when(
        data: (user) => user != null ? const AppScaffold() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Inventory'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart),
                label: Text('Sales'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                DashboardScreen(),
                InventoryScreen(),
                Scaffold(body: Center(child: Text('Sales'))),
                Scaffold(body: Center(child: Text('Users'))),
                Scaffold(body: Center(child: Text('Reports'))),
                Scaffold(body: Center(child: Text('Settings'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'src/features/auth/login_screen.dart';
import 'src/features/dashboard/presentation/admin_dashboard.dart';
import 'src/features/dashboard/presentation/manager_dashboard.dart';
import 'src/features/sales/sales_screen.dart';
import 'src/features/dashboard/presentation/dashboard_screen.dart';
import 'src/features/dashboard/presentation/widgets/sidebar.dart';
import 'src/features/dashboard/presentation/widgets/stats_card.dart';


Map<String, WidgetBuilder> routes = {
        '/login': (context) => const LoginScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/manager_dashboard': (context) => const ManagerDashboard(),
        '/sales_dashboard': (context) => const SalesDashboard(),
        '/manage_users': (context) => const ManageUsersScreen(),
        '/stock': (context) => const StockScreen(),
        '/sales': (context) => const SalesScreen(),
        '/sales_reports': (context) => const SalesReportsScreen(),
        '/stock_levels': (context) => const StockLevelsScreen(),
        '/suppliers': (context) => const SuppliersScreen(),
        '/new_sale': (context) => const NewSaleScreen(),
        '/sales_history': (context) => const SalesHistoryScreen(),
      },
};

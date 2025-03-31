import 'package:flutter/material.dart';

class StockSummaryCard extends StatelessWidget {
  const StockSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            'Stock Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  horizontalMargin: 12,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Unit Price')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: _mockStockItems.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item.name)),
                        DataCell(Text(item.category)),
                        DataCell(Text(item.quantity.toString())),
                        DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: item.status.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.status.label,
                              style: TextStyle(
                                color: item.status.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum StockStatus {
  inStock(label: 'In Stock', color: Colors.green),
  lowStock(label: 'Low Stock', color: Colors.orange),
  outOfStock(label: 'Out of Stock', color: Colors.red);

  final String label;
  final Color color;

  const StockStatus({
    required this.label,
    required this.color,
  });
}

class _StockItem {
  final String name;
  final String category;
  final int quantity;
  final double price;
  final StockStatus status;

  const _StockItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.status,
  });
}

final List<_StockItem> _mockStockItems = [
  _StockItem(
    name: 'Laptop XPS 13',
    category: 'Electronics',
    quantity: 45,
    price: 1299.99,
    status: StockStatus.inStock,
  ),
  _StockItem(
    name: 'Wireless Mouse',
    category: 'Accessories',
    quantity: 5,
    price: 29.99,
    status: StockStatus.lowStock,
  ),
  _StockItem(
    name: 'USB-C Cable',
    category: 'Accessories',
    quantity: 0,
    price: 19.99,
    status: StockStatus.outOfStock,
  ),
  _StockItem(
    name: 'Monitor 27"',
    category: 'Electronics',
    quantity: 12,
    price: 299.99,
    status: StockStatus.inStock,
  ),
  _StockItem(
    name: 'Keyboard',
    category: 'Accessories',
    quantity: 8,
    price: 89.99,
    status: StockStatus.lowStock,
  ),
];

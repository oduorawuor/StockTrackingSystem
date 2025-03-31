import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sidebar.dart';

class ManageStockScreen extends StatelessWidget {
  const ManageStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Stock')),
      drawer: const Sidebar(role: 'admin'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildStockList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStockDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔹 Function to fetch and display stock items
  Widget _buildStockList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('stock').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var stockItems = snapshot.data!.docs;

        if (stockItems.isEmpty) {
          return const Center(child: Text('No stock items found.'));
        }

        return ListView.builder(
          itemCount: stockItems.length,
          itemBuilder: (context, index) {
            var stock = stockItems[index];
            String id = stock.id;
            String name = stock['name'];
            int quantity = stock['quantity'];
            double price = stock['price'].toDouble();

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.inventory, color: Colors.blue),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Quantity: $quantity\nPrice: KES $price'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showStockDialog(context, id: id, name: name, quantity: quantity, price: price),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteStock(id, context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🔹 Function to show dialog for adding/editing stock
  void _showStockDialog(BuildContext context, {String? id, String name = '', int quantity = 0, double price = 0.0}) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController quantityController = TextEditingController(text: quantity.toString());
    TextEditingController priceController = TextEditingController(text: price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Stock Item' : 'Edit Stock Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Stock Name')),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => _saveStock(
                  id, nameController.text, int.tryParse(quantityController.text) ?? 0, double.tryParse(priceController.text) ?? 0.0, context),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Function to add or update stock
  void _saveStock(String? id, String name, int quantity, double price, BuildContext context) async {
    if (name.isEmpty || quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields must be valid')));
      return;
    }

    var stockRef = FirebaseFirestore.instance.collection('stock');

    if (id == null) {
      await stockRef.add({'name': name, 'quantity': quantity, 'price': price});
    } else {
      await stockRef.doc(id).update({'name': name, 'quantity': quantity, 'price': price});
    }

    Navigator.pop(context);
  }

  // 🔹 Function to delete stock
  void _deleteStock(String id, BuildContext context) async {
    await FirebaseFirestore.instance.collection('stock').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock item deleted successfully')));
  }
}

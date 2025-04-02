import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sidebar.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Map<String, Map<String, dynamic>> cart = {}; // Stores products with name, price, and quantity
  bool _isProcessing = false;

  // Function to add a product to the cart
  void _addToCart(String productId, String name, double price) {
    setState(() {
      if (cart.containsKey(name)) {
        cart[name]!['quantity'] += 1;
      } else {
        cart[name] = {'quantity': 1, 'price': price};
      }
    });
  }

  // Function to remove a product from the cart
  void _removeFromCart(String name) {
    setState(() {
      if (cart.containsKey(name)) {
        if (cart[name]!['quantity'] > 1) {
          cart[name]!['quantity'] -= 1;
        } else {
          cart.remove(name);
        }
      }
    });
  }

  // Function to calculate total price
  double _calculateTotal() {
    double total = 0.0;
    for (var item in cart.values) {
      total += item['quantity'] * item['price'];
    }
    return total;
  }

  // Function to process checkout
  Future<void> _checkout() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart is empty!')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      for (var entry in cart.entries) {
        String productName = entry.key;
        int quantity = entry.value['quantity'];

        var stockRef = FirebaseFirestore.instance
            .collection('stock')
            .where('name', isEqualTo: productName);
        var stockSnapshot = await stockRef.get();

        if (stockSnapshot.docs.isEmpty || stockSnapshot.docs.first['quantity'] < quantity) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Not enough stock for $productName')));
          continue;
        }

        var stockDoc = stockSnapshot.docs.first.reference;

        // Reduce stock quantity
        await stockDoc.update({'quantity': stockSnapshot.docs.first['quantity'] - quantity});

        // Log the sale
        await FirebaseFirestore.instance.collection('sales').add({
          'product': productName,
          'quantity': quantity,
          'total_price': entry.value['quantity'] * entry.value['price'],
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      setState(() => cart.clear());

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkout successful!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      drawer: const Sidebar(role: 'sales'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('stock').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var products = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      String productId = product.id;
                      String name = product['name'];
                      int stock = product['quantity'];
                      double price = (product['price'] as num).toDouble();

                      return ListTile(
                        title: Text(name),
                        subtitle: Text('Stock: $stock | Price: Ksh $price'),
                        trailing: ElevatedButton(
                          onPressed: stock > 0 ? () => _addToCart(productId, name, price) : null,
                          child: const Text('Add to Cart'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(),
            const Text(
              'Cart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: cart.isEmpty
                  ? const Center(child: Text('No items in cart'))
                  : ListView(
                      children: cart.entries.map((entry) {
                        String name = entry.key;
                        int quantity = entry.value['quantity'];
                        double price = entry.value['price'];

                        return ListTile(
                          title: Text(name),
                          subtitle: Text('Quantity: $quantity | Price: Ksh $price'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeFromCart(name),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => _addToCart(name, name, price),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Total: Ksh ${_calculateTotal().toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: _isProcessing ? null : _checkout,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

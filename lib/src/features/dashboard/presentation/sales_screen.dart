import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sidebar.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Map<String, int> cart = {}; // Stores selected products and their quantities
  bool _isProcessing = false;

  // Function to add a product to the cart
  void _addToCart(String productName) {
    setState(() {
      cart[productName] = (cart[productName] ?? 0) + 1;
    });
  }

  // Function to remove a product from the cart
  void _removeFromCart(String productName) {
    setState(() {
      if (cart.containsKey(productName)) {
        if (cart[productName]! > 1) {
          cart[productName] = cart[productName]! - 1;
        } else {
          cart.remove(productName);
        }
      }
    });
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
        String product = entry.key;
        int quantity = entry.value;

        var stockRef = FirebaseFirestore.instance.collection('stock').doc(product);
        var stockSnapshot = await stockRef.get();

        if (!stockSnapshot.exists || stockSnapshot['quantity'] < quantity) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Not enough stock for $product')));
          continue;
        }

        // Reduce stock quantity
        await stockRef.update({'quantity': stockSnapshot['quantity'] - quantity});

        // Log the sale
        await FirebaseFirestore.instance.collection('sales').add({
          'product': product,
          'quantity': quantity,
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
                      String productName = product.id;
                      int stock = product['quantity'];

                      return ListTile(
                        title: Text(productName),
                        subtitle: Text('Stock: $stock'),
                        trailing: ElevatedButton(
                          onPressed: stock > 0 ? () => _addToCart(productName) : null,
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
                        return ListTile(
                          title: Text(entry.key),
                          subtitle: Text('Quantity: ${entry.value}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeFromCart(entry.key),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => _addToCart(entry.key),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

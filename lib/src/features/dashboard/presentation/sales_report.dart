import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sidebar.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      drawer: const Sidebar(role: 'admin'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Reports',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildSalesReport()),
            const SizedBox(height: 20),
            _buildExportButtons(context),
          ],
        ),
      ),
    );
  }

  // 🔹 Function to fetch sales data
  Widget _buildSalesReport() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sales').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var sales = snapshot.data!.docs;

        if (sales.isEmpty) {
          return const Center(child: Text('No sales records found.'));
        }

        return ListView.builder(
          itemCount: sales.length,
          itemBuilder: (context, index) {
            var sale = sales[index];
            String product = sale['product'];
            int quantity = sale['quantity'];
            DateTime date = (sale['timestamp'] as Timestamp).toDate();

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.blue),
                title: Text(product, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Quantity: $quantity\nDate: ${date.toLocal()}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  // 🔹 Buttons for exporting reports
  Widget _buildExportButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Export PDF'),
          onPressed: () => _exportToPDF(context),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.table_chart),
          label: const Text('Export CSV'),
          onPressed: () => _exportToCSV(context),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.insert_drive_file),
          label: const Text('Export Excel'),
          onPressed: () => _exportToExcel(context),
        ),
      ],
    );
  }

  // 🔹 Function to generate PDF report
  Future<void> _exportToPDF(BuildContext context) async {
    final pdf = pw.Document();
    var salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: salesSnapshot.docs.map((doc) {
              return pw.Text('${doc['product']} - ${doc['quantity']} units - ${doc['timestamp'].toDate()}');
            }).toList(),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sales_report.pdf');
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

  // 🔹 Function to generate CSV report
  Future<void> _exportToCSV(BuildContext context) async {
    var salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();
    List<List<dynamic>> rows = [
      ['Product', 'Quantity', 'Date']
    ];

    for (var doc in salesSnapshot.docs) {
      rows.add([doc['product'], doc['quantity'], doc['timestamp'].toDate().toString()]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sales_report.csv');
    await file.writeAsString(csvData);

    OpenFile.open(file.path);
  }

Future<void> _exportToExcel(BuildContext context) async {
  var salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();
  var excel = Excel.createExcel();
  Sheet sheet = excel['Sales Report'];

  // Append the header row
 // sheet.appendRow(['Product', 'Quantity', 'Date']);

  // Append sales data
  for (var doc in salesSnapshot.docs) {
    sheet.appendRow([
      doc['product'],
      doc['quantity'],
    ]);
  }

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/sales_report.xlsx');

  await file.writeAsBytes(excel.encode()!);

  OpenFile.open(file.path);
}

}

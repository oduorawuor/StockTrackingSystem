import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_tracking_app/src/features/dashboard/presentation/widgets/sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      drawer: const Sidebar(role: 'admin'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔹 Function to fetch and display users
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            String id = user.id;
            String name = user['name'];
            String email = user['email'];
            String role = user['role'];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Email: $email\nRole: $role'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showUserDialog(context, id: id, name: name, email: email, role: role),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(id, context),
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

  // 🔹 Function to show dialog for adding/editing users
  void _showUserDialog(BuildContext context, {String? id, String name = '', String email = '', String role = 'sales'}) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController emailController = TextEditingController(text: email);
    String selectedRole = role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Add User' : 'Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 10),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: selectedRole,
                items: ['admin', 'manager', 'sales']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role.toUpperCase())))
                    .toList(),
                onChanged: (value) => selectedRole = value!,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => _saveUser(id, nameController.text, emailController.text, selectedRole, context),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Function to add or update user
  void _saveUser(String? id, String name, String email, String role, BuildContext context) async {
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }

    var usersRef = FirebaseFirestore.instance.collection('users');

    try {
      if (id == null) {
        // Create user in Firebase Authentication
        UserCredential credentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: 'default123', // Default password (should be changed later)
        );

        String uid = credentials.user!.uid;

        // Add user to Firestore with UID as document ID
        await usersRef.doc(uid).set({
          'name': name,
          'email': email,
          'role': role,
          'uid': uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User added successfully')));
      } else {
        // Update existing user
        await usersRef.doc(id).update({'name': name, 'email': email, 'role': role});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User updated successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    Navigator.pop(context);
  }

  // 🔹 Function to delete user from Firestore and Firebase Authentication
  void _deleteUser(String id, BuildContext context) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance.collection('users').doc(id).delete();

      // Delete from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == id) {
        await user.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

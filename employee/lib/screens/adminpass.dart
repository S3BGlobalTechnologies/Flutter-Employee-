import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for user data storage (replace with your DB solution)

class AdminCreateUser extends StatefulWidget {
  const AdminCreateUser({super.key});

  @override
  State<AdminCreateUser> createState() => _AdminCreateUserState();
}

class _AdminCreateUserState extends State<AdminCreateUser> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> createUser() async {
    // Validate user input (not shown for brevity)
    try {
      // Use your preferred method for user creation (Firebase Auth not shown here)
      await FirebaseFirestore.instance.collection('users').add({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        // Store password securely ( hashing recommended, not shown for brevity)
      });
      // Show success message or navigate back to Admin dashboard
    } catch (e) {
      print(e);
      // Show error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter User Name',
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter User Email',
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: passwordController,
              obscureText: true, // Hide password input
              decoration: const InputDecoration(
                hintText: 'Enter User Password',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: createUser,
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}

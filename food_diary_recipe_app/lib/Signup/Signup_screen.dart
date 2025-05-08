import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user'; // default value

  Future<void> _signUp() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    User? user = userCredential.user;

    // Store role in Firestore
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': _emailController.text.trim(),
        'role': _selectedRole,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Signup successful as $_selectedRole!")),
    );
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Signup failed.')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Blur glass effect
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/logo.jpg',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 10),
                      Text(
                        "Create Your Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 4)
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      TextField(
                        controller: _emailController,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.email, color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Select Role',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        dropdownColor: Colors.black87,
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        items: ['user', 'admin'].map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.toUpperCase()),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 88, 81, 156)
                                  .withOpacity(0.8),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Sign Up",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Already have an account? Log in",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

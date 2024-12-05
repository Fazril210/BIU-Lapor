import 'package:biu_force/screens/forgot_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final String successMessage;
  const LoginPage({super.key, this.successMessage = ''});

  @override
  _LoginPageState createState() => _LoginPageState();
}

Future<void> _saveLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('lastPage', '/home'); // Default halaman awal
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nimController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  final FocusNode _nimFocusNode = FocusNode(); 
  final FocusNode _passwordFocusNode = FocusNode(); 

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hash password before storing or comparing
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // convert password to bytes
    var digest = sha256.convert(bytes); // hash it with SHA-256
    return digest.toString(); // return hash as string
  }

  // Method to handle login
Future<void> _loginUser() async {
  String npm = nimController.text.trim(); // Input dari pengguna (NPM)
  String password = passwordController.text.trim();

  if (npm.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NPM dan Password wajib diisi!')),
    );
    return;
  }

  try {
    // Query Firestore untuk mencari user berdasarkan npm
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('npm', isEqualTo: npm)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Jika tidak ada pengguna dengan NPM tersebut
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna dengan NPM tersebut tidak ditemukan!')),
      );
      return;
    }

    // Ambil email pengguna dari dokumen Firestore
    DocumentSnapshot userDoc = querySnapshot.docs.first;
    String email = userDoc['email']; // Pastikan `email` ada di Firestore

    // Gunakan Firebase Authentication untuk memvalidasi password
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan status login ke SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('npm', npm); // Simpan NPM
      await _saveLoginStatus();

      // Navigasi ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password salah!')),
        );
      } else if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun tidak ditemukan!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  } catch (e) {
    // Tangani error dari Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Masuk',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade800,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.green.shade300,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo with animation
              AnimatedContainer(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                height: 150,
                width: 150,
                child: Image.asset('assets/logo.png'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              const Text(
                'Masuk untuk melanjutkan ke BIU Lapor',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 30),

              // Success message, if provided
              if (widget.successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    widget.successMessage,
                    style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

              // Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: nimController,
                  focusNode: _nimFocusNode, 
                   style: TextStyle(
                  color: _nimFocusNode.hasFocus
                      ? Colors.green.shade800 
                      : Colors.green.shade800, 
                ),
                  decoration: InputDecoration(
                    labelText: 'NPM',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                    ),
                    labelStyle: TextStyle(
                      color: _nimFocusNode.hasFocus
                        ? Colors.green.shade800 
                        : Colors.green.shade800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: passwordController,
                   focusNode: _passwordFocusNode, 
                   style: TextStyle(
                  color: _nimFocusNode.hasFocus
                      ? Colors.green.shade800 
                      : Colors.green.shade800, 
                ),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.green.shade700),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.green.shade700,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                    ),
                    labelStyle: TextStyle(
                      color: _passwordFocusNode.hasFocus
                        ? Colors.green.shade800 
                        : Colors.green.shade800,
                    )
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Login Button with improved styling
              ElevatedButton(
                onPressed: _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  shadowColor: Colors.green.shade600,
                  elevation: 5,
                ),
                child: const Text(
                  'Masuk',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              // Register link
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Tidak memiliki Akun?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      minimumSize: const Size(0, 0),
                    ),
                    
                    child: const Text(
                      ' Daftar',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

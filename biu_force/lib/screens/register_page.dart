import 'dart:convert'; // for utf8.encode
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';

import 'login_page.dart'; // Pastikan login_page.dart ada

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _ktmImage;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Method to hash the password before storing it
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // convert password to bytes
    var digest = sha256.convert(bytes); // hash it with SHA-256
    return digest.toString(); // return hash as string
  }

  Future<void> _pickImage(bool isKtm) async {
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        if (isKtm) {
          _ktmImage = pickedImage;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selected: ${pickedImage.name}')),
      );
    }
  }

   Future<String?> uploadFileForRegister(File file) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.118:5000/upload'), // IP backend
    );

    // Tambahkan custom header untuk menandai file dari register
    request.headers['from-register'] = 'true';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: path.basename(file.path),
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      return jsonResponse['filePath'];
    } else {
      print('Gagal mengunggah file: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error saat mengunggah file: $e');
    return null;
  }
}

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    String npm = _npmController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();

    if (npm.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty || _ktmImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi!')));
      setState(() {
        _isLoading = false;
      });
      return;
    }

     // Logika validasi dan inisialisasi
  if (_ktmImage != null) {
    final response = await uploadFileForRegister(File(_ktmImage!.path));
    if (response != null) {
      print('File KTM uploaded to: $response');
    } else {
      print('Gagal mengunggah KTM');
    }
  }

    try {
      // Firebase Authentication: Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Hash password before saving to Firestore
        String hashedPassword = _hashPassword(password);

        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'npm': npm,
          'password': hashedPassword, // Save the hashed password
          'phone': phone,
          'email': email,
          'photoPath': _ktmImage?.path,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Show SnackBar for successful registration
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi berhasil!')));

        // Navigate to login page with success message
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(successMessage: 'Registrasi berhasil!'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error occurred';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email sudah digunakan.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Buat Akun',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 30),
                _buildInputField(_nameController, 'Nama', Icons.person),
                const SizedBox(height: 16),
                _buildInputField(_npmController, 'NPM', Icons.assignment,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildInputField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 16),
                _buildInputField(_phoneController, 'Nomor Telepon', Icons.phone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
               _buildInputField(
                  _passwordController,
                  'Password',
                  Icons.lock,
                  obscureText: true,
                  isPasswordField: true,
                ),
                const SizedBox(height: 20),
                _buildImagePicker(
                    "Upload Foto KTM / KTP / SIM", true, _ktmImage),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.green,
                      )
                    : ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 15),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Daftar',
                            style: TextStyle(color: Colors.white)),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      bool isPasswordField = false}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          suffixIcon: isPasswordField
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.green.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.green.shade50,
        ),
        obscureText: isPasswordField && !_isPasswordVisible,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildImagePicker(String label, bool isKtm, XFile? imageFile) {
    return GestureDetector(
      onTap: () => _pickImage(isKtm),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              if (imageFile != null)
                Image.file(
                  File(imageFile.path),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              else
                const Icon(Icons.upload_file, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui';

import 'package:biu_force/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ValueNotifier<String?> _profileImagePath = ValueNotifier<String?>(null);

    @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? npm = prefs.getString('npm'); // Ambil NPM dari SharedPreferences

    if (npm != null) {
      // Query Firestore untuk mendapatkan data pengguna berdasarkan field `npm`
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('npm', isEqualTo: npm)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Ambil dokumen pertama (npm diharapkan unik)
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
    }
    return null; // Jika pengguna tidak ditemukan
  }

  void _refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profil"),
              backgroundColor: Colors.green.shade700,
            ),
            body: const Center(child: Text("Data pengguna tidak ditemukan")),
          );
        }

        final userData = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profil",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green.shade700,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
              Padding(
  padding: const EdgeInsets.all(20.0),
  child: GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Detail Foto Profil",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<String?>(
                  valueListenable: _profileImagePath,
                  builder: (context, path, child) {
                    return path == null
                        ? const Text(
                            "Tidak ada foto profil tersedia.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            ),
                          );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Tutup modal
                    await _uploadProfilePicture(context); // Unggah gambar baru
                  },
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: const Text(
                    "Unggah Gambar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Tutup", style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        );
      },
    );
  },
  child: ValueListenableBuilder<String?>(
    valueListenable: _profileImagePath,
    builder: (context, path, child) {
      return CircleAvatar(
        radius: 70,
        backgroundImage: path == null
            ? const AssetImage('assets/default_photo.png')
            : FileImage(File(path)) as ImageProvider,
        child: path == null ? const CircularProgressIndicator() : null,
      );
    },
  ),
),
),


                Text(
                  userData['name'] ?? 'Nama Tidak Ditemukan',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'NPM: ${userData['npm'] ?? 'Tidak Ada'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  title: 'Informasi Kontak',
                  children: [
                    Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 70, // Lebar tetap untuk label
          child: Text(
            'Email:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Text(
            userData['email'] ?? 'Tidak Tersedia',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis, // Jika email terlalu panjang
          ),
        ),
      ],
    ),
    const SizedBox(height: 8), // Spasi antar baris
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 70, // Lebar tetap untuk label
          child: Text(
            'Telepon:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Text(
            userData['phone'] ?? 'Tidak Tersedia',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  ],
)

                  ],
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  title: 'Dokumen Identitas',
                  children: [
                    userData['photoPath'] != null &&
                            userData['photoPath'].isNotEmpty
                        ? FutureBuilder<File>(
                            future:
                                _getCorrectedImageFile(userData['photoPath']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              if (snapshot.hasError || snapshot.data == null) {
                                return const Icon(
                                  Icons.broken_image,
                                  color: Colors.red,
                                  size: 100,
                                ); // Tampilkan ikon jika ada error
                              }

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    16), // Sudut melengkung
                                child: Image.file(
                                  snapshot.data!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(
                                3), // Sudut melengkung fallback
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 100,
                              ),
                            ),
                          ),
                    const SizedBox(height: 10),
                    const Text(
                      'KTP/KTM/SIM',
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildMenuButtons(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Divider(),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.edit, color: Colors.green),
          title: const Text('Edit Profil'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _buildDialog(
                  context,
                  title: 'Edit Profil',
                  message: 'Fitur ini akan segera hadir!',
                  icon: Icons.edit,
                  iconColor: Colors.green,
                );
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock, color: Colors.blue),
          title: const Text('Ganti Password'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) =>
                  _buildChangePasswordDialog(context),
            );

            if (result == true) {
              // ignore: invalid_use_of_protected_member
              (context as Element).reassemble();
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.red),
          title: const Text('Logout'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _buildLogoutDialog(context);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDialog(BuildContext context,
      {required String title,
      required String message,
      required IconData icon,
      required Color iconColor}) {
    final ImagePicker _picker = ImagePicker();
    XFile? _pickedFile; // File baru yang dipilih oleh pengguna

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text("Data tidak dapat dimuat."));
        }

        final userData = snapshot.data!;
        final TextEditingController nameController =
            TextEditingController(text: userData['name']);
        final TextEditingController emailController =
            TextEditingController(text: userData['email'] ?? '');
        final TextEditingController phoneController =
            TextEditingController(text: userData['phone']);
        final String currentPhotoPath = userData['photoPath'] ?? '';

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 40, color: iconColor),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          labelStyle: const TextStyle(color: Colors.green),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.green.withOpacity(0.7)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.green),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.green.withOpacity(0.7)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Nomor Telepon',
                          labelStyle: const TextStyle(color: Colors.green),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.green.withOpacity(0.7)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gambar Sebelumnya
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Gambar Sebelumnya:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: currentPhotoPath.isNotEmpty
                                ? Image.file(
                                    File(currentPhotoPath),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 150,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Text(
                                        "Tidak ada dokumen",
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Gambar Baru
                          const Text(
                            "Gambar Baru:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              // Pilih gambar dari galeri
                              _pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                                maxHeight: 480,
                                maxWidth: 640,
                              );

                              if (_pickedFile != null) {
                                setState(
                                    () {}); // Perbarui UI setelah gambar dipilih
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Gambar berhasil dipilih!')),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _pickedFile != null
                                  ? Image.file(
                                      File(_pickedFile!.path),
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 150,
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Text(
                                          "Klik untuk memilih gambar",
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tombol Simpan dengan Konfirmasi
                      ElevatedButton(
                        onPressed: () async {
                          // Tampilkan dialog konfirmasi
                          final bool? confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      16), // Membuat sudut melengkung
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Ikon dan judul
                                      Icon(
                                        Icons.info_rounded,
                                        size: 50,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Konfirmasi Perubahan",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Teks isi
                                      const Text(
                                        "Apakah Anda yakin ingin menyimpan perubahan ini? Data yang telah diubah tidak dapat dikembalikan.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Tombol aksi
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Tombol Batal
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                            ),
                                            child: Text(
                                              "Batal",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.red.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),

                                          // Tombol Simpan
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade700,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              "Simpan",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );

                          if (confirmed != true) {
                            return; // Batalkan jika pengguna tidak mengonfirmasi
                          }

                          try {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? npm = prefs.getString('npm');

                            if (npm == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('NPM tidak ditemukan!')),
                              );
                              return;
                            }

                            QuerySnapshot querySnapshot =
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .where('npm', isEqualTo: npm)
                                    .get();

                            if (querySnapshot.docs.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Pengguna tidak ditemukan!')),
                              );
                              return;
                            }

                            DocumentSnapshot userDoc = querySnapshot.docs.first;

                            // Simpan data ke Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userDoc.id)
                                .update({
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'phone': phoneController.text.trim(),
                              // Gunakan gambar baru jika ada
                              'photoPath':
                                  _pickedFile?.path ?? currentPhotoPath,
                            });

                            Navigator.of(context).pop();
                            _refreshPage();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Profil berhasil diperbarui!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Simpan',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<File> _getCorrectedImageFile(String photoPath) async {
    final file = File(photoPath);

    try {
      // Muat gambar untuk mengetahui dimensinya
      final image = await decodeImageFromList(file.readAsBytesSync());

      // Jika tinggi lebih besar dari lebar (potret), putar ke horizontal
      if (image.height > image.width) {
        final rotatedImage = await _rotateImage(file);
        return rotatedImage;
      }

      // Jika gambar sudah horizontal, kembalikan file aslinya
      return file;
    } catch (e) {
      // Tangani error dengan mengembalikan file asli
      return file;
    }
  }

  Future<File> _rotateImage(File file) async {
    // Rotasi gambar menjadi horizontal
    final bytes = file.readAsBytesSync();
    final decodedImage = await decodeImageFromList(bytes);
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Putar gambar 90 derajat untuk membuatnya horizontal
    final paint = Paint();
    final rotatedWidth = decodedImage.height.toDouble();
    final rotatedHeight = decodedImage.width.toDouble();
    canvas.translate(rotatedWidth / 2, rotatedHeight / 2);
    canvas.rotate(-90 * 3.14159 / 180); // Rotasi 90 derajat
    canvas.translate(-rotatedHeight / 2, -rotatedWidth / 2);

    canvas.drawImage(decodedImage, Offset.zero, paint);
    final picture = pictureRecorder.endRecording();
    final img =
        await picture.toImage(rotatedWidth.toInt(), rotatedHeight.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);

    // Simpan hasil rotasi ke file baru
    final rotatedFilePath =
        '${file.parent.path}/rotated_${file.uri.pathSegments.last}';
    final rotatedFile = File(rotatedFilePath);
    await rotatedFile.writeAsBytes(byteData!.buffer.asUint8List());

    return rotatedFile;
  }

  Widget _buildChangePasswordDialog(BuildContext context) {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    final ValueNotifier<bool> hideOldPassword = ValueNotifier(true);
    final ValueNotifier<bool> hideNewPassword = ValueNotifier(true);
    final ValueNotifier<bool> hideConfirmPassword = ValueNotifier(true);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            const Text(
              'Ganti Password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: hideOldPassword,
              builder: (context, isHidden, _) {
                return TextField(
                  controller: oldPasswordController,
                  obscureText: isHidden,
                  decoration: InputDecoration(
                    labelText: 'Password Lama',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          isHidden ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        hideOldPassword.value = !isHidden;
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: hideNewPassword,
              builder: (context, isHidden, _) {
                return TextField(
                  controller: newPasswordController,
                  obscureText: isHidden,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          isHidden ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        hideNewPassword.value = !isHidden;
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: hideConfirmPassword,
              builder: (context, isHidden, _) {
                return TextField(
                  controller: confirmPasswordController,
                  obscureText: isHidden,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          isHidden ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        hideConfirmPassword.value = !isHidden;
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final oldPassword = oldPasswordController.text.trim();
                final newPassword = newPasswordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                if (oldPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua kolom harus diisi!')),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Password baru dan konfirmasi tidak cocok!')),
                  );
                  return;
                }

                try {
                  // Ambil email pengguna dari SharedPreferences
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? npm = prefs.getString('npm');

                  if (npm == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pengguna tidak ditemukan!')),
                    );
                    return;
                  }

                  // Ambil email pengguna dari Firestore berdasarkan NPM
                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('npm', isEqualTo: npm)
                      .get();

                  if (querySnapshot.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pengguna tidak ditemukan!')),
                    );
                    return;
                  }

                  final userDoc = querySnapshot.docs.first;
                  final String email = userDoc['email'];

                  // Re-autentikasi pengguna dengan Firebase Authentication
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final user = auth.currentUser;
                  final credential = EmailAuthProvider.credential(
                    email: email,
                    password: oldPassword, // Password lama untuk re-autentikasi
                  );

                  await user!.reauthenticateWithCredential(credential);

                  // Update password di Firebase Authentication
                  await user.updatePassword(newPassword);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diubah!')),
                  );

                  Navigator.pop(
                      context, true); // Tutup dialog dengan status berhasil
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'wrong-password') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password lama salah!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Gagal mengubah password: ${e.message}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Terjadi kesalahan: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
              ),
              child:
                  const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _uploadProfilePicture(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar tidak dipilih!')),
      );
      return;
    }

    try {
      // Simpan path gambar lokal ke Firestore
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? npm = prefs.getString('npm');

      if (npm == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NPM tidak ditemukan!')),
        );
        return;
      }

      CollectionReference profileCollection =
          FirebaseFirestore.instance.collection('profile');

      String localImagePath = image.path;
      await profileCollection.doc(npm).set({
        'photoProfile': localImagePath,
      });

      // Update ValueNotifier
      _profileImagePath.value = localImagePath;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diunggah!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengganti gambar: $e')),
      );
    }
  }


 Future<void> _loadProfilePicture() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? npm = prefs.getString('npm');

  if (npm == null) return;

  DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('profile').doc(npm).get();

  if (doc.exists && doc.data() != null) {
    _profileImagePath.value =
        (doc.data() as Map<String, dynamic>)['photoProfile'] as String?;
  }
}


  Widget _buildLogoutDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Membuat sudut melengkung
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Logout Besar
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.exit_to_app,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),

            // Judul Dialog
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),

            // Pesan Dialog
            const Text(
              'Apakah Anda yakin ingin logout dari akun Anda?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Batal
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Batal'),
                ),

                // Tombol Logout
                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs
                        .clear(); // Hapus semua data dari SharedPreferences
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false, // Menghapus semua rute sebelumnya
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

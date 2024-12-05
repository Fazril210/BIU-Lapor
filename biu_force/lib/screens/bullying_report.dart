import 'dart:convert';
import 'dart:io';
import 'package:biu_force/screens/home_page.dart';
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReportBullyingPage extends StatefulWidget {
  const ReportBullyingPage({super.key});

  @override
  _ReportBullyingPageState createState() => _ReportBullyingPageState();
}

class _ReportBullyingPageState extends State<ReportBullyingPage> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<XFile>? _mediaFiles;
  List<File>? _videoFiles;
  File? _audioFile;
  bool _isSubmitting = false;
  String? _selectedType;

  final List<String> _bullyingTypes = [
    'Fisik',
    'Verbal',
    'Sosial',
    'Siber',
    'Lainnya',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<String?> _getLoggedInNPM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('npm'); // Ambil NPM dari SharedPreferences
  }

  Future<String?> uploadFileToServer(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.1.118:5000/upload'), // Ganti dengan server backend Anda
      );
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

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      setState(() {
        _mediaFiles = pickedFiles;
      });
      _showSuccessSnackbar('Foto berhasil dipilih');
    } catch (e) {
      _showErrorSnackbar('Gagal memilih foto');
    }
  }

  Future<void> _pickVideos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _videoFiles = result.files.map((file) => File(file.path!)).toList();
        });
        _showSuccessSnackbar('Video berhasil dipilih');
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memilih video');
    }
  }

  Future<void> _pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _audioFile = File(result.files.single.path!);
        });
        _showSuccessSnackbar('Audio berhasil dipilih');
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memilih audio');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Ambil NPM pengguna dari SharedPreferences
        String? loggedInNPM = await _getLoggedInNPM();
        if (loggedInNPM == null) {
          throw Exception('NPM tidak ditemukan. Silakan login ulang.');
        }

        // Upload media ke server
        List<String> uploadedFiles = [];
        String? audioPath;

        // Upload foto
        if (_mediaFiles != null) {
          for (var file in _mediaFiles!) {
            final response = await uploadFileToServer(File(file.path));
            if (response != null) uploadedFiles.add(response);
          }
        }

        // Upload video
        if (_videoFiles != null) {
          for (var file in _videoFiles!) {
            final response = await uploadFileToServer(file);
            if (response != null) uploadedFiles.add(response);
          }
        }

        // Upload audio
        if (_audioFile != null) {
          audioPath = await uploadFileToServer(_audioFile!);
        }

        // Simpan data ke Firestore
        await FirebaseFirestore.instance.collection('reports').add({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'description': _descriptionController.text.trim(),
          'type': _selectedType,
          'uploadedFiles': uploadedFiles,
          'audioFile': audioPath,
          'npm': loggedInNPM,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'Menunggu',
        });

        _showSuccessDialog();
      } catch (e) {
        _showErrorSnackbar('Gagal mengirim laporan: $e');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Laporan Terkirim!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terima kasih atas laporan Anda. Kami akan menindaklanjuti segera.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
             onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomePage(), // Ganti dengan halaman homepage Anda
                ),
              );
            },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Laporkan Bullying',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.red.shade700, Colors.red.shade900],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
               _buildHeaderSection(),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: _nameController,
                        label: 'Nama Anda',
                        icon: Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: _emailController,
                        label: 'Email Anda',
                        icon: Icons.email),
                    const SizedBox(height: 16),
                    _buildTypeDropdown(),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: _descriptionController,
                        label: 'Ceritakan kejadian bullying',
                        icon: Icons.description,
                        maxLines: 4),
                    const SizedBox(height: 16),
                    _buildMediaSection(),
                    const SizedBox(height: 24),
                    _buildSubmitSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildHeaderSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buat Laporan',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami akan menanggapi laporan Anda dengan serius dan rahasia',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }

   Widget _buildTextField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      int maxLines = 1,
      String? Function(String?)? validator,
    }) {
      return TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.red.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.red.shade50,
          contentPadding: const EdgeInsets.all(16),
        ),
      );
    }

  Widget _buildTypeDropdown() {
      return DropdownButtonFormField<String>(
        value: _selectedType,
        items: _bullyingTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedType = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Tipe pembullyan wajib dipilih';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Pilih Tipe Pembullyan',
          prefixIcon: Icon(Icons.category, color: Colors.red.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.red.shade50,
          contentPadding: const EdgeInsets.all(16),
        ),
      );
    }

    Widget _buildMediaSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambahkan Bukti',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMediaButton(
                  onPressed: _pickImages,
                  icon: Icons.photo_camera,
                  label: 'Foto',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildMediaButton(
                  onPressed: _pickVideos,
                  icon: Icons.videocam,
                  label: 'Video',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildMediaButton(
                  onPressed: _pickAudio,
                  icon: Icons.mic,
                  label: 'Audio',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_mediaFiles != null) _buildMediaPreview(),
          if (_videoFiles != null) _buildVideoPreview(),
          if (_audioFile != null) _buildAudioPreview(),
        ],
      );
    }

      Widget _buildMediaButton({
      required VoidCallback onPressed,
      required IconData icon,
      required String label,
      required Color color,
    }) {
      return Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

       Widget _buildMediaPreview() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto yang dipilih:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _mediaFiles!.map((file) {
              return GestureDetector(
                onTap: () {
                  // Menampilkan modal untuk melihat gambar secara detail
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              Image.file(
                                File(file.path),
                                fit: BoxFit.contain,
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(file.path),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

      Widget _buildVideoPreview() {
        if (_videoFiles == null || _videoFiles!.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video yang diunggah:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _videoFiles!.map((file) {
                return GestureDetector(
                  onTap: () async {
                    VideoPlayerController controller =
                        VideoPlayerController.file(file);
                    await controller.initialize();
                    controller.play();

                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: VideoPlayer(controller),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  controller.pause();
                                  controller.dispose();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.black26,
                      height: 100,
                      width: 100,
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 40),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }

      Widget _buildAudioPreview() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Audio yang diunggah:',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              // Menampilkan modal untuk memutar audio
              AudioPlayer audioPlayer = AudioPlayer();
              audioPlayer.setSourceDeviceFile(_audioFile!.path);
              audioPlayer.play(DeviceFileSource(_audioFile!.path));

              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Memutar Audio',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(_audioFile!.path.split('/').last),
                        const SizedBox(height: 16),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.redAccent),
                          onPressed: () {
                            audioPlayer.stop();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: ListTile(
              leading: const Icon(Icons.audiotrack, color: Colors.redAccent),
              title: Text(_audioFile?.path.split('/').last ?? ''),
              tileColor: Colors.red.shade50,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      );
    }

  Widget _buildSubmitSection() {
      return Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isSubmitting ? 60 : 200,
          height: 60,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Kirim Laporan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
          ),
        ),
      );
    }
}

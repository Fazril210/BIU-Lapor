import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart'; // Untuk mengatur orientasi layar

class BullyingEducationPage extends StatefulWidget {
  const BullyingEducationPage({super.key});

  @override
  _BullyingEducationPageState createState() => _BullyingEducationPageState();
}

class _BullyingEducationPageState extends State<BullyingEducationPage> {
  bool isDarkMode = false;
  late YoutubePlayerController _controller;

  int currentQuestionIndex = 0;
  int score = 0;
  final List<Map<String, dynamic>> quizQuestions = [
    {
      'question': 'Apa itu Bullying?',
      'answers': ['Perilaku agresif', 'Berbagi pendapat', 'Kerja sama', 'Berolahraga'],
      'correctAnswer': 'Perilaku agresif'
    },
    {
      'question': 'Di mana bullying biasanya terjadi?',
      'answers': ['Sekolah', 'Tempat kerja', 'Media sosial', 'Semua di atas'],
      'correctAnswer': 'Semua di atas'
    },
    {
      'question': 'Apa dampak dari bullying?',
      'answers': ['Peningkatan kesehatan', 'Kerusakan mental', 'Menambah teman', 'Menumbuhkan semangat'],
      'correctAnswer': 'Kerusakan mental'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the YoutubePlayerController with the video URL
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId('https://youtu.be/K3mAWQti0gU')!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  // Toggle theme mode
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edukasi Mengenai Bullying', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            'Apa itu Bullying?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 10),

          // Deskripsi Edukasi
          Text(
            'Bullying adalah perilaku agresif yang dilakukan oleh seseorang atau sekelompok orang dengan tujuan untuk menyakiti, mengintimidasi, atau merendahkan orang lain. Bullying dapat terjadi dalam berbagai bentuk, termasuk fisik, verbal, dan sosial.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.5,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Penjelasan tambahan mengenai bullying
          Text(
            'Bullying dapat berdampak negatif yang serius terhadap korban. Tidak hanya merusak kesehatan mental, tetapi juga dapat mempengaruhi hubungan sosial dan kualitas hidup korban. Tindakan bullying sering kali terjadi secara berulang dan bisa sangat merusak jika tidak segera dihentikan. Bullying juga dapat terjadi di berbagai tempat, termasuk di sekolah, tempat kerja, dan media sosial.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.5,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Ilustrasi
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://img.freepik.com/free-photo/high-angle-sad-teenager-school_23-2149583172.jpg',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                semanticLabel: 'Ilustrasi Bullying',
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Video Edukasi Button
          ElevatedButton.icon(
            onPressed: () {
              _showVideoModal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.play_arrow, color: Colors.white,),
            label: const Text('Tonton Video', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
    );
  }

  // Show modal with YouTube player
  void _showVideoModal(BuildContext context) {
    // Mengatur orientasi layar menjadi vertikal (portrait) sebelum menampilkan video
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Tentukan tinggi video modal
              double height = constraints.maxHeight * 0.6; // Default tinggi 60% dari layar

              // Menambahkan pengaturan tinggi modal jika dalam mode landscape
              if (MediaQuery.of(context).orientation == Orientation.landscape) {
                height = constraints.maxHeight; // Isi seluruh tinggi layar
              }

              return Stack(
                children: [
                  // SingleChildScrollView untuk menangani konten yang lebih besar
                  SingleChildScrollView(
                    child: SizedBox(
                      height: height,
                      child: Column(
                        children: [
                          // Menampilkan Video
                          Expanded(
                            child: YoutubePlayer(
                              controller: _controller,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.blue,
                              onReady: () {
                                print('Video is ready to play!');
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.pause),
                                onPressed: () {
                                  _controller.pause();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  _controller.play();
                                },
                              ),
                              PopupMenuButton<double>(
                                icon: const Icon(Icons.speed),
                                onSelected: (speed) {
                                  _controller.setPlaybackRate(speed);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 1.0,
                                    child: Text('1x'),
                                  ),
                                  const PopupMenuItem(
                                    value: 1.5,
                                    child: Text('1.5x'),
                                  ),
                                  const PopupMenuItem(
                                    value: 2.0,
                                    child: Text('2x'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

void _showQuizDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white, // Background dialog putih
        title: Text(
          'Kuis Bullying - Pertanyaan ${currentQuestionIndex + 1}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent, // Warna judul biru
          ),
        ),
        content: SingleChildScrollView(  // Menggunakan SingleChildScrollView untuk responsivitas
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quizQuestions[currentQuestionIndex]['question'],
                style: const TextStyle(fontSize: 16), // Ukuran font soal
              ),
              const SizedBox(height: 10),
              // Menampilkan pilihan jawaban dengan ElevatedButton
              ...quizQuestions[currentQuestionIndex]['answers'].map<Widget>((answer) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue, // Warna teks tombol putih
                      minimumSize: const Size(double.infinity, 50), // Lebar tombol responsif
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (answer == quizQuestions[currentQuestionIndex]['correctAnswer']) {
                        score++;
                      }
                      if (currentQuestionIndex < quizQuestions.length - 1) {
                        setState(() {
                          currentQuestionIndex++;
                        });
                        Navigator.pop(context); // Menutup dialog dan menampilkan soal selanjutnya
                        _showQuizDialog(context);
                      } else {
                        Navigator.pop(context); // Menutup dialog jika soal selesai
                        _showQuizResult(context);
                      }
                    },
                    child: Text(answer, textAlign: TextAlign.center),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    },
  );
}


  void _showQuizResult(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white, // Background dialog tetap putih
        title: const Text(
          'Kuis Selesai',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent, // Warna biru untuk judul
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skor Anda: $score/${quizQuestions.length}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue, // Warna biru untuk skor
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Menambahkan informasi tambahan atau gambar jika perlu
          ],
        ),
        actions: [
          // Tombol untuk mencoba lagi
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, // Warna teks tombol putih
                minimumSize: const Size(double.infinity, 50), // Lebar tombol responsif
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  currentQuestionIndex = 0;
                  score = 0;
                });
                Navigator.pop(context);
              },
              child: const Text('Coba Lagi'),
            ),
          ),
          // Tombol untuk menutup hasil
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.grey[300], // Warna teks tombol hitam
                minimumSize: const Size(double.infinity, 50), // Lebar tombol responsif
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            ),
          ),
        ],
      );
    },
  );
}

}

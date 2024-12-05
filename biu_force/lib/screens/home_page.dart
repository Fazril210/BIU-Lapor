import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:biu_force/screens/emergency_guide_page.dart';
import 'package:biu_force/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biu_force/screens/bullying_report.dart';
import 'package:biu_force/screens/chat.dart';
import 'package:biu_force/screens/consultation.dart';
import 'package:biu_force/screens/education_page.dart';
import 'package:biu_force/screens/emergency_contact.dart';
import 'package:biu_force/screens/history_page.dart';
import 'package:biu_force/screens/profile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      // Jika belum login, arahkan ke LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContentPage(),
    const AntiBullyingChatPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  @override
  void initState() {
    super.initState();    
    _checkLoginStatus();
  }
}

class HomeContentPage extends StatefulWidget {
  
  const HomeContentPage({super.key});

  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  // ignore: unused_field
  late Future<List<BullyingReport>> _typeReportsFuture;

  @override
  void initState() {
    super.initState();
    _typeReportsFuture = _fetchTypeReports();
    
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Background dengan gradasi modern
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Dekorasi lingkaran dengan efek blur
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent.withOpacity(0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightGreenAccent.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian header
                   Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(seconds: 2),
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade800,
                            Colors.green.shade600,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade300.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Bagian teks dengan animasi masuk dari kiri
                          const AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(seconds: 1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hai, Sobat!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Bersama kita lawan bullying',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Avatar dengan animasi scale saat di-hover
                        GestureDetector(
  child: AnimatedScale(
    scale: 1.1, // Slight scale-up effect when tapped
    duration: const Duration(milliseconds: 200),
    child: CircleAvatar(
      radius: 25,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png', 
          fit: BoxFit.cover,
          width: 64, 
          height: 64,
        ),
      ),
    ),
  ),
),

                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      _buildCarousel(),
                      const SizedBox(height: 20),
                      const Text(
                        'Fitur Utama',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        children: [
                          _buildFeatureCard(
                            icon: Icons.report_problem,
                            title: 'Lapor Bullying',
                            color: Colors.red.shade600,
                            context: context,
                            destinationPage: const ReportBullyingPage(),
                          ),
                          _buildFeatureCard(
                            icon: Icons.chat,
                            title: 'Konsultasi',
                            color: Colors.green.shade700,
                            context: context,
                            destinationPage: const ConsultationPage(npm: '',),
                          ),
                          _buildFeatureCard(
                            icon: Icons.help_outline,
                            title: 'Panduan',
                            color: Colors.redAccent.shade700,
                            context: context,
                            destinationPage:  EmergencyGuidePage(),
                          ),
                          _buildFeatureCard(
                            icon: Icons.emergency,
                            title: 'Kontak Darurat',
                            color: Colors.orange.shade400,
                            context: context,
                            destinationPage: const EmergencyContactsPage(),
                          ),
                          _buildFeatureCard(
                            icon: Icons.access_alarm,
                            title: 'Riwayat',
                            color: Colors.amber.shade600,
                            context: context,
                            destinationPage: HistoryReportsPage(),
                          ),
                          _buildFeatureCard(
                            icon: Icons.school,
                            title: 'Edukasi',
                            color: Colors.lightBlue.shade400,
                            context: context,
                            destinationPage: BullyingEducationPage(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Temukan Artikel Terbaru',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                  _buildArticleCarousel(), // Memanggil Carousel
                  const SizedBox(height: 20),
                    const Text(
                      'Grafik Tipe Bullying ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTypeReportChart(),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCarousel() {
  return FutureBuilder<List<Map<String, String>>>(
    future: _fetchArticlesFromFirestore(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(
          child: Text(
            'Tidak ada artikel tersedia.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      final articleList = snapshot.data!;

      // ignore: unused_local_variable
      int _currentIndex = 0;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CarouselSlider.builder(
            itemCount: articleList.length,
            options: CarouselOptions(
              height: 160,
              autoPlay: false,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                _currentIndex = index;
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final article = articleList[index];
              return GestureDetector(
                onTap: () {
                  _showArticleDialog(context, article['url']!);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['title']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Flexible(
                              child: Text(
                                article['description']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                'Baca Selengkapnya',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          const Text(
            "Geser ke kanan atau kiri untuk melihat lebih banyak artikel",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    },
  );
}


Future<List<Map<String, String>>> _fetchArticlesFromFirestore() async {
  try {
    // Ambil data dari koleksi Firestore
    final snapshot = await FirebaseFirestore.instance.collection('articles').get();

    // Map data Firestore ke List<Map<String, String>>
    return snapshot.docs.map((doc) {
      final data = doc.data();

      // Konversi semua nilai menjadi String
      return {
        'title': data['title']?.toString() ?? 'Judul Tidak Tersedia',
        'description': data['content']?.toString() ?? 'Deskripsi tidak tersedia.',
        'url': data['url']?.toString() ?? '',
      };
    }).toList();
  } catch (e) {
    print('Error fetching articles: $e');
    return [];
  }
}



  Future<List<BullyingReport>> _fetchTypeReports() async {
  try {
    // Ambil data dari koleksi Firestore
    final snapshot = await FirebaseFirestore.instance.collection('reports').get();

    if (snapshot.docs.isEmpty) {
      print('Tidak ada dokumen di koleksi reports');
      return [];
    }

    final Map<String, int> typeData = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final type = data['type'] as String? ?? 'Tidak Diketahui';

      // Hitung jumlah berdasarkan tipe
      if (typeData.containsKey(type)) {
        typeData[type] = typeData[type]! + 1;
      } else {
        typeData[type] = 1;
      }
    }

    print('Hasil typeData: $typeData'); // Debug

    // Ubah map menjadi daftar BullyingReport
    return typeData.entries
        .map((entry) => BullyingReport(entry.key, entry.value))
        .toList();
  } catch (e) {
    print('Error fetching type reports: $e');
    return [];
  }
}

Widget _buildTypeReportChart() {
  return FutureBuilder<List<BullyingReport>>(
    future: _fetchTypeReports(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(
          child: Text(
            'Tidak ada data untuk grafik tipe kasus.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      final reports = snapshot.data!;
      final maxReportCount = reports.map((r) => r.reportCount).reduce((a, b) => a > b ? a : b);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxReportCount.toDouble() + 2,
                  minY: 0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8.0),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final count = rod.toY.toInt();
                        final type = reports[groupIndex].type;
                        return BarTooltipItem(
                          '$type\n$count laporan',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxReportCount / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < reports.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  reports[index].type,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxReportCount / 5).ceilToDouble(),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  barGroups: reports.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.reportCount.toDouble(),
                          gradient: LinearGradient(
                            colors: [Colors.teal.shade400, Colors.green.shade600],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildCarousel() {
    final List<String> imgList = [
      'https://img.freepik.com/free-vector/cyber-bullying-concept_52683-41699.jpg',
      'https://img.freepik.com/free-vector/stop-bullying-text-with-cartoon-character_1308-119824.jpg',
      'https://img.freepik.com/free-vector/stop-bullying-illustration-concept_52683-40743.jpg',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        enlargeCenterPage: true,
      ),
      items: imgList
          .map((item) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(item, fit: BoxFit.cover, width: 1000),
                ),
              ))
          .toList(),
    );
  }

 Widget _buildFeatureCard({
  required IconData icon,
  required String title,
  required Color color,
  required BuildContext context,
  required Widget destinationPage,
}) {
  final screenWidth = MediaQuery.of(context).size.width;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destinationPage),
      );
    },
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(15),
          width: screenWidth * 0.4, // Lebar responsif
          height: constraints.maxWidth * 0.7, // Tambahkan tinggi kartu
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: constraints.maxWidth * 0.2, // Ikon responsif
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: AutoSizeText(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.13, // Ukuran font responsif
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 2, // Membatasi teks maksimal 2 baris
                  minFontSize: 10, // Ukuran minimum untuk font
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
}

void _showArticleDialog(BuildContext context, String url) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 1,
                child: WebViewWidget(
                  controller: WebViewController()..loadRequest(Uri.parse(url)),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}


class BullyingReport {
  final String type;
  final int reportCount;

  BullyingReport(this.type, this.reportCount);
}

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EmergencyGuidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan Tindakan Darurat',style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.redAccent.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
  children: [
    _buildStepSection(
      context: context,
      title: 'Jaga Jarak Aman',
      description:
          'Segera menjauh dari situasi bullying jika memungkinkan. Cari tempat yang aman.',
      icon: Icons.directions_run,
      color: Colors.redAccent.shade200,
      slides: [
        {
          'title': 'Contoh Situasi Bullying',
          'content':
              'Bullying dapat berupa ejekan, intimidasi verbal, atau ancaman fisik. Misalnya: Seorang siswa diolok-olok di depan teman-temannya di kelas atau tempat umum, yang menyebabkan rasa malu dan rendah diri. Ini juga bisa berupa pelecehan melalui media sosial yang dikenal sebagai cyberbullying, di mana pelaku menghina atau menyebarkan rumor palsu.',
          'image': 'https://awsimages.detik.net.id/community/media/visual/2022/01/17/bullying.jpeg?w=1200',
        },
        {
          'title': 'Langkah Jaga Jarak',
          'content':
              '1. Tinggalkan tempat kejadian secepatnya untuk menghindari eskalasi situasi.\n2. Temukan area yang ramai seperti ruang guru atau tempat umum di sekolah.\n3. Tetap tenang dan hindari menunjukkan emosi yang dapat memprovokasi pelaku lebih lanjut.\n4. Jika memungkinkan, ajak teman untuk ikut meninggalkan tempat untuk mendukung Anda.',
          'image': 'https://mysiloam-api.siloamhospitals.com/storage-down/website-cms/website-cms-16950988898357998.webp',
        },
        {
          'title': 'Tips Preventif',
          'content':
              '1. Hindari tempat sepi, terutama jika Anda tahu tempat tersebut sering digunakan untuk tindakan bullying.\n2. Selalu berjalan bersama teman jika memungkinkan untuk meningkatkan keamanan.\n3. Laporkan segera lokasi yang sering menjadi tempat kejadian kepada pihak sekolah atau petugas keamanan agar tindakan preventif dapat dilakukan.',
          'image': 'https://www.new-indonesia.org/wp-content/uploads/2019/07/Program-Roots-Upaya-Pencegahan-Bullying-di-Sekolah.jpg',
        },
      ],
    ),
    _buildStepSection(
      context: context,
      title: 'Cari Bantuan',
      description:
          'Hubungi orang dewasa yang dapat dipercaya, seperti guru, konselor, atau orang tua.',
      icon: Icons.phone,
      color: Colors.orange.shade300,
      slides: [
        {
          'title': 'Tahapan Hubungi Bantuan',
          'content':
              '1. Laporkan kejadian kepada guru atau staf sekolah terdekat untuk mendapatkan perlindungan langsung.\n2. Hubungi konselor kampus untuk bimbingan psikologis lebih lanjut terkait dampak bullying.\n3. Anda juga dapat menghubungi lembaga perlindungan anak melalui nomor: 021-12345678 untuk tindakan lanjutan dan dukungan hukum jika diperlukan.',
          'image': 'https://cdn.idntimes.com/content-images/community/2022/10/pexels-polina-zimmerman-3958375-97ae06e75a95eb7595641ab869500840-f074a090f25f98b890d01c62c1db8e3a_600x400.jpg',
        },
        {
          'title': 'Apa yang Dibutuhkan?',
          'content':
              'Ketika melapor, pastikan Anda memberikan informasi selengkap mungkin, termasuk waktu kejadian, lokasi spesifik, nama atau ciri-ciri pelaku, saksi yang melihat kejadian, dan bukti seperti foto atau rekaman jika ada. Ini akan membantu proses penanganan menjadi lebih efektif.',
          'image': 'https://d1vbn70lmn1nqe.cloudfront.net/prod/wp-content/uploads/2022/07/29103110/image_8.Ini-Alasan-Anak-Jadi-Pelaku-Bullying.jpg.webp',
        },
      ],
    ),
    _buildStepSection(
      context: context,
      title: 'Catat Kejadian',
      description:
          'Catat atau ingat detail kejadian untuk membantu laporan.',
      icon: Icons.note_alt,
      color: Colors.blue.shade300,
      slides: [
        {
          'title': 'Apa yang Dicatat?',
          'content':
              '1. Tanggal dan waktu kejadian untuk mencocokkan kronologi.\n2. Lokasi spesifik kejadian seperti ruang kelas atau taman sekolah.\n3. Nama saksi atau pelaku jika diketahui, termasuk ciri-ciri fisik mereka.\n4. Detail kronologi kejadian, seperti bagaimana bullying dimulai dan reaksi dari saksi atau korban.',
          'image': 'https://st3.depositphotos.com/14431644/18603/i/450/depositphotos_186035494-stock-photo-conceptual-hand-writing-text-caption.jpg',
        },
        {
          'title': 'Fungsi Catatan',
          'content':
              'Catatan ini sangat penting untuk membantu pihak berwenang dalam menyelidiki kasus dengan lebih cepat. Ini juga membantu memastikan bahwa setiap detail tidak terlewatkan ketika Anda memberikan laporan kepada pihak terkait.',
          'image': 'https://st3.depositphotos.com/14431644/18601/i/450/depositphotos_186017596-stock-photo-handwritten-text-showing-stop-bullying.jpg',
        },
      ],
    ),
  ],
),

      ),
    );
  }

  Widget _buildStepSection({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<Map<String, String>> slides,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StepDetailPage(
                title: title,
                slides: slides,
              ),
            ),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(description),
        ),
      ),
    );
  }
}

class StepDetailPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> slides;

  const StepDetailPage({
    required this.title,
    required this.slides,
  });

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: slides.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final slide = slides[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 8.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Gambar dengan efek overlay
                        if (slide['image'] != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16.0)),
                                child: Image.network(
                                  slide['image']!,
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image,
                                        size: 100, color: Colors.grey);
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    slide['title']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        // Konten Deskripsi
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            slide['content']!,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Indikator Modern
          SmoothPageIndicator(
            controller: pageController,
            count: slides.length,
            effect: ExpandingDotsEffect(
              dotHeight: 10,
              dotWidth: 10,
              expansionFactor: 4,
              activeDotColor: Colors.redAccent,
              dotColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

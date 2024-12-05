import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {

  @override
  void initState() {
    super.initState();
    // No need to call WebViewPlatform.instance?.initialize() anymore.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Artikel',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Temukan Artikel Terbaru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(25, 118, 210, 1),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView(
                  children: [
                    _buildArticleCard(
                      'Kenali Tanda-tanda Bullying',
                      'Pelajari bagaimana mengenali tanda-tanda bullying sejak dini...',
                      Colors.purpleAccent.shade100,
                      context,
                      'https://www.halodoc.com/artikel/ini-5-tanda-tanda-bullying-pada-anak-yang-perlu-diketahui?srsltid=AfmBOop4hN9dZBQkSInPvPS_9E0MEMcIBhNnAAHwiIFgOImNq9h4d8QW',
                    ),
                    const SizedBox(height: 15),
                    _buildArticleCard(
                      'Cara Menghadapi Bullying',
                      'Tips dan strategi untuk menghadapi situasi bullying...',
                      Colors.lightBlueAccent.shade100,
                      context,
                      'https://blog.maukuliah.id/7-cara-mengatasi-bullying/', 
                    ),
                    const SizedBox(height: 15),
                    _buildArticleCard(
                      'Pentingnya Melaporkan Bullying',
                      'Memahami pentingnya melaporkan kasus bullying...',
                      Colors.greenAccent.shade100,
                      context,
                      'https://www.margasari.desa.id/pentingnya-melaporkan-bullying-memberikan-suara-untuk-anak-anak',
                    ),
                    const SizedBox(height: 15),
                    _buildArticleCard(
                      'Peran Orang Tua dalam Mencegah Bullying',
                      'Bagaimana orang tua dapat berperan dalam mencegah bullying...',
                      Colors.orangeAccent.shade100,
                      context,
                      'https://www.bener.desa.id/pencegahan-bullying-di-rumah-peran-orang-tua-dan-keluarga/', 
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(
      String title, String subtitle, Color color, BuildContext context, String url) {
    return GestureDetector(
      onTap: () {
        // Navigate to the article page or show a modal with the specific URL
        _showArticleDialog(context, url);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.8),
                  child: const Icon(Icons.article, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Baca Selengkapnya',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.indigo,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
              child: WebViewWidget(
                controller: WebViewController()..loadRequest(Uri.parse(url)),
              ),
            ),
            Positioned(
              bottom: 10, // Positioned at the bottom
              right: 10,  // Positioned at the right
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.red, // Icon color white to stand out
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

}

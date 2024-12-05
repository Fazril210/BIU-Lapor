import 'package:biu_force/screens/login_page.dart';
import 'package:flutter/material.dart';
import '../utils/preferences.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Future<void> _setFirstTimeStatus() async {
    await Preferences.setFirstTime(false);
  }

  @override
  Widget build(BuildContext context) {
    _setFirstTimeStatus();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'assets/logo.png', // Pastikan Anda memiliki logo di folder assets/images
                height: 120,
              ),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang di BIU Lapor!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bersama kita melawan bullying.\nDapatkan perlindungan, edukasi, dan bantuan cepat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              _buildFeatureTile(
                icon: Icons.shield,
                title: 'Perlindungan',
                description:
                    'Dapatkan akses untuk melaporkan bullying dengan aman dan terjamin.',
              ),
              _buildFeatureTile(
                icon: Icons.school,
                title: 'Edukasi',
                description:
                    'Pelajari cara mencegah bullying dan membantu sesama.',
              ),
              _buildFeatureTile(
                icon: Icons.support_agent,
                title: 'Bantuan Cepat',
                description:
                    'Konsultasi dengan ahli kapan saja, di mana saja untuk perlindungan lebih lanjut.',
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Selanjutnya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

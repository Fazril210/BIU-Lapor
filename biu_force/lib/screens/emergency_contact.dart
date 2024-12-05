  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
  import 'package:url_launcher/url_launcher.dart';
  import 'package:font_awesome_flutter/font_awesome_flutter.dart';

  class EmergencyContactsPage extends StatelessWidget {
    const EmergencyContactsPage({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Kontak Darurat',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          backgroundColor: Colors.amber.shade700,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hubungi Kami',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Segera hubungi nomor-nomor berikut jika mengalami situasi darurat atau membutuhkan bantuan.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildContactCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Nomor Darurat',
                    subtitle: '112',
                    color: Colors.redAccent,
                    context: context,
                    onTap: () async {
                      final Uri phoneUri = Uri(scheme: '112');
                        if (await canLaunch(phoneUri.toString())) {
                          await launch(phoneUri.toString());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Tidak dapat melakukan panggilan.')),
                          );
                        }
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildContactCard(
                      icon: Icons.email_rounded,
                      title: 'Email Pengaduan',
                      subtitle: 'forcebiu041@gmail.com',
                      color: Colors.blueAccent,
                      context: context,
                      onTap: () async {},
                      ),
                  const SizedBox(height: 15),
                  _buildContactCard(
                    icon: Icons.location_on_rounded,
                    title: 'Kantor Pusat',
                    subtitle: 'Jl. Raya Siliwangi No.6, RT.001/RW.004, Sepanjang Jaya, Kec. Rawalumbu, Kota Bks, Jawa Barat 17114',
                    color: Colors.green,
                    context: context,
                    onTap: () async {
                      final Uri mapsUri =
                          Uri.parse('https://maps.app.goo.gl/U4dnwUwnVqsUMJrt6');
                      if (await canLaunch(mapsUri.toString())) {
                        await launch(mapsUri.toString());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tidak dapat membuka Maps.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Section for Teacher Contacts with 3x3 grid layout
                  const Text(
                    'Daftar Kontak Dosen',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Use an Expanded widget for the GridView
                SizedBox(
                    height: 400,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('contacts') // Replace with your collection
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Gagal memuat kontak guru.',
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'Belum ada kontak guru yang tersedia.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          );
                        }

                        final contacts = snapshot.data!.docs;

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final contact = contacts[index].data()
                                as Map<String, dynamic>; // Cast to Map

                            return _buildTeacherContactCard(
                              imageUrl: contact['photopath'] != null
                                  ? 'https://example.com/${contact['photopath']}'
                                  : 'https://via.placeholder.com/150',
                              name: contact['name'] ?? 'Tidak diketahui',
                              contact: contact['notelp'] ?? '-',
                              role_teacher: contact['role_teacher'] ?? '-',
                              context: context, 
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }


    Widget _buildContactCard({
      required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required BuildContext context,
      required Future<void> Function() onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
        ),
      );
    }

  Widget _buildTeacherContactCard({
    required String imageUrl,
    required String name,
    required String contact,
    required String role_teacher,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Modal Indicator
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Profile Image
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipOval(
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  // Role
                  Text(
                    'Role: $role_teacher',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  // Contact Info Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.amber, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            contact,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Call Button
                      ElevatedButton.icon(
onPressed: () async {
  try {
    // Format nomor telepon ke format internasional
    String formattedContact = contact.startsWith('08')
        ? contact.replaceFirst('08', '628')
        : contact;

    // Pesan WhatsApp
    String message =
        "Halo $name, ini adalah pesan dari tim kami. Silakan hubungi kami jika ada pertanyaan.";

    // URL WhatsApp
    final Uri whatsappUri = Uri.parse(
        'https://wa.me/$formattedContact?text=${Uri.encodeComponent(message)}');

    // Debugging log untuk memeriksa nomor dan URL
    debugPrint('Nomor yang digunakan: $formattedContact');
    debugPrint('URL WhatsApp: $whatsappUri');

    // Coba buka WhatsApp
    bool canOpen = await canLaunchUrl(whatsappUri);

    if (canOpen) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Jika tidak dapat membuka WhatsApp, tampilkan pesan kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  } catch (e) {
    // Penanganan jika terjadi error
    debugPrint('Error launching WhatsApp: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan saat membuka WhatsApp.')),
    );
  }
},






    icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
    label: const Text(
      'Hubungi',
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
    ),
  ),

                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Image
            ClipOval(
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              role_teacher,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  }

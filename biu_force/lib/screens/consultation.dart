import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Konsultasi App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: ConsultationPage(npm: '12345678'), // Example NPM
    );
  }
}

class ConsultationPage extends StatefulWidget {
  final String npm;

  const ConsultationPage({super.key, required this.npm});

  @override
  _ConsultationPageState createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Map<String, dynamic>? selectedCounselor;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController problemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeFirestoreData();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    emailController.dispose();
    problemController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          setState(() {
            nameController.text = data['name'] ?? '';
            emailController.text = user.email ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<void> _initializeFirestoreData() async {
    final counselorsCollection =
        FirebaseFirestore.instance.collection('counselors');
    final counselorsSnapshot = await counselorsCollection.get();

    if (counselorsSnapshot.docs.isEmpty) {
      final defaultCounselors = [
        {
          'name': 'Guru Konseling 1',
          'role': 'Guru Konseling',
          'image': 'https://via.placeholder.com/150',
          'workingDays': ['Monday', 'Wednesday', 'Friday'],
          'workingHours': {'start': '09:00', 'end': '17:00'},
        },
        {
          'name': 'Guru Konseling 2',
          'role': 'Psikolog Anak',
          'image': 'https://via.placeholder.com/150',
          'workingDays': ['Tuesday', 'Thursday'],
          'workingHours': {'start': '10:00', 'end': '16:00'},
        },
      ];

      for (final counselor in defaultCounselors) {
        await counselorsCollection.add(counselor);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.teal, Colors.tealAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  title: const Text(
    'Konsultasi',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 25,
      color: Colors.white,
    ),
  ),
bottom: TabBar(
  controller: _tabController,
  labelColor: Colors.white, // Warna teks dan ikon aktif
  unselectedLabelColor: Colors.black, // Warna teks dan ikon tidak aktif
  indicator: BoxDecoration(
    color: Colors.teal, // Warna latar belakang tab aktif
    borderRadius: BorderRadius.circular(25), // Membuat sudut melengkung
  ),
  indicatorPadding: const EdgeInsets.symmetric(horizontal: -20, vertical: 8), // Padding untuk background
  tabs: [
    Tab(icon: Icon(Icons.person), text: 'Konselor'),
    Tab(icon: Icon(Icons.schedule), text: 'Jadwal'),
    Tab(icon: Icon(Icons.history), text: 'Riwayat'),
  ],
),

),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCounselorList(),
          _buildScheduleForm(),
          _buildAppointmentHistory(),
        ],
      ),
    );
  }

  Tab _buildTabItem(IconData icon, String text) {
    return Tab(
      icon: Icon(icon, size: 22),
      text: text,
    );
  }

  Widget _buildCounselorList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('counselors').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada konselor tersedia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final counselors = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: counselors.length,
          itemBuilder: (context, index) {
            final counselor = counselors[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 5,
              shadowColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedCounselor = counselor;
                  });
                  _tabController.animateTo(1);
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          counselor['image'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              counselor['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              counselor['role'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.teal.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScheduleForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (selectedCounselor != null) ...[
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(selectedCounselor!['image']),
                ),
                title: Text(selectedCounselor!['name']),
                subtitle: Text(selectedCounselor!['role']),
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildTextField('Nama Lengkap', nameController, Icons.person),
          const SizedBox(height: 15),
          _buildTextField('Email', emailController, Icons.email),
          const SizedBox(height: 15),
          _buildTextField(
            'Masalah Anda',
            problemController,
            Icons.message,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          _buildDatePicker(),
          const SizedBox(height: 15),
          _buildTimePicker(),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
            onPressed: isLoading ? null : _submitAppointment,
            icon: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.check),
            label: const Text('Konfirmasi Janji Temu'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String hintText, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      leading: const Icon(Icons.calendar_today, color: Colors.teal),
      title: Text(
        selectedDate == null
            ? 'Pilih Tanggal'
            : DateFormat('yyyy-MM-dd').format(selectedDate!),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (picked != null) {
          setState(() {
            selectedDate = picked;
            selectedTime = null;
          });
        }
      },
    );
  }

  Widget _buildTimePicker() {
    if (selectedDate == null || selectedCounselor == null) {
      return const Text('Pilih Tanggal dan Konselor terlebih dahulu.');
    }

    return FutureBuilder<List<String>>(
      future: _getAvailableTimes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Tidak ada waktu tersedia.');
        }

        final times = snapshot.data!;

        return DropdownButton<TimeOfDay>(
          isExpanded: true,
          value: selectedTime,
          hint: const Text('Pilih Waktu'),
          items: times.map((time) {
            final parsedTime = TimeOfDay(
              hour: int.parse(time.split(':')[0]),
              minute: int.parse(time.split(':')[1]),
            );
            return DropdownMenuItem<TimeOfDay>(
              value: parsedTime,
              child: Text(time),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedTime = value;
            });
          },
        );
      },
    );
  }

  Future<List<String>> _getAvailableTimes() async {
    final counselorSnapshot = await FirebaseFirestore.instance
        .collection('counselors')
        .where('name', isEqualTo: selectedCounselor?['name'])
        .get();

    if (counselorSnapshot.docs.isEmpty) {
      return [];
    }

    final counselor = counselorSnapshot.docs.first.data();
    final workingDays = List<String>.from(counselor['workingDays']);
    final workingHours = counselor['workingHours'] as Map<String, dynamic>;

    final dayName = DateFormat('EEEE').format(selectedDate!);
    if (!workingDays.contains(dayName)) {
      return [];
    }

    final startHour = int.parse(workingHours['start'].split(':')[0]);
    final endHour = int.parse(workingHours['end'].split(':')[0]);
    final allTimes = List.generate(endHour - startHour, (i) {
      return "${startHour + i}:00";
    });

    final reservedTimesSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('counselor', isEqualTo: selectedCounselor?['name'])
        .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate!))
        .get();

    final reservedTimes = reservedTimesSnapshot.docs.map((doc) {
      return doc['time'] as String;
    }).toList();

    return allTimes.where((time) => !reservedTimes.contains(time)).toList();
  }

  Future<void> _submitAppointment() async {
    if (selectedDate == null ||
        selectedTime == null ||
        nameController.text.isEmpty ||
        emailController.text.isEmpty) {
      _showCustomSnackBar('Mohon lengkapi semua data!', Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final existingAppointment = await FirebaseFirestore.instance
          .collection('appointments')
          .where('counselor', isEqualTo: selectedCounselor?['name'])
          .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate!))
          .where('time', isEqualTo: selectedTime!.format(context))
          .get();

      if (existingAppointment.docs.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
        _showCustomSnackBar('Waktu ini sudah diambil.', Colors.orange);
        return;
      }

      await FirebaseFirestore.instance.collection('appointments').add({
        'counselor': selectedCounselor?['name'],
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'time': selectedTime!.format(context),
        'status': 'Pending',
        'user': {
          'npm': widget.npm,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
        },
      });

      setState(() {
        isLoading = false;
        nameController.clear();
        emailController.clear();
        selectedCounselor = null;
        selectedDate = null;
        selectedTime = null;
      });

      _showCustomSnackBar('Janji temu berhasil dibuat!', Colors.teal);
      _tabController.animateTo(2);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showCustomSnackBar('Gagal membuat janji temu.', Colors.red);
    }
  }

  void _showCustomSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildAppointmentHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('user.npm', isEqualTo: widget.npm)
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada janji temu.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final appointments = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index].data() as Map<String, dynamic>;
            final status = appointment['status'] ?? 'Pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: Text(
                  appointment['counselor'] ?? 'Tidak diketahui',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${appointment['date']} - ${appointment['time']}'),
                    const SizedBox(height: 5),
                    Text(
                      'Status: $status',
                      style: TextStyle(
                        color: status == 'Approved'
                            ? Colors.green
                            : (status == 'Rejected'
                                ? Colors.red
                                : Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

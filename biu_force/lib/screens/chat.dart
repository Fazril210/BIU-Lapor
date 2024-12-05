import 'package:flutter/material.dart';

class AntiBullyingChatPage extends StatefulWidget {
  const AntiBullyingChatPage({super.key});

  @override
  _AntiBullyingChatPageState createState() => _AntiBullyingChatPageState();
}

class _AntiBullyingChatPageState extends State<AntiBullyingChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // List for messages with user info

  @override
void initState() {
  super.initState();
  // Adding a welcome message and available keywords when chat starts
  _messages.add({
    'message': 'Halo! Saya adalah chatbot Anti-Bullying. Berikut adalah beberapa kata kunci yang bisa Anda gunakan:\n'
        '1. Laporkan Bullying\n'
          '2. Kontak Darurat\n'
          '3. Informasi Bantuan\n'
          '4. Baca Artikel atau Info Lebih Lanjut\n'
      'Masukkan saja angka untuk mengetahui informasi sesuai dengan nomornya!',
    'isUserMessage': false,
  });
}


  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      String userMessage = _controller.text;

      setState(() {
        _messages.add({
          'message': userMessage,
          'isUserMessage': true,
        });
      });
      _controller.clear();

      // Respond with a simple rule-based chatbot logic
      String botResponse = _getBotResponse(userMessage);
      
      // Simulate a delay for bot response
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            'message': botResponse,
            'isUserMessage': false,
          });
        });
      });
    }
  }

  // Simple rule-based response logic for the chatbot
String _getBotResponse(String userMessage) {
  switch (userMessage.trim()) {
     case '1':
        return 'Anda dapat melaporkan kasus bullying melalui menu Lapor Bullying. Tindakan Anda sangat penting untuk membantu menciptakan lingkungan yang lebih aman.';
      case '2':
        return 'Jika Anda membutuhkan bantuan segera, gunakan menu Kontak Darurat untuk menghubungi pihak berwenang atau layanan darurat.';
      case '3':
        return 'Kami menyediakan informasi yang relevan untuk membantu Anda. Jika Anda perlu saran atau dukungan, jelajahi menu bantuan yang tersedia.';
      case '4':
        return 'Anda dapat membaca artikel tentang bullying di menu Artikel. Alternatifnya, gunakan internet untuk menemukan informasi lebih lanjut yang Anda butuhkan.';
      default:
        return 'Maaf, saya tidak mengerti. Silakan pilih nomor dari 1 hingga 4 atau tanyakan sesuatu yang lain.';
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anti-Bullying Chat", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUserMessage = message['isUserMessage'];

                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.green.shade100 : Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade300.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message['message'],
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan di sini...",
                      filled: true,
                      fillColor: Colors.green.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(50.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade300.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
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
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🍫 Detector de Vainas Abortadas',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Roboto',
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HistoryItem {
  final String date;
  final String result;
  final Uint8List? imageBytes;
  final File? originalImage;

  HistoryItem({
    required this.date,
    required this.result,
    this.imageBytes,
    this.originalImage,
  });
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  bool _loading = false;
  String? _resultText;
  Uint8List? _resultImageBytes;
  List<HistoryItem> _history = [];
  bool _showHistory = false;

  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _resultText = null;
        _resultImageBytes = null;
        _showHistory = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _resultText = null;
        _resultImageBytes = null;
        _showHistory = false;
      });
    }
  }

  Future<void> _sendToBackend() async {
    if (_image == null) return;

    setState(() {
      _loading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://despliegue-modelo-vx85.onrender.com/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', _image!.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final int vainas = jsonResponse["vainas_abortadas"];
        final String imgBase64 = jsonResponse["image"];

        final resultText = "🌱 Vainas abortadas detectadas: $vainas";
        final resultImageBytes = base64Decode(imgBase64);

        // Agregar al historial
        setState(() {
          _resultText = resultText;
          _resultImageBytes = resultImageBytes;
          _history.insert(0, HistoryItem(
            date: DateTime.now().toString().substring(0, 16),
            result: resultText,
            imageBytes: resultImageBytes,
            originalImage: _image,
          ));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultText)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error en servidor: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Excepción: $e")),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  void _clearAll() {
    setState(() {
      _image = null;
      _resultText = null;
      _resultImageBytes = null;
      _loading = false;
    });
  }

  void _toggleHistory() {
    setState(() {
      _showHistory = !_showHistory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEBE9),
      appBar: AppBar(
        title: Text('🍫 Detector de Vainas Abortadas'),
        backgroundColor: Color(0xFF5D4037),
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _toggleHistory,
            tooltip: 'Ver historial',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (!_showHistory) ...[
                const SizedBox(height: 10),
                Text(
                  "🌿 Sube una imagen de mazorca de cacao para detectar las vainas abortadas 🍃",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4E342E),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(_image!, height: 250),
                  ),
                if (_loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(color: Colors.brown),
                  ),
                if (_resultText != null) ...[
                  const SizedBox(height: 20),
                  Text("📊 Resultado:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_resultText!, style: TextStyle(fontSize: 16)),
                ],
                if (_resultImageBytes != null) ...[
                  const SizedBox(height: 20),
                  Text("🖼️ Imagen con detecciones:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(_resultImageBytes!, height: 250),
                  ),
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _customButton(Icons.image, "Galería", _getImage, Colors.green),
                    _customButton(Icons.camera_alt, "Cámara", _takePhoto, Colors.teal),
                    _customButton(Icons.send, "Enviar", _sendToBackend, Colors.brown),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: _clearAll,
                  icon: Icon(Icons.delete, color: Colors.white),
                  label: Text("Limpiar", style: TextStyle(color: Colors.white)),
                ),
              ] else ...[
                const SizedBox(height: 10),
                Text(
                  "📜 Historial de Análisis",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF4E342E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (_history.isEmpty)
                  Text("No hay registros en el historial", style: TextStyle(fontSize: 16)),
                ..._history.map((item) => _buildHistoryItem(item)).toList(),
              ],
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(HistoryItem item) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.date, style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _history.remove(item);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.result),
            const SizedBox(height: 10),
            if (item.imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(item.imageBytes!, height: 150),
              ),
            const SizedBox(height: 10),
            if (item.originalImage != null)
              Text("Imagen original:", style: TextStyle(fontStyle: FontStyle.italic)),
            if (item.originalImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(item.originalImage!, height: 100),
              ),
          ],
        ),
      ),
    );
  }

  Widget _customButton(IconData icon, String label, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}
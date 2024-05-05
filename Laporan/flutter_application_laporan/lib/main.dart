import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Paket untuk membuat permintaan HTTP
import 'dart:convert'; // Paket untuk mengonversi JSON
import 'package:url_launcher/url_launcher.dart'; // Paket untuk membuka URL
import 'package:provider/provider.dart'; // Paket untuk manajemen keadaan aplikasi

class Universitas {
  final String nama;
  final String situs;

  Universitas({required this.nama, required this.situs});

  // Konstruktor factory untuk membuat objek Universitas dari JSON
  factory Universitas.fromJson(Map<String, dynamic> json) {
    return Universitas(
      nama: json['name'] ?? 'Nama Tidak Tersedia',
      situs: json['web_pages'] != null && json['web_pages'].isNotEmpty
          ? json['web_pages'][0]
          : 'Website Tidak Tersedia',
    );
  }
}

class UniversitasProvider extends ChangeNotifier {
  late List<Universitas> _universitasList; // Daftar universitas
  late String _selectedCountry; // Negara yang dipilih

  UniversitasProvider() {
    _universitasList = [];
    _selectedCountry = 'Indonesia'; // Negara default
    fetchUniversitasList(_selectedCountry); // Ambil daftar universitas
  }

  // Getter untuk daftar universitas
  List<Universitas> get universitasList => _universitasList;

  // Getter untuk negara yang dipilih
  String get selectedCountry => _selectedCountry;

  // Metode untuk mengambil daftar universitas dari API
  Future<void> fetchUniversitasList(String country) async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _universitasList =
          data.map((json) => Universitas.fromJson(json)).toList();
      notifyListeners(); // Beri tahu konsumen tentang perubahan
    } else {
      throw Exception('Failed to fetch universities');
    }
  }

  // Metode untuk mengatur negara yang dipilih dan memperbarui daftar universitas
  void setSelectedCountry(String country) {
    _selectedCountry = country;
    fetchUniversitasList(_selectedCountry);
  }
}

class UniversitasList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universitasProvider = Provider.of<UniversitasProvider>(context);
    final universitasList = universitasProvider.universitasList;

    // Tampilkan daftar universitas dalam ListView
    return ListView.builder(
      itemCount: universitasList.length,
      itemBuilder: (context, index) {
        final universitas = universitasList[index];
        return ListTile(
          title: Text(universitas.nama),
          subtitle: Text(universitas.situs),
          onTap: () {
            launch(universitas.situs); // Buka situs universitas ketika di tap
          },
        ); 
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universitasProvider = Provider.of<UniversitasProvider>(context);

    // Tampilkan UI dengan DropdownButton untuk memilih negara dan UniversitasList untuk menampilkan daftar universitas
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: universitasProvider.selectedCountry,
            items: [
              'Indonesia',
              'Malaysia',
              'Singapore',
              'Thailand',
              'Brunei Darussalam',
              'Vietnam',
              'Philippines',
              'Myanmar',
              'Cambodia',
              'Laos',
              // Tambahkan negara ASEAN lainnya di sini
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              universitasProvider.setSelectedCountry(newValue!);
            },
          ),
          Expanded(
            child: UniversitasList(),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    // Menjalankan aplikasi dengan ChangeNotifierProvider sebagai root widget
    ChangeNotifierProvider(
      // Membuat instance dari UniversitasProvider untuk manajemen keadaan aplikasi
      create: (context) => UniversitasProvider(),
      // MaterialApp adalah root widget yang menyediakan struktur dasar aplikasi
      child: MaterialApp(
        // MyApp adalah halaman utama aplikasi
        home: MyApp(),
      ),
    ),
  );
}
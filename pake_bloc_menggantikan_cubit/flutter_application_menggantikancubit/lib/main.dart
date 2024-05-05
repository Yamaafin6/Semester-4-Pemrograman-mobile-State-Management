import 'package:flutter/material.dart'; // Import library untuk pengembangan UI menggunakan Flutter
import 'package:flutter_bloc/flutter_bloc.dart'; // Import library untuk Flutter Bloc
import 'package:http/http.dart' as http; // Import library untuk membuat permintaan HTTP
import 'dart:convert'; // Import library untuk mengonversi JSON
import 'package:url_launcher/url_launcher.dart'; // Import library untuk membuka URL

// Event untuk memperbarui daftar universitas berdasarkan negara yang dipilih.
class UniversityEvent {
  final String country;

  UniversityEvent(this.country); // Konstruktor untuk event, menerima negara sebagai parameter
}

// State untuk menampung daftar universitas.
class UniversityState {
  final List<Universitas> universities; // List untuk menyimpan objek Universitas

  UniversityState(this.universities); // Konstruktor state, menerima daftar universitas sebagai parameter
}

// Bloc untuk mengelola daftar universitas.
class UniversityBloc extends Bloc<UniversityEvent, UniversityState> {
  UniversityBloc() : super(UniversityState([])); // Inisialisasi Bloc dengan state awal kosong

  @override
  Stream<UniversityState> mapEventToState(UniversityEvent event) async* {
    yield UniversityState(await _fetchUniversitasList(event.country)); // Menghasilkan state baru dengan daftar universitas yang diperbarui
  }

  // Metode untuk mengambil daftar universitas dari server.
  Future<List<Universitas>> _fetchUniversitasList(String country) async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country')); // Melakukan permintaan HTTP untuk mendapatkan data universitas berdasarkan negara

    if (response.statusCode == 200) { // Jika permintaan berhasil
      final List<dynamic> data = json.decode(response.body); // Mendekode respon JSON
      return data.map((json) => Universitas.fromJson(json)).toList(); // Mengonversi data JSON menjadi objek Universitas dan mengembalikan daftar universitas
    } else {
      throw Exception('Failed to fetch universities'); // Jika permintaan gagal, lemparkan pengecualian
    }
  }
}

// Model untuk merepresentasikan data universitas
class Universitas {
  final String nama; // Nama universitas
  final String situs; // URL situs web universitas

  Universitas({required this.nama, required this.situs}); // Konstruktor dengan parameter wajib

  // Konstruktor factory untuk membuat objek Universitas dari JSON
  factory Universitas.fromJson(Map<String, dynamic> json) {
    return Universitas(
      nama: json['name'] ?? 'Nama Tidak Tersedia', // Ambil nama universitas, jika tidak tersedia, gunakan nilai default
      situs: json['web_pages'] != null && json['web_pages'].isNotEmpty
          ? json['web_pages'][0] // Ambil URL situs web universitas pertama jika tersedia
          : 'Website Tidak Tersedia', // Jika tidak ada URL, gunakan nilai default
    );
  }
}

// Widget untuk menampilkan daftar universitas dalam bentuk ListView
class UniversitasList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UniversityBloc, UniversityState>(
      builder: (context, state) {
        if (state.universities.isEmpty) { // Jika daftar universitas kosong
          return Center(
            child: CircularProgressIndicator(), // Tampilkan indikator progres
          );
        } else { // Jika daftar universitas tidak kosong
          return ListView.builder(
            itemCount: state.universities.length, // Jumlah item dalam daftar adalah panjang daftar universitas
            itemBuilder: (context, index) {
              final universitas = state.universities[index]; // Ambil objek universitas pada indeks tertentu
              return ListTile(
                title: Text(universitas.nama), // Tampilkan nama universitas
                subtitle: Text(universitas.situs), // Tampilkan URL situs web universitas
                onTap: () {
                  launch(universitas.situs); // Buka situs web universitas saat item di tap
                },
              );
            },
          );
        }
      },
    );
  }
}

void main() {
  runApp(MyApp()); // Panggil fungsi runApp untuk menjalankan aplikasi
}

// Widget utama aplikasi
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => UniversityBloc()..add(UniversityEvent('Indonesia')), // Inisialisasi Bloc dan kirim event untuk memperbarui daftar universitas
        child: HomePage(), // Widget utama aplikasi
      ),
    );
  }
}

// Halaman utama aplikasi
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// State dari widget halaman beranda
class _HomePageState extends State<HomePage> {
  late String selectedCountry; // Variabel untuk menyimpan negara yang dipilih

  @override
  void initState() {
    super.initState();
    selectedCountry = 'Indonesia'; // Set nilai awal negara yang dipilih
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas'), // Judul halaman
        actions: [
          BlocBuilder<UniversityBloc, UniversityState>(
            builder: (context, state) {
              return DropdownButton<String>(
                value: selectedCountry, // Nilai dropdown adalah negara yang dipilih
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedCountry = newValue; // Perbarui nilai negara yang dipilih
                    });
                    context.read<UniversityBloc>().add(UniversityEvent(newValue)); // Kirim event untuk memperbarui daftar universitas
                  }
                },
                items: <String>[
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
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Tampilkan nama negara dalam dropdown
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      body: UniversitasList(), // Widget untuk menampilkan daftar universitas
    );
  }
}

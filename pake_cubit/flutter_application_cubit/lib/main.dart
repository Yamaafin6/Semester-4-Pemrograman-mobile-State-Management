import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Paket untuk Flutter Bloc
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// Model untuk merepresentasikan data universitas
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

// Cubit untuk mengelola negara yang dipilih dan daftar universitas yang ditampilkan.
class UniversityCubit extends Cubit<List<Universitas>> {
  UniversityCubit() : super([]);

  // Memperbarui daftar universitas berdasarkan negara yang dipilih.
  void updateUniversities(String country) async {
    final universities = await _fetchUniversitasList(country);
    emit(universities);
  }

  // Mengambil data daftar universitas dari server.
  Future<List<Universitas>> _fetchUniversitasList(String country) async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Universitas.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch universities');
    }
  }
}

// Widget untuk menampilkan daftar universitas dalam bentuk ListView
class UniversitasList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UniversityCubit, List<Universitas>>(
      builder: (context, state) {
        if (state.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
            itemCount: state.length,
            itemBuilder: (context, index) {
              final universitas = state[index];
              return ListTile(
                title: Text(universitas.nama),
                subtitle: Text(universitas.situs),
                onTap: () {
                  launch(universitas.situs);
                },
              );
            },
          );
        }
      },
    );
  }
}

// Titik masuk utama aplikasi
void main() {
  runApp(MyApp());
}

// Widget utama aplikasi
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => UniversityCubit()..updateUniversities('Indonesia'),
        child: HomePage(),
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
  late String selectedCountry;

  @override
  void initState() {
    super.initState();
    selectedCountry = 'Indonesia'; // Set nilai awal negara yang dipilih
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Menjadikan judul AppBar berada di tengah
        title: DropdownButton<String>( // Menambahkan DropdownButton di dalam judul AppBar
          value: selectedCountry, // Menggunakan nilai variabel selectedCountry sebagai nilai default
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedCountry = newValue; // Memperbarui nilai selectedCountry ketika dipilih
              });
              context.read<UniversityCubit>().updateUniversities(newValue);
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
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      body: UniversitasList(),
    );
  }
}

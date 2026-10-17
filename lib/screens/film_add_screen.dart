// lib/screens/film_add_screen.dart

import 'package:flutter/material.dart';
import '../models/film.dart';
import '../services/api_service.dart';

class FilmAddScreen extends StatefulWidget {
  const FilmAddScreen({Key? key}) : super(key: key);

  
  @override
  // ignore: library_private_types_in_public_api
  _FilmAddScreenState createState() => _FilmAddScreenState();
}

class _FilmAddScreenState extends State<FilmAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _yonetmenController = TextEditingController();
  final _yapimYiliController = TextEditingController();
  final _turController = TextEditingController();
  final _imdbPuaniController = TextEditingController();
  final _ozetController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _addFilm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final film = Film(
          baslik: _baslikController.text,
          yonetmen: _yonetmenController.text.isEmpty
              ? null
              : _yonetmenController.text,
          yapimYili: int.tryParse(_yapimYiliController.text),
          tur: _turController.text.isEmpty ? null : _turController.text,
          imdbPuani: double.tryParse(_imdbPuaniController.text),
          ozet: _ozetController.text.isEmpty ? null : _ozetController.text,
        );

        await _apiService.createFilm(film);

        if (!mounted) return; // Async boşluktan sonra mounted kontrolü

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Film başarıyla eklendi')), // unnecessary_const için const düzenlendi
        );

        if (!mounted) return; // Async boşluktan sonra mounted kontrolü
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return; // Async boşluktan sonra mounted kontrolü

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ekleme hatası: ${e.toString()}')),
        );
      } finally {
        // if (!mounted) return; // İsteğe bağlı
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _yonetmenController.dispose();
    _yapimYiliController.dispose();
    _turController.dispose();
    _imdbPuaniController.dispose();
    _ozetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Film Ekle'), // const eklendi
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // unnecessary_const için const düzenlendi
          : Padding(
              padding: const EdgeInsets.all(16.0), // const eklendi
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _baslikController,
                      decoration: const InputDecoration(
                          labelText: 'Film Adı *'), // const eklendi
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen film adını girin';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _yonetmenController,
                      decoration: const InputDecoration(
                          labelText: 'Yönetmen'), // const eklendi
                    ),
                    TextFormField(
                      controller: _yapimYiliController,
                      decoration: const InputDecoration(
                          labelText: 'Yapım Yılı'), // const eklendi
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            int.tryParse(value) == null) {
                          return 'Geçerli bir yıl girin';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _turController,
                      decoration: const InputDecoration(
                          labelText: 'Tür'), // const eklendi
                    ),
                    TextFormField(
                      controller: _imdbPuaniController,
                      decoration: const InputDecoration(
                          labelText: 'IMDb Puanı (örn: 8.7)'), // const eklendi
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final puan = double.tryParse(value);
                          if (puan == null) {
                            return 'Geçerli bir puan girin';
                          }
                          if (puan < 0 || puan > 10) {
                            return 'Puan 0 ile 10 arasında olmalı';
                          }
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _ozetController,
                      decoration: const InputDecoration(
                          labelText: 'Özet'), // const eklendi
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20), // const eklendi
                    ElevatedButton(
                      onPressed: _isLoading ? null : _addFilm,
                      child: const Text('Filmi Kaydet'), // const eklendi
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

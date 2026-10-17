// lib/screens/film_update_screen.dart

import 'package:flutter/material.dart';
import '../models/film.dart';
import '../services/api_service.dart';

class FilmUpdateScreen extends StatefulWidget {
  final int filmId;

  const FilmUpdateScreen({Key? key, required this.filmId}) : super(key: key);

  // ignore: library_private_types_in_public_api // library_private_types_in_public_api uyarısını bastır
  @override
  // ignore: library_private_types_in_public_api
  _FilmUpdateScreenState createState() => _FilmUpdateScreenState();
}

class _FilmUpdateScreenState extends State<FilmUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _yonetmenController = TextEditingController();
  final _yapimYiliController = TextEditingController();
  final _turController = TextEditingController();
  final _imdbPuaniController = TextEditingController();
  final _ozetController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Film? _currentFilm;

  @override
  void initState() {
    super.initState();
    _loadFilmData();
  }

  Future<void> _loadFilmData() async {
    try {
      final film = await _apiService.getFilmById(widget.filmId);

      if (!mounted) return; // Async boşluktan sonra mounted kontrolü

      setState(() {
        _currentFilm = film;
        _baslikController.text = film.baslik;
        _yonetmenController.text = film.yonetmen ?? '';
        _yapimYiliController.text = film.yapimYili?.toString() ?? '';
        _turController.text = film.tur ?? '';
        _imdbPuaniController.text = film.imdbPuani?.toString() ?? '';
        _ozetController.text = film.ozet ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Async boşluktan sonra mounted kontrolü

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Film verisi yüklenemedi: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateFilm() async {
    if (_formKey.currentState!.validate() && _currentFilm != null) {
      setState(() {
        // _isLoading = true;
      });

      try {
        final updatedFilm = Film(
          filmId: _currentFilm!.filmId, // ID'yi koru
          baslik: _baslikController.text,
          yonetmen: _yonetmenController.text.isEmpty
              ? null
              : _yonetmenController.text,
          yapimYili: int.tryParse(_yapimYiliController.text),
          tur: _turController.text.isEmpty ? null : _turController.text,
          imdbPuani: double.tryParse(_imdbPuaniController.text),
          ozet: _ozetController.text.isEmpty ? null : _ozetController.text,
        );

        await _apiService.updateFilm(widget.filmId, updatedFilm);

        if (!mounted) return; // Async boşluktan sonra mounted kontrolü

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Film başarıyla güncellendi'),
          ), // const eklendi
        );

        if (!mounted) return; // Async boşluktan sonra mounted kontrolü
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return; // Async boşluktan sonra mounted kontrolü

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme hatası: ${e.toString()}')),
        );
      } finally {
        // if (!mounted) return; // İsteğe bağlı olarak buraya da eklenebilir
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
    _yapimYiliController.dispose(); // 'Yonetmen' yerine 'Yili' düzeltmesi
    _turController.dispose();
    _imdbPuaniController.dispose();
    _ozetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_currentFilm?.baslik ?? "Film"} Güncelle')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // const eklendi
          : Padding(
              padding: const EdgeInsets.all(16.0), // const eklendi
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _baslikController,
                      decoration: const InputDecoration(
                        labelText: 'Film Adı *',
                      ), // const eklendi
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
                        labelText: 'Yönetmen',
                      ), // const eklendi
                    ),
                    TextFormField(
                      controller: _yapimYiliController, // Controller ismi doğru
                      decoration: const InputDecoration(
                        labelText: 'Yapım Yılı',
                      ), // const eklendi
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
                        labelText: 'Tür',
                      ), // const eklendi
                    ),
                    TextFormField(
                      controller: _imdbPuaniController,
                      decoration: const InputDecoration(
                        labelText: 'IMDb Puanı (örn: 8.7)',
                      ), // const eklendi
                      // ignore: prefer_const_constructors
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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
                        labelText: 'Özet',
                      ), // const eklendi
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20), // const eklendi
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateFilm,
                      // ... (FilmUpdateScreen'daki ElevatedButton'ın child parametresi)
                      child: const Text('Filmi Güncelle'), // const eklendi
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

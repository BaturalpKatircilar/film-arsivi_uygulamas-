// lib/screens/film_list_screen.dart

import 'package:flutter/material.dart';
import '../models/film.dart';
import '../services/api_service.dart';
import 'film_update_screen.dart';

class FilmListScreen extends StatefulWidget {
  const FilmListScreen({Key? key}) : super(key: key);

  // ignore: library_private_types_in_public_api // library_private_types_in_public_api uyarısını bastır
  @override
  // ignore: library_private_types_in_public_api
  _FilmListScreenState createState() => _FilmListScreenState();
}

class _FilmListScreenState extends State<FilmListScreen> {
  late Future<List<Film>> _filmler;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _filmler = _apiService.getFilmler();
  }

  void _refreshFilmler() {
    setState(() {
      _filmler = _apiService.getFilmler();
    });
  }

  Future<void> _deleteFilm(int filmId) async {
    try {
      await _apiService.deleteFilm(filmId);

      if (!mounted) return; // Async boşluktan sonra mounted kontrolü

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Film başarıyla silindi')), // unnecessary_const için const düzenlendi
      );
      _refreshFilmler();
    } catch (e) {
      if (!mounted) return; // Async boşluktan sonra mounted kontrolü

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme hatası: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Listesi'), // const eklendi
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // const eklendi
            onPressed: _refreshFilmler,
            tooltip: 'Listeyi Yenile',
          ),
        ],
      ),
      body: FutureBuilder<List<Film>>(
        future: _filmler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // unnecessary_const için const düzenlendi
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
                    'Hiç film bulunamadı.')); // unnecessary_const için const düzenlendi
          } else {
            List<Film> filmler = snapshot.data!;
            return ListView.builder(
              itemCount: filmler.length,
              itemBuilder: (context, index) {
                Film film = filmler[index];
                // Dismissible widget'ı ve içindeki child'lar film verisine bağlı olduğu için
                // const olamazlar. const_with_non_const hatası alınıyorsa buradaki const kaldırılmalıydı.
                // Kodun son hali const_with_non_const hatasını gidermeli.
                return Dismissible(
                  // Buradaki const kaldırıldıysa doğru (const_with_non_const hatası için)
                  key: Key(film.filmId.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    // const eklendi
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0), // const eklendi
                    child: const Icon(Icons.delete,
                        color: Colors.white), // const eklendi
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          // Burası const olabilir eğer tüm childları const ise
                          title: const Text("Silmeyi Onayla"), // const eklendi
                          content: Text(
                              "${film.baslik} adlı filmi silmek istediğinizden emin misiniz?"), // Film verisine bağlı olduğu için AlertDialog const olamaz
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("İptal"), // const eklendi
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Sil"), // const eklendi
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    if (film.filmId != null) {
                      _deleteFilm(film.filmId!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Bu filmin ID bilgisi eksik, silinemiyor.')), // unnecessary_const için const düzenlendi
                      );
                    }
                  },
                  child: ListTile(
                    title: Text(film.baslik), // Film verisine bağlı
                    subtitle: Text(
                        '${film.yonetmen ?? "Bilinmiyor"} - ${film.yapimYili ?? "Bilinmiyor"} - Puan: ${film.imdbPuani ?? "-"}'), // Film verisine bağlı
                    trailing: IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red), // const eklendi
                      onPressed: () => _deleteFilm(film.filmId!),
                    ),
                    onTap: () {
                      if (film.filmId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilmUpdateScreen(
                                filmId: film
                                    .filmId!), // Film verisine bağlı olduğu için MaterialPageRoute const olamaz
                          ),
                        ).then((_) => _refreshFilmler());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Bu filmin ID bilgisi eksik, güncellenemiyor.')), // unnecessary_const için const düzenlendi
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add').then((_) => _refreshFilmler());
        },
        tooltip: 'Yeni Film Ekle',
        child: const Icon(Icons.add), // const eklendi
      ),
    );
  }
}

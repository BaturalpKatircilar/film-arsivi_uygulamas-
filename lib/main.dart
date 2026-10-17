
import 'package:flutter/material.dart';
import './screens/film_list_screen.dart';
import './screens/film_add_screen.dart';

void main() {
  runApp(const MyApp()); // const eklendi
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film Arşivi Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(), 
        '/list': (context) => const FilmListScreen(), 
        '/add': (context) => const FilmAddScreen(),
      },
      onUnknownRoute: (settings) {
        // ignore: avoid_print
        print('Bilinmeyen rota: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
        ); // const eklendi
      },
    );
  }
}

class HomePage extends StatelessWidget {
  // super.key kullanımı
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Arşivi Ana Sayfa'), 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text(
                'Filmleri Görüntüle ve Yönet (Listeleme/Silme)',
              ), // const eklendi
              onPressed: () {
                Navigator.pushNamed(context, '/list');
              },
            ),
            const SizedBox(height: 20), 
            ElevatedButton(
              child: const Text('Yeni Film Ekle'), 
              onPressed: () {
                Navigator.pushNamed(context, '/add');
              },
            ),
          ],
        ),
      ),
    );
  }
}

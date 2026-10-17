// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/film.dart';

class ApiService {
  // ############################################################
  // BACKEND WEB SERVISİNİZİN URL'Sİ
  // LÜTFEN BURAYI KENDİ BACKEND URL'NİZ İLE DEĞİŞTİRİN!
  // Örnek: "http://10.0.2.2:5000" (Android Emülatör için)
  // Örnek: "http://localhost:5000" (iOS Simülatör veya bazı durumlarda Android)
  // Örnek: "http://192.168.1.x:5000" (Fiziksel cihaz ve bilgisayar aynı ağda)
  // ############################################################
  final String baseUrl =
      "http://192.168.1.162:5000"; // <-- Flutter Web (aynı bilgisayarda) için bu URL'yi kullanın

  Future<List<Film>> getFilmler() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/filmler'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((filmJson) => Film.fromJson(filmJson)).toList();
      } else {
        // ignore: avoid_print
        print('Filmleri çekerken hata oluştu: ${response.statusCode}');
        // ignore: avoid_print
        print('Hata Body: ${response.body}');
        throw Exception(
          'Filmler yüklenemedi. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Ağ hatası oluştu: $e');
      throw Exception('Filmleri çekerken ağ hatası oluştu: $e');
    }
  }

  Future<Film> getFilmById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/filmler/$id'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return Film.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw Exception('Film bulunamadı.');
      } else {
        // ignore: avoid_print
        print('Filmi çekerken hata oluştu: ${response.statusCode}');
        // ignore: avoid_print
        print('Hata Body: ${response.body}');
        throw Exception(
          'Film detayları yüklenemedi. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Ağ hatası oluştu: $e');
      throw Exception('Film detaylarını çekerken ağ hatası oluştu: $e');
    }
  }

  Future<Film> createFilm(Film film) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/filmler'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(film.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return Film.fromJson(jsonResponse);
      } else {
        // ignore: avoid_print
        print('Film eklerken hata oluştu: ${response.statusCode}');
        // ignore: avoid_print
        print('Hata Body: ${response.body}');
        throw Exception('Film eklenemedi. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Ağ hatası oluştu: $e');
      throw Exception('Film eklerken ağ hatası oluştu: $e');
    }
  }

  Future<Film> updateFilm(int id, Film film) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/filmler/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(film.toJson()),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return Film.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw Exception('Güncellenecek film bulunamadı.');
      } else {
        // ignore: avoid_print
        print('Film güncellerken hata oluştu: ${response.statusCode}');
        // ignore: avoid_print
        print('Hata Body: ${response.body}');
        throw Exception(
          'Film güncellenemedi. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Ağ hatası oluştu: $e');
      throw Exception('Film güncellerken ağ hatası oluştu: $e');
    }
  }

  Future<void> deleteFilm(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/filmler/$id'));

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Silinecek film bulunamadı.');
      } else {
        // ignore: avoid_print
        print('Film silerken hata oluştu: ${response.statusCode}');
        // ignore: avoid_print
        print('Hata Body: ${response.body}');
        throw Exception('Film silinemedi. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Ağ hatası oluştu: $e');
      throw Exception('Film silerken ağ hatası oluştu: $e');
    }
  }
}

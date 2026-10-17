// lib/models/film.dart

// import 'package:flutter/material.dart'; // Gerekli değil

class Film {
  final int? filmId;
  final String baslik;
  final String? yonetmen;
  final int? yapimYili;
  final String? tur;
  final double? imdbPuani;
  final String? ozet;
  final DateTime? eklenmeTarihi;

  Film({
    this.filmId,
    required this.baslik,
    this.yonetmen,
    this.yapimYili,
    this.tur,
    this.imdbPuani,
    this.ozet,
    this.eklenmeTarihi,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    final dynamic baslikDynamic = json['baslik'];
    final String? baslikString = baslikDynamic as String?;

    if (baslikString == null || baslikString.isEmpty) {
      throw const FormatException(
          'JSON verisinde "baslik" alanı eksik, null veya boş.');
    }
    final String finalBaslik = baslikString;

    final dynamic imdbDynamic = json['imdb_puani'];
   // ignore: prefer_const_constructors // Linter bu satır için gereksiz const öneriyor
    final double? imdbPuaniValue = imdbDynamic is num ? imdbDynamic.toDouble() : null;
    
    

    final dynamic eklenmeTarihiDynamic = json['eklenme_tarihi'];
    final DateTime? eklenmeTarihiValue = eklenmeTarihiDynamic is String
        ? DateTime.tryParse(eklenmeTarihiDynamic)
        : null;

    final dynamic ozetDynamic = json['ozet'];
    final String? ozetValue = ozetDynamic is String ? ozetDynamic : null;

    // ignore: prefer_const_constructors // prefer_const_constructors uyarısını bastır
    return Film(
      filmId: json['film_id'],
      baslik: finalBaslik,
      yonetmen: json['yonetmen'],
      yapimYili: json['yapim_yili'],
      tur: json['tur'],
      imdbPuani: imdbPuaniValue,
      ozet: ozetValue,
      eklenmeTarihi: eklenmeTarihiValue,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'baslik': baslik,
      'yonetmen': yonetmen,
      'yapim_yili': yapimYili,
      'tur': tur,
      'imdb_puani': imdbPuani,
      'ozet': ozet,
    };
    if (filmId != null) {
      json['film_id'] = filmId;
    }
    return json;
  }
}

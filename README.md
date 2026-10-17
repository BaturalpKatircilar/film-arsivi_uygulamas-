# 🎬 Film Arşivi (Movie Archive App)

Bu proje, kullanıcıların film bilgilerini ekleyip yönetebileceği, tam yığın (full-stack) mimari ile geliştirilmiş bir mobil uygulamadır. Geliştirme sürecinde modern mobil teknolojiler ve güçlü bir ilişkisel veritabanı mimarisi bir arada kullanılmıştır.

## 🚀 Teknolojiler (Tech Stack)

**Frontend (Mobil Uygulama):**
* [Flutter](https://flutter.dev/) (Dart)
* HTTP paketleri ile RESTful API iletişimi

**Backend (API Sunucusu):**
* [Python](https://www.python.org/) 3.x
* Flask (Web Framework)
* Flask-CORS
* psycopg2 (PostgreSQL Sürücüsü)

**Veritabanı:**
* [PostgreSQL](https://www.postgresql.org/) 16

## ✨ Özellikler
* **CRUD İşlemleri:** Film ekleme, listeleme, güncelleme ve silme (Create, Read, Update, Delete).
* **RESTful Mimari:** İsteklerin HTTP standartlarına (GET, POST, PUT, DELETE) uygun olarak yönetilmesi.
* **Çapraz Platform:** Tek bir kod tabanı üzerinden Android (ve potansiyel olarak iOS/Web) desteği.

## 🛠️ Yerelde Kurulum ve Çalıştırma (Local Setup)

Bu projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin.

### 1. Veritabanı Kurulumu
1. PostgreSQL kurun ve pgAdmin'i açın.
2. `film_arsivi_db` adında yeni bir veritabanı oluşturun.
3. Aşağıdaki SQL sorgusu ile gerekli tabloyu oluşturun:

```sql
CREATE TABLE filmler (
    film_id SERIAL PRIMARY KEY,
    baslik VARCHAR(255) NOT NULL,
    yonetmen VARCHAR(255),
    yapim_yili INTEGER,
    tur VARCHAR(100),
    imdb_puani DECIMAL(3, 1),
    ozet TEXT,
    eklenme_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. Backend (Python/Flask) Kurulumu
1. Backend dizininde gerekli kütüphaneleri yükleyin:
   `pip install flask flask-cors psycopg2`
2. `app.py` içerisindeki veritabanı bağlantı bilgilerini (kullanıcı adı, şifre) kendi sisteminize göre güncelleyin.
3. Sunucuyu başlatın:
   `python app.py`
*(Sunucu varsayılan olarak `http://0.0.0.0:5000` adresinde çalışacaktır.)*

### 3. Frontend (Flutter) Kurulumu
1. Flutter projesinin bağımlılıklarını indirin:
   `flutter pub get`
2. **ÖNEMLİ:** `lib/services/api_service.dart` dosyasını açın. Eğer fiziksel bir cihazda (Android/iOS) test ediyorsanız, `baseUrl` değişkenini backend'in çalıştığı bilgisayarın yerel IP adresi ile değiştirin (Örn: `http://192.168.1.X:5000`).

## 📄 Lisans
Bu proje [MIT Lisansı](LICENSE) ile lisanslanmıştır. Serbestçe kullanılabilir ve geliştirilebilir.

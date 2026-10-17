from flask_cors import CORS
from flask import Flask, request, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import decimal 
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}}) 

# ################################################################
# Veritabanı Bağlantı Bilgileri
# LÜTFEN BURADAKİ YER TUTUCULARI KENDİ BİLGİLERİNİZLE DEĞİŞTİRİN!
# ################################################################
DB_HOST = os.environ.get("DB_HOST", "localhost") # <-- Kendi DB hostunuz
DB_NAME = os.environ.get("DB_NAME", "film_arsivi_db") # <-- Kendi DB adınız
DB_USER = os.environ.get("DB_USER", "postgres") # <-- Kendi DB kullanıcı adınız
DB_PASS = os.environ.get("DB_PASS", "") # <-- Kendi DB şifreniz
DB_PORT = os.environ.get("DB_PORT", "5432") # <-- Kendi DB portunuz (varsayılan 5432)

def get_db_connection():
    """Veritabanı bağlantısı oluşturur."""
    conn = None
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            port=DB_PORT
        )
    except psycopg2.OperationalError as e:
        print(f"Veritabanı bağlantı hatası: {e}")
        raise e
    return conn

# Helper function to format data from DB for JSON
def format_film_data(film):
    """RealDictRow veya dictionary formatındaki film verisindeki Decimal tiplerini float'a çevirir."""
    # Gelen veriyi kopyalayarak üzerinde değişiklik yapıyoruz
    film_dict = dict(film)

    # imdb_puani Decimal ise float'a çevir
    if isinstance(film_dict.get('imdb_puani'), decimal.Decimal):
        film_dict['imdb_puani'] = float(film_dict['imdb_puani'])
        
    # eklenme_tarihi datetime ise isoformat string'e çevir (RealDictCursor bunu zaten yapabilir)
    # eklenme_tarihi = film_dict.get('eklenme_tarihi')
    # if isinstance(eklenme_tarihi, datetime): # datetime import etmek gerekir
    #    film_dict['eklenme_tarihi'] = eklenme_tarihi.isoformat()

    return film_dict

# ################################################################
# API Endpointleri
# ################################################################

# Tüm filmleri listeleme (READ - GET)
@app.route('/filmler', methods=['GET'])
def get_filmler():
    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor) # Sonuçları dictionary olarak alırız
        cursor.execute("SELECT film_id, baslik, yonetmen, yapim_yili, tur, imdb_puani, ozet, eklenme_tarihi FROM filmler;")
        filmler = cursor.fetchall()

        # Decimal tipini JSON'a çevirirken float'a dönüştür
        filmler_formatted = [format_film_data(film) for film in filmler]

        return jsonify(filmler_formatted)

    except psycopg2.OperationalError:
        return jsonify({"error": "Veritabanı bağlantı hatası"}), 500
    except Exception as e:
        # ignore: avoid_print # Hata basılabilir
        print(f"Hata oluştu: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# Belirli bir filmi getirme (READ - GET by ID)
@app.route('/filmler/<int:film_id>', methods=['GET'])
def get_film(film_id):
    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("SELECT film_id, baslik, yonetmen, yapim_yili, tur, imdb_puani, ozet, eklenme_tarihi FROM filmler WHERE film_id = %s;", (film_id,))
        film = cursor.fetchone()

        if film is None:
            return jsonify({"message": "Film bulunamadı"}), 404

        # Decimal tipini float'a dönüştür
        film_formatted = format_film_data(film)

        return jsonify(film_formatted)

    except psycopg2.OperationalError:
        return jsonify({"error": "Veritabanı bağlantı hatası"}), 500
    except Exception as e:
        # ignore: avoid_print # Hata basılabilir
        print(f"Hata oluştu: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# Yeni film ekleme (CREATE - POST)
@app.route('/filmler', methods=['POST'])
def create_film():
    new_film_data = request.json 

    # Basit validasyon: 'baslik' alanı zorunlu ve boş olmamalı
    if not new_film_data or not new_film_data.get('baslik'):
        return jsonify({"error": "Eksik veya boş film başlığı bilgisi"}), 400 # Bad Request

    baslik = new_film_data.get('baslik')
    yonetmen = new_film_data.get('yonetmen')
    yapim_yili = new_film_data.get('yapim_yili')
    tur = new_film_data.get('tur')
    imdb_puani = new_film_data.get('imdb_puani')
    ozet = new_film_data.get('ozet')

    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor() 

        # INSERT sorgusu ve RETURNING film_id ile eklenen kaydın ID'sini alıyoruz
        cursor.execute(
            "INSERT INTO filmler (baslik, yonetmen, yapim_yili, tur, imdb_puani, ozet) VALUES (%s, %s, %s, %s, %s, %s) RETURNING film_id;",
            (baslik, yonetmen, yapim_yili, tur, imdb_puani, ozet) # Değerler tuple olarak verilir
        )
        new_film_id = cursor.fetchone()[0] # Yeni ID'yi al
        conn.commit() # Değişiklikleri veritabanına kaydet

        # Eklenen filmin detaylarını çekip döndürelim
        cursor = conn.cursor(cursor_factory=RealDictCursor) # Fetch için RealDictCursor kullan
        cursor.execute("SELECT film_id, baslik, yonetmen, yapim_yili, tur, imdb_puani, ozet, eklenme_tarihi FROM filmler WHERE film_id = %s;", (new_film_id,))
        created_film = cursor.fetchone()

        if created_film:
             created_film_formatted = format_film_data(created_film)
             return jsonify(created_film_formatted), 201 
        else:
             
             print(f"Film ID {new_film_id} eklendi ancak detayları çekilemedi.")
             return jsonify({"message": "Film başarıyla eklendi, ancak detayları alınamadı"}), 201


    except psycopg2.OperationalError:
        if conn: conn.rollback()
        return jsonify({"error": "Veritabanı bağlantı hatası"}), 500
    except Exception as e:
        if conn: conn.rollback()
        
        print(f"Hata oluştu: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# Filmi güncelleme (UPDATE - PUT)
@app.route('/filmler/<int:film_id>', methods=['PUT'])
def update_film(film_id):
    update_data = request.json # Gelen JSON verisini al

    if not update_data:
        return jsonify({"error": "Güncellenecek bilgi yok"}), 400 # Bad Request

    # Sadece gelen alanları güncellemek için dinamik sorgu hazırlığı
    update_fields = {}
    if 'baslik' in update_data: update_fields['baslik'] = update_data['baslik']
    if 'yonetmen' in update_data: update_fields['yonetmen'] = update_data['yonetmen']
    if 'yapim_yili' in update_data: update_fields['yapim_yili'] = update_data['yapim_yili']
    if 'tur' in update_data: update_fields['tur'] = update_data['tur']
    if 'imdb_puani' in update_data: update_fields['imdb_puani'] = update_data['imdb_puani']
    if 'ozet' in update_data: update_fields['ozet'] = update_data['ozet']

    if not update_fields: 
        return jsonify({"error": "Güncellenecek geçerli alan bulunamadı"}), 400

    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Güncelleme sorgusunu dinamik olarak oluştur
        set_clauses = [f"{key} = %s" for key in update_fields.keys()]
        sql = f"UPDATE filmler SET {', '.join(set_clauses)} WHERE film_id = %s;"

        # Sorguya geçirilecek değerleri hazırla: update_fields'ın değerleri + film_id
        values = list(update_fields.values()) + [film_id]

        cursor.execute(sql, tuple(values))

        if cursor.rowcount == 0: # Hiç satır etkilenmediyse film bulunamamış olabilir
            conn.rollback()
            return jsonify({"message": "Film bulunamadı veya güncellenecek bir değişiklik yok"}), 404

        conn.commit()

        # Güncellenen filmin detaylarını döndürebiliriz (isteğe bağlı)
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute("SELECT film_id, baslik, yonetmen, yapim_yili, tur, imdb_puani, ozet, eklenme_tarihi FROM filmler WHERE film_id = %s;", (film_id,))
        updated_film = cursor.fetchone()

        if updated_film:
            updated_film_formatted = format_film_data(updated_film)
            return jsonify(updated_film_formatted), 200 # 200 OK status code
        else:
            # ignore: avoid_print # Hata basılabilir
            print(f"Film ID {film_id} güncellendi ancak detayları çekilemedi.")
            return jsonify({"message": "Film başarıyla güncellendi, ancak detayları alınamadı"}), 200

    except psycopg2.OperationalError:
        if conn: conn.rollback()
        return jsonify({"error": "Veritabanı bağlantı hatası"}), 500
    except Exception as e:
        if conn: conn.rollback()
        # ignore: avoid_print # Hata basılabilir
        print(f"Hata oluştu: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# Filmi silme (DELETE)
@app.route('/filmler/<int:film_id>', methods=['DELETE'])
def delete_film(film_id):
    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM filmler WHERE film_id = %s;", (film_id,))

        if cursor.rowcount == 0: # Hiç satır etkilenmediyse film bulunamamış olabilir
            conn.rollback()
            return jsonify({"message": "Film bulunamadı"}), 404

        conn.commit()

        return jsonify({"message": "Film başarıyla silindi"}), 200 # 200 OK status code

    except psycopg2.OperationalError:
        if conn: conn.rollback()
        return jsonify({"error": "Veritabanı bağlantı hatası"}), 500
    except Exception as e:
        if conn: conn.rollback()
        # ignore: avoid_print # Hata basılabilir
        print(f"Hata oluştu: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()



if __name__ == '__main__':
    
    app.run(debug=True, host='0.0.0.0', port=5000)
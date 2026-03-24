# 🕌 Kaza Namazı & Kur'an Takip (Habit Tracker)

Modern Android Material Design 3 (M3) prensipleriyle geliştirilmiş, oyunlaştırma (gamification) odaklı Kaza Namazı ve Kur'an-ı Kerim okuma takip uygulaması. 

Kullanıcıların geçmiş namaz borçlarını kapatmalarını ve günlük Kur'an okuma alışkanlığı kazanmalarını motive edici bir arayüzle sağlar. Geleneksel "kalan devasa borç" vurgusu yerine, "başarılan adımlara" ve serilere (streak) odaklanır.

---

## ✨ Temel Özellikler

* **🕹️ Oyunlaştırma & Seviye Sistemi:** Kılınan her kaza namazı için motivasyon puanı kazanılır. Kademeli zorlaşan seviye (Level) sistemi ile kullanıcı sürekli motive edilir.
* **📅 Zinciri Kırma (Streak) Takvimi:** GitHub contribution grafiğinden ilham alan, günlük kaza namazı ve Kur'an okuma performansını gösteren dinamik renkli ısı haritası (Heatmap).
* **📊 Detaylı İstatistikler & Grafikler:** Haftalık/aylık performans grafikleri ve şeffaf borç/başarı tablosu.
* **📜 Geçmiş Dökümü:** Her vakte özel (Sabah, Öğle, İkindi, Akşam, Yatsı, Vitir) hangi gün kaç adet kaza kılındığını gösteren detaylı log/geçmiş sayfası.
* **⚡ Hızlı & Kolay Kullanım:** Ana ekrandan tek tıkla sayfa/kaza ekleme, yanlış işlemleri anında "Geri Al" (Undo) özelliği ile düzeltme.
* **🎨 Material Design 3:** Tamamen güncel M3 standartlarında; dinamik renkler, ferah kartlar ve pürüzsüz animasyonlar.
* **🌍 Türkçe Desteği:** Tamamen Türkçe arayüz ve tarih formatlaması.

---

## 🛠️ Kullanılan Teknolojiler

| Teknoloji | Amaç |
| --- | --- |
| **[Flutter](https://flutter.dev/)** | Cross-platform mobil uygulama geliştirme |
| **[Riverpod](https://riverpod.dev/)** | Reactif state management ve iş mantığı |
| **[Sqflite](https://pub.dev/packages/sqflite)** | Yerel ilişkisel veritabanı (SQLite) |
| **[Material Design 3](https://m3.material.io/)** | Modern, uyumlu ve accessible UI/UX |
| **[Intl](https://pub.dev/packages/intl)** | Uluslararasılaştırma (Türkçe tarih formatlaması) |

---

## � Proje Hakkında

Bu proje, **vibe koding** felsefesiyle geliştirilen bir hobi projesidir. Eğlenceli, yaratıcı ve rahat bir ortamda, yazılım geliştirmenin sanatsal yönünü keşfetmek amacıyla oluşturulmuştur. Her feature, detaylı araştırma ve düşünülerek eklenmiştir. Kurumsal kalitede bir ürün sunmanın yanı sıra, geliştirme sürecinde yaşanan deneyim ve öğrenim sürecine de değer verilmektedir.

---

## �📂 Proje Klasör Yapısı

```
lib/
├── main.dart                          # Uygulama başlangıç noktası
├── providers/                         # Riverpod state providers
│   ├── database_provider.dart         # Database provider
│   ├── kaza_logs_provider.dart        # Kaza namazı logs state
│   ├── quran_logs_provider.dart       # Kur'an okuma logs state
│   ├── statistics_provider.dart       # İstatistikler state
│   ├── streak_provider.dart           # Streak (zincir) state
│   └── user_profile_provider.dart     # Kullanıcı profili state
├── src/
│   ├── core/
│   │   └── database/
│   │       └── app_database_helper.dart # Database işlemleri (Sqflite)
│   └── features/                         # Feature-based modüler yapı
│       ├── kaza/                         # Kaza namazı özelliği
│       │   ├── domain/
│       │   │   └── entities/
│       │   │       └── prayer_time.dart  # Namaz vakitleri enum
│       │   ├── data/
│       │   │   └── models/
│       │   │       └── kaza_log_model.dart # Kaza kayıt modeli
│       │   └── presentation/
│       ├── quran/                        # Kur'an okuma özelliği
│       │   ├── domain/
│       │   ├── data/
│       │   │   └── models/
│       │   │       └── quran_log_model.dart # Kur'an kayıt modeli
│       │   └── presentation/
│       └── profile/                      # Kullanıcı profili özelliği
│           ├── domain/
│           ├── data/
│           │   └── models/
│           │       └── user_profile_model.dart # Profil modeli (Seviye, Puan)
│           └── presentation/
├── ui/
│   ├── screens/                       # Ana ekranlar (Dashboard, Streak, İstatistikler vb.)
│   ├── widgets/                       # Tekrar kullanılabilir UI bileşenleri
│   └── theme/
│       └── app_theme.dart             # Material Design 3 tema ve renkler
└── pubspec.yaml                       # Paket bağımlılıkları
```

### 📋 Klasör Yapısı Açıklaması

- **`lib/`** – Ana Flutter kaynak kodu
- **`lib/providers/`** – Riverpod state yönetimi ve business logic
- **`lib/src/features/`** – Temiz Mimari (Clean Architecture) ilkesine göre feature-based modüler yapı
  - Her feature (kaza, quran, profile) domain, data ve presentation katmanlarına ayrılmıştır
  - **domain/** – İş kuralları ve entity'ler
  - **data/** – Veritabanı modelleri ve veri kaynakları
  - **presentation/** – UI ve state management
- **`lib/ui/`** – Tekrar kullanılabilir bileşenler ve app-wide tema
- **`lib/src/core/`** – Uygulama çapında ortak araçlar (Database Helper)

---

## 🚀 Kurulum & Çalıştırma

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

### ✅ Ön Koşullar

- **Flutter SDK** 3.0 veya üzeri
- **Dart** 3.0 veya üzeri
- **Android SDK** (Android cihaz/emülatör için)
- **Xcode** (iOS cihaz/emülatör için)

### 📥 Kurulum Adımları

1. **Projeyi Klonlayın:** (GitHub reposu oluşturulduktan sonra)
   ```bash
   git clone https://github.com/gkaan/kaza-quran-takip.git
   cd kaza-quran-takip
   ```

2. **Paketleri Yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı Çalıştırın:**
   ```bash
   # Android için
   flutter run

   # iOS için (macOS gerekli)
   flutter run -d ios
   ```

4. **Geliştirme Modunda Hot Reload ile:**
   ```bash
   flutter run -v
   ```

---

## 🏗️ Mimari Yapı

Bu proje **Temiz Mimari (Clean Architecture)** ilkelerini takip eder:

```
Feature
├── Domain (İş Kuralları)
│   ├── Entities (Veri modelleri - domain spesifik)
│   └── Repositories (Abstract interface'ler)
├── Data (Veri Kaynakları)
│   ├── Models (Domain entity'lerinin data temsili)
│   ├── Datasources (Veritabanı, API vb. kaynaklar)
│   └── Repositories (Domain interface'lerinin implementasyonu)
└── Presentation (UI & State)
    ├── Screens (Ekranlar)
    ├── Widgets (UI bileşenleri)
    └── State Management (Riverpod providers)
```

**Faydaları:**
- ✅ Kod testlenebilirliği artırılır
- ✅ Bağımlılıklar düşük kalır
- ✅ Yeni özellik eklenmesi kolay
- ✅ Ekip çalışması istikrarlı olur

---

## 💾 Veri Tabanı Şeması

Uygulama 3 ana tablodan oluşur:

### 1. **user_profile** – Kullanıcı Profili
```sql
CREATE TABLE user_profile (
  id INTEGER PRIMARY KEY,
  initial_sabah INTEGER,
  initial_ogle INTEGER,
  initial_ikindi INTEGER,
  initial_aksam INTEGER,
  initial_yatsi INTEGER,
  initial_vitir INTEGER,
  completed_sabah INTEGER,
  completed_ogle INTEGER,
  completed_ikindi INTEGER,
  completed_aksam INTEGER,
  completed_yatsi INTEGER,
  completed_vitir INTEGER,
  level INTEGER,
  motivation_points INTEGER,
  created_at TEXT,
  updated_at TEXT
);
```

### 2. **kaza_logs** – Kaza Namazı Kayıtları
```sql
CREATE TABLE kaza_logs (
  id INTEGER PRIMARY KEY,
  date TEXT,
  prayer_time TEXT,  -- sabah, ogle, ikindi, aksam, yatsi, vitir
  count INTEGER,
  created_at TEXT
);
-- İndeks: (date, prayer_time)
```

### 3. **quran_logs** – Kur'an Okuma Kayıtları
```sql
CREATE TABLE quran_logs (
  id INTEGER PRIMARY KEY,
  date TEXT,
  pages INTEGER,
  created_at TEXT
);
-- İndeks: (date)
```

---

## 📸 Ekran Görüntüleri

> *(Buraya uygulamanın ekran görüntülerini ekleyeceksiniz)*

| Ana Sayfa (Dashboard) | Seriler (Streak) | İstatistikler | Geçmiş Dökümü |
| :---: | :---: | :---: | :---: |
| `[Ekran Görüntüsü 1]` | `[Ekran Görüntüsü 2]` | `[Ekran Görüntüsü 3]` | `[Ekran Görüntüsü 4]` |

---

## 🔐 State Management (Riverpod)

Uygulama **Riverpod** kullanarak reaktif state yönetimi sağlar:

```dart
// Örnek: Kaza kayıtlarını dinleme
final kazaLogsProvider = StateNotifierProvider<...>((ref) {
  final db = ref.watch(databaseProvider);
  return KazaLogsNotifier(db);
});

// Kullanım
@override
Widget build(BuildContext context, WidgetRef ref) {
  final kazaLogs = ref.watch(kazaLogsProvider);
  
  return kazaLogs.when(
    data: (logs) => ListView(children: [...]),
    loading: () => CircularProgressIndicator(),
    error: (e, st) => Text('Hata: $e'),
  );
}
```

---

## 🤝 Katkıda Bulunma

Projeye katkıda bulunmak istiyorsanız:

1. Fork yapın
2. Feature branch'i oluşturun (`git checkout -b feature/YeniÖzellik`)
3. Değişikliklerinizi commit edin (`git commit -m 'Yeni özellik ekle'`)
4. Branch'i push edin (`git push origin feature/YeniÖzellik`)
5. Pull Request'i açın

---

## 👨‍💻 Geliştirici

**Kaan GÜL** – [GitHub Profili](https://github.com/kaan-gul)

---

## ❓ Sık Sorulan Sorular

**S: Uygulamayı iOS'ta çalıştırabilirim?**  
C: Evet, flutter run -d ios komutu ile çalıştırabilirsiniz (macOS gerekli).

**S: Veritabanım başka cihaza taşıyabilir miyim?**  
C: Sqflite lokal depolama kullanır. Bulut senkronizasyonu için Firebase eklemek mümkün.

**S: Undo (Geri Al) özelliği tamamen destekleniyor mu?**  
C: Kaza ve Kur'an kayıtlarında undo mekanizması uygulanmıştır.

---

##  İletişim

Sorularınız ya da önerileriniz için GitHub Issues'i açabilirsiniz.

---

⭐ Projeyi beğendiyseniz star vermeyi unutmayın!

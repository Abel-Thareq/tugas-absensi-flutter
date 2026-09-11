# Presensi Pegawai - Mobile Attendance Application

Aplikasi sistem presensi karyawan berbasis mobile yang dibangun menggunakan **Flutter**, terintegrasi dengan **Firebase Authentication**, **Google Cloud Firestore**, dan sensor koordinat **GPS Geolocator**.

Aplikasi ini dirancang dengan antarmuka modern bertema *Forest Emerald & Clean Slate*, dilengkapi pencegahan absensi ganda (*duplicate check-in prevention*), riwayat absensi kronologis, serta profil karyawan.

---

## 🌟 Fitur Utama

1. **Autentikasi Karyawan (Firebase Authentication)**
   - Login menggunakan email dan kata sandi dengan validasi input yang ketat.
   - Penanganan error human-readable dan indikator pemrosesan.
   - Sesi pengguna tersimpan secara aman.

2. **Dashboard Karyawan**
   - Sapaan dinamis sesuai waktu (*Selamat Pagi / Siang / Sore / Malam*).
   - Penunjuk jam digital *realtime* (WIB).
   - Kartu status presensi harian (*Belum Absen* / *Hadir*).
   - Indikator kesiapan sensor lokasi GPS.
   - Ringkasan metrik mingguan (*Kehadiran*, *Ketepatan*, *Geofence*).

3. **Akuisisi Koordinat GPS (Geolocator)**
   - Mendeteksi dan membaca koordinat riil *Latitude* & *Longitude* dari sensor GPS perangkat.
   - Menangani izin lokasi (*Location Permissions*) dan status GPS aktif.
   - Menampilkan titik koordinat secara transparan sebelum data disimpan.

4. **Pencegahan Presensi Ganda (Duplicate Check-in Guard)**
   - Sistem memvalidasi tanggal hari ini sebelum menyimpan.
   - Tombol dan kartu presensi otomatis terkunci (*disabled*) jika karyawan sudah melakukan absensi pada hari yang sama.
   - Mencegah spam atau klik ganda secara logis di aplikasi dan database.

5. **Penyimpanan Data Cloud (Cloud Firestore)**
   - Data karyawan tersimpan di koleksi `users/{userId}`.
   - Data rekaman presensi harian tersimpan di koleksi `attendance/{attendanceId}` dengan Server Timestamp Firebase.

6. **Riwayat Presensi (Attendance History)**
   - Menampilkan catatan presensi secara kronologis.
   - Memuat tanggal, jam presensi, status kehadiran, dan titik koordinat GPS.
   - Dilengkapi fitur *Pull-to-refresh*.

7. **Profil Karyawan & Logout**
   - Informasi detail karyawan (Nama, NIP, Posisi, Divisi, Kantor Penugasan, Shift Kerja).
   - Logout aman dengan dialog konfirmasi.

---

## 🛠️ Teknologi & Dependensi

* **Framework:** Flutter (Dart 3.x)
* **Backend & Database:**
  * `firebase_core`: Inisialisasi Firebase
  * `firebase_auth`: Manajemen autentikasi pengguna
  * `cloud_firestore`: Database NoSQL untuk data karyawan dan absensi
* **Lokasi & GPS:**
  * `geolocator`: Akuisisi koordinat latitude & longitude
* **State Management:**
  * `provider`: Pengelolaan state autentikasi, status presensi, dan riwayat
* **Desain & UI:**
  * `google_fonts` (Inter)
  * `intl`: Format tanggal dan jam lokal Indonesia

---

## 📁 Struktur Proyek

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # Konstanta aplikasi & konfigurasi default
│   └── theme/
│       └── app_theme.dart              # Tema warna (Emerald Palette) & tipografi
├── models/
│   ├── attendance_model.dart           # Model data rekaman presensi
│   └── user_model.dart                 # Model data profil karyawan
├── services/
│   ├── auth_service.dart               # Layanan Firebase Auth & manajemen sesi
│   ├── attendance_service.dart         # Layanan Firestore untuk data presensi
│   └── location_service.dart           # Layanan sensor GPS & izin lokasi
├── state/
│   ├── auth_provider.dart              # State management autentikasi
│   └── attendance_provider.dart        # State management presensi & riwayat
├── screens/
│   ├── auth/
│   │   └── login_screen.dart           # Tampilan login karyawan
│   ├── home/
│   │   ├── home_screen.dart            # Dashboard utama presensi
│   │   ├── location_verification_sheet.dart # Modal pembacaan koordinat GPS
│   │   ├── check_in_confirmation_sheet.dart  # Lembar konfirmasi presensi
│   │   └── check_in_success_dialog.dart      # Dialog notifikasi sukses
│   ├── history/
│   │   └── history_screen.dart         # Layar riwayat presensi
│   ├── profile/
│   │   └── profile_screen.dart         # Layar profil karyawan & logout
│   └── main_navigation_screen.dart     # Navigasi tab bawah (Home, History, Profile)
├── firebase_options.dart               # Konfigurasi platform Firebase
└── main.dart                           # Titik masuk utama aplikasi
```

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Prasyarat
* Flutter SDK (versi >= 3.24)
* Android Studio / VS Code
* Perangkat Android (Fisik atau Emulator) dengan layanan Google Play Services

### 2. Instalasi Dependensi
Jalankan perintah berikut di terminal:
```bash
flutter pub get
```

### 3. Menjalankan Aplikasi
Hubungkan perangkat Android Anda via USB Debugging, lalu jalankan:
```bash
flutter run
```

### 4. Build APK Release
Untuk membuat file APK siap instal:
```bash
flutter build apk --release
```
File APK akan dihasilkan di `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🔑 Kredensial Pengujian

* **Email:** `abel@perusahaan.com`
* **Kata Sandi:** `password123`
*(Atau gunakan email perusahaan lainnya dengan format standar)*

---

## 📄 Lisensi
Dikembangkan untuk keperluan akademik / tugas sistem presensi karyawan mobile.

# Pasar Malam

Aplikasi Flutter Pasar Malam yang terhubung dengan Dompet Digital/Kampus.

## Setup

```sh
flutter pub get
```

## Menjalankan Aplikasi

Android:

```sh
flutter run -d android
```

iOS simulator:

```sh
flutter run -d 3818D081-BB40-4ADA-AA3F-CE3E6DBE0150
```

Target yang tersedia bisa dicek dengan:

```sh
flutter devices
```

## Verifikasi

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator
```

Catatan: konfigurasi Firebase lama sudah dihapus. Jalankan FlutterFire CLI memakai Firebase project milik sendiri, lalu pilih app `com.example.pasar_malam` untuk Android dan `com.example.pasarMalam` untuk iOS.

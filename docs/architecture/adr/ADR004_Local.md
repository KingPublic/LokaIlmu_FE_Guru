# ADR 004: Pemilihan Local Data Persistence

## Status
Accepted

## Date  
07/05/2025

## Decider  
Ketua Tim - @KingPublic

## Informed  
@veryepiccindeed  
@alicialisal  
@Calvinrichie

## Context

Aplikasi LokaIlmu membutuhkan penyimpanan lokal yang aman untuk menyimpan data autentikasi pengguna seperti token atau cookie login. Data ini digunakan untuk menjaga sesi pengguna tetap aktif tanpa harus login ulang setiap kali aplikasi dibuka. Karena data bersifat sensitif, tidak bisa disimpan sembarangan. Selain itu, fitur Perpustakaan yang disediakan oleh LokaIlmu juga membutuhkan mekanisme penyimpanan data lokal untuk mendukung fungsi offline, seperti menyimpan metadata buku.

## Decision

Kami memutuskan untuk menggunakan **`flutter_secure_storage`** sebagai solusi penyimpanan lokal untuk data autentikasi.

- Menggunakan fitur keamanan native: Keychain (iOS) dan Keystore (Android).
- Simpel, berbasis key-value.
- Aman untuk menyimpan token, cookie, atau ID user.

Selain itu, kami juga memutuskan untuk menggunakan **Hive** untuk menyimpan data umum dan non-sensitif seperti metadata buku, status unduhan, dan profil pengguna.

## Consequences

### Keuntungan

- Hive:
  - Ringan dan cepat, cocok untuk aplikasi mobile.
  - Tidak membutuhkan struktur SQL, mudah digunakan oleh pemula.
  - Bisa digunakan offline tanpa setup kompleks.
  - Mendukung TypeAdapter untuk data kompleks.

- *flutter_secure_storage*:
  - Menyimpan data secara **terenkripsi**, aman dari akses pihak ketiga.
  - **Cross-platform** dan mendukung operasi async.
  - API sederhana, cepat diintegrasikan.

### Risiko
- Hive tidak mengenkripsi data secara default.
- Kebutuhan dua storage berbeda dapat menambah kompleksitas kecil dalam manajemen data.

### Mitigasi
- Untuk Hive, hanya digunakan untuk data non-sensitif.
- flutter_secure_storage digunakan secara spesifik dan terbatas hanya untuk token dan data yang benar-benar sensitif.
- Dokumentasi internal akan menyertakan panduan kapan harus menyimpan data di Hive vs flutter_secure_storage.

## Alternatives Considered
- **SQLite**: Kuat dan fleksibel, tetapi terlalu kompleks untuk kebutuhan yang sederhana. Membutuhkan setup query SQL manual dan skema tabel.
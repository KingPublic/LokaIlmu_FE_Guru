# ADR 004: Local Data Persistence untuk Login/User Session

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

Aplikasi LokaIlmu membutuhkan penyimpanan lokal yang aman untuk menyimpan data autentikasi pengguna seperti token atau cookie login. Data ini digunakan untuk menjaga sesi pengguna tetap aktif tanpa harus login ulang setiap kali aplikasi dibuka. Karena data bersifat sensitif, tidak bisa disimpan sembarangan.

## Decision

Kami memutuskan untuk menggunakan **`flutter_secure_storage`** sebagai solusi penyimpanan lokal untuk data autentikasi.

- Menggunakan fitur keamanan native: Keychain (iOS) dan Keystore (Android).
- Simpel, berbasis key-value.
- Aman untuk menyimpan token, cookie, atau ID user.

## Consequences

### Keuntungan
- Menyimpan data secara **terenkripsi**, aman dari akses pihak ketiga.
- **Cross-platform** dan mendukung operasi async.
- API sederhana, cepat diintegrasikan.

### Risiko
- Hanya cocok untuk data kecil (token, string sederhana).
- Tidak cocok untuk menyimpan data besar atau kompleks.

### Mitigasi
- Gunakan hanya untuk data penting (misal: token login).
- Gunakan `jsonEncode` jika butuh menyimpan data JSON sederhana.

## Alternatives Considered
- **SharedPreferences**: tidak terenkripsi, tidak aman untuk data sensitif.
- **Hive / SQLite**: lebih cocok untuk caching atau penyimpanan data non-sensitif.

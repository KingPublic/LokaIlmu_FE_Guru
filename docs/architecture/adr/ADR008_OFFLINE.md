# ADR 008: Strategi Offline Support & Caching

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

Aplikasi LokaIlmu dirancang untuk bisa digunakan oleh guru dan kepala sekolah yang mungkin berada di daerah dengan konektivitas internet terbatas. Oleh karena itu, dibutuhkan strategi untuk mendukung penggunaan aplikasi secara **offline** dan tetap mempertahankan performa serta keamanan data—terutama untuk buku-buku dalam format PDF yang hanya boleh dibaca dalam aplikasi dan tidak boleh disebarluaskan.

## Decision

Kami memutuskan untuk menerapkan strategi **local-first dengan custom caching layer**, yang mencakup:

- Menyimpan **metadata buku** (judul, deskripsi, penulis, ID, status unduhan) secara lokal menggunakan **Hive**.
- Menyimpan file **PDF buku di internal storage** aplikasi menggunakan nama acak, tidak dapat diakses langsung oleh pengguna.
- Membaca file PDF hanya melalui **PDF viewer bawaan aplikasi**, bukan membuka lewat aplikasi eksternal.
- Tidak mengizinkan pengguna menyalin, mengunduh, atau membagikan file PDF ke luar aplikasi.

## Consequences

### Keuntungan

- Aplikasi tetap bisa digunakan tanpa koneksi internet.
- Buku tetap bisa dibaca offline jika sudah diunduh sebelumnya.
- File PDF tidak dapat dibagikan sembarangan karena disimpan secara tersembunyi.
- Performa aplikasi meningkat karena tidak tergantung sepenuhnya pada request server.

### Risiko

- Ukuran aplikasi bisa bertambah seiring banyaknya file PDF yang disimpan.
- Perlu kontrol manajemen storage agar tidak memakan banyak ruang di perangkat.
- Perlu pengamanan tambahan agar file PDF tidak bisa dicuri dari internal storage.

### Mitigasi

- File PDF disimpan dengan nama acak dan tanpa ekstensi yang mudah dikenali.
- Gunakan direktori **application documents** atau **cache** yang tidak dapat diakses tanpa root.
- Tambahkan opsi penghapusan otomatis untuk buku yang sudah tidak dibaca dalam jangka waktu tertentu.
- Tidak menggunakan `openFile()` atau intent viewer eksternal yang memungkinkan pengguna menyalin file.

## Alternatives Considered

- **Backend-as-a-Cache Proxy**: Terlalu kompleks untuk kebutuhan saat ini, dan tetap membutuhkan koneksi saat pertama kali membuka buku.

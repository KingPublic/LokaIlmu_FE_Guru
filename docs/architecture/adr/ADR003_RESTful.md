# ADR 003: Pemilihan RESTful API

## Status
Accepted

## Date
06/05/2025

## Decider 
Anggota Backend - @veryepiccindeed

## Informed
@KingPublic
@alicialisal
Calvin Richie

## Context

Aplikasi LokaIlmu membutuhkan metode komunikasi antara frontend (Flutter) dan backend (Laravel) untuk mengambil dan mengirim data seperti informasi pengguna, daftar pelatihan, dan hasil evaluasi. Pilihan utama adalah antara RESTful API, GraphQL, atau Backend-as-a-Service (seperti Firebase). Mengingat Laravel sangat mendukung REST, dan kebutuhan kita masih dalam skala menengah tanpa kompleksitas query yang tinggi, maka perlu dipilih pendekatan yang sederhana dan stabil.

## Decision

Kami memutuskan untuk menggunakan **RESTful API** sebagai strategi integrasi antara frontend dan backend. Laravel akan menyediakan endpoint REST yang diakses oleh aplikasi Flutter untuk kebutuhan data pengguna, pelatihan, dan interaksi lainnya.

## Consequences

### Keuntungan

- Mudah diimplementasikan di Laravel karena sudah native support.
- Dokumentasi dan standar luas, banyak referensi dan contoh kasus.
- Cocok untuk tim baru, terutama untuk pengembang pemula hingga menengah.
- Mudah di-debug dan dipantau, terutama saat menggunakan tools seperti Postman atau Insomnia.

### Potensi Risiko

- Kurang fleksibel dibanding GraphQL dalam mengambil data spesifik (misalnya hanya sebagian field dari objek besar).
- Bisa terjadi over-fetching (ambil data lebih banyak dari yang dibutuhkan) atau under-fetching.

### Mitigasi

- Menggunakan struktur endpoint yang efisien dan pagination saat mengambil data banyak.
- Backend akan menyediakan endpoint khusus untuk skenario yang berulang agar tidak perlu ambil semua data sekaligus.
- Bisa dievaluasi kembali penggunaan GraphQL jika kebutuhan aplikasi bertambah kompleks di masa depan.

## Alternatives Considered

- **GraphQL**: Lebih fleksibel untuk query data. Namun belum dikuasai penuh oleh tim dan butuh setup tambahan di Laravel. Terdapat risiko over-engineering pada tahap awal pengembangan.
- **Firebase**: Cepat untuk MVP, cocok untuk aplikasi ringan. Tapi kurang sesuai dengan arsitektur self-hosted Laravel yang sedang dibangun. Kurang fleksibel untuk kustomisasi dan kendali penuh atas data.
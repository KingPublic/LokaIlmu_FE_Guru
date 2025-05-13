# ADR 009: Pemilihan Error Handling & Monitoring

## Status
Accepted

## Date
06/05/2025

## Decider 
Ketua Tim - @KingPublic

## Informed
@veryepiccindeed
@alicialisal
@Calvinrichie

## Context

Tim pengembang aplikasi *LokaIlmu* memiliki keterbatasan waktu dan sumber daya pada fase awal pengembangan. Meskipun tools seperti **Sentry** atau **Firebase Crashlytics** menyediakan pelaporan error otomatis yang sangat membantu, integrasi dan konfigurasi awalnya membutuhkan waktu tambahan.  
Untuk itu, diputuskan bahwa sistem pelaporan error akan dimulai dengan pendekatan **custom logging** yang sederhana terlebih dahulu.

## Decision

Tim memutuskan untuk:
- Mengimplementasikan sistem **custom logging** menggunakan wrapper `logService.dart`, yang memanfaatkan `logger` atau `print()` dengan format standar.
- Menambahkan opsi untuk menyimpan log penting ke local file jika diperlukan untuk debugging.
- Menyiapkan arsitektur logging agar dapat dengan mudah di-*upgrade* ke **Sentry** di tahap release atau production mendatang.


## Consequences

### Keuntungan

- Lebih cepat untuk diimplementasikan di fase awal.
- Tidak menambah beban dependensi atau konfigurasi eksternal.
- Memberikan fleksibilitas dalam menangani log sesuai kebutuhan aplikasi.

### Risiko

- Error tidak dilaporkan secara otomatis ke dashboard.
- Developer harus mencari log manual dari perangkat.
- Sulit memantau crash yang terjadi di production.

### Mitigasi

- Logging ditulis dengan standar konsisten dan ditempatkan dalam `logService.dart`.
- Setelah aplikasi mencapai versi stabil (Beta/Release), akan dilakukan integrasi dengan **Sentry** untuk pelaporan error otomatis.
- Setiap error kritis akan diuji secara manual sebelum rilis ke publik.


## Alternatives Considered

- **Sentry**: Powerful dan mendukung Flutter serta Laravel. Rencana jangka menengah kami, namun ditunda sampai waktu pengembangan lebih longgar.

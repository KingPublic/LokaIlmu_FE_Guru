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

Aplikasi LokaIlmu perlu menangani error dengan baik dan memantau kesehatan aplikasi saat digunakan oleh pengguna asli (guru, kepala sekolah, mentor). Hal ini penting agar tim developer bisa tahu jika aplikasi tiba-tiba error, crash, atau berjalan tidak normal. Pilihannya adalah menggunakan Sentry, Firebase Crashlytics, atau sistem logging manual.

## Decision

Tim memutuskan untuk menggunakan Sentry sebagai alat utama untuk error reporting dan monitoring di aplikasi LokaIlmu, baik di sisi Flutter (frontend) maupun Laravel (backend).

## Consequences

### Keuntungan

- Real-time error tracking, jadi tim bisa langsung tahu kalau ada bug atau crash terjadi di sisi pengguna.
- Support untuk Flutter dan Laravel, jadi satu platform bisa dipakai dua-duanya.
- Bisa melihat stack trace, user context, dan device info, yang sangat membantu saat debug.
- Mendukung integrasi ke tools seperti Slack atau Email untuk notifikasi otomatis.

### Risiko

- Penggunaan data/log terlalu banyak jika tidak dikonfigurasi dengan baik bisa memenuhi kuota gratisnya.
- Perlu pengaturan awal dan memahami dashboard Sentry untuk memanfaatkan fitur sepenuhnya.

### Mitigasi

- Konfigurasi logging agar hanya menangkap error penting (bukan log debug biasa).
- Atur notifikasi hanya untuk error level tinggi (e.g., fatal crash).
- Pantau penggunaan kuota dan pertimbangkan upgrade plan jika diperlukan.

## Alternatives Considered

- **Firebase Crashlytics**: Kuat untuk Android/iOS, mudah diintegrasikan. Namun kurang cocok untuk Laravel (butuh solusi terpisah untuk backend).
- **Custom Logging**: Fleksibel dan bisa dikontrol penuh. Tapi memerlukan waktu lebih banyak untuk membangun sistem alert, log viewer, dan dashboar
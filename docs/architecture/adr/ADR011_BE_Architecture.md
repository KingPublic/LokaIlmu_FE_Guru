# ADR 011: Back-End Architecture Pattern

## Status
Accepted

## Date
13/05/2025

## Decider 
Ketua Tim - @KingPublic

## Informed
@veryepiccindeed
@alicialisal
@Calvinrichie

## Context

Dalam tahap awal pengembangan aplikasi, penting untuk menentukan pola arsitektur backend yang dapat memisahkan tanggung jawab logika bisnis, pengelolaan data, dan antarmuka pengguna. Pilihan arsitektur akan mempengaruhi keterbacaan, skalabilitas, dan kemudahan perawatan kode dalam jangka panjang.

## Decision

Diputuskan untuk menggunakan pola arsitektur MVC (Model-View-Controller) sebagai fondasi utama dalam pengembangan backend aplikasi.

## Consequences

### Keuntungan

* Sudah built-in dalam framework
* Pemisahan tugas yang jelas antara logika bisnis (Controller), struktur data (Model), dan representasi data (View/Response).
* Sebagian besar tutorial, package, dan dokumentasi Laravel mengasumsikan penggunaan pola MVC.

### Risiko

* Membutuhkan kedisiplinan dalam menjaga batas tanggung jawab tiap komponen.
* Implementasi awal mungkin sedikit lebih kompleks dibandingkan pendekatan monolitik sederhana.

### Mitigasi

* Dokumentasi internal akan disiapkan untuk menyamakan pemahaman tim tentang struktur MVC.

## Alternatives Considered

- **Mircoservice**: Khusus untuk aplikasi dengan skalabilitas besar dan membutuhkan tim besar untuk pengerjaannya.

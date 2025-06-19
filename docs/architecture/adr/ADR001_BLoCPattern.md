# ADR 001: Pemilihan Arsitektur BLoC Pattern

## Status
Accepted

## Date
06/05/2025

## Decider 
Ketua Tim

## Informed
@veryepiccindeed
@alicialisal
@Calvinrichie

## Context

Aplikasi *LokaIlmu* ditujukan untuk mendukung guru-guru di sekolah dengan akreditasi B ke bawah serta para profesional sebagai mentor. Aplikasi ini memiliki berbagai fitur seperti pelatihan daring, perpustakaan digital, dan forum diskusi. Fitur-fitur ini memiliki logika kompleks dan beragam alur data asinkron yang perlu dikelola secara efisien dan terpisah dari tampilan (UI).

Diperlukan arsitektur yang mampu:
- Memisahkan tanggung jawab antar komponen aplikasi.
- Mempermudah pengujian unit secara independen.
- Mendukung pengembangan fitur yang scalable.

## Decision

Kami memutuskan untuk menggunakan pola arsitektur **BLoC Pattern** dalam aplikasi LokaIlmu. Dengan pola ini:

- **Data Layer (Repository)** bertanggung jawab untuk menyediakan data dari API dan melakukan parsing ke model. 
- **Business Logic Layer (BLoC)** bertanggung jawab untuk menerima events dari UI, mengelola state aplikasi, dan berkomunikasi dengan repository.
- **Presentation Layer (UI Layer)** hanya bertanggung jawab menampilkan UI berdasarkan state dan mengirim events yang diterima dari user ke BLoC.

## Consequences

### Keuntungan

- **Separation of Concerns**: Meningkatkan keterbacaan dan maintainability kode.
- **Testability**: BLoC mudah diuji karena bebas dari kode UI.
- **Scalability**: Struktur yang modular memudahkan pengembangan fitur baru.

### Potensi Risiko

- **Learning Curve**: Perlu penyesuaian awal tim terhadap pola MVVM di Flutter.
- **Kompleksitas Awal**: Membutuhkan pengaturan struktur folder dan dependensi dengan tepat.

### Mitigasi

- Menyediakan dokumentasi arsitektur internal dan template pengembangan.
- Melatih tim pengembang untuk memahami peran ViewModel dalam pengelolaan UI state.

## Alternatives Considered

- **MVC / MVP**: Kurang cocok untuk aplikasi Flutter karena logika bisnis sering bercampur dengan UI.
- **Clean Architecture Full Stack**: Terlalu kompleks untuk tahap awal aplikasi ini.


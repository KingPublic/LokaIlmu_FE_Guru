# ADR 001: Pemilihan Arsitektur MVVM

## Status
Accepted

## Context
Aplikasi *LokaIlmu* ditujukan untuk mendukung guru-guru di sekolah dengan akreditasi B ke bawah serta para profesional sebagai mentor. Aplikasi ini memiliki berbagai fitur seperti pelatihan daring, perpustakaan digital, dan forum diskusi. Fitur-fitur ini memiliki logika kompleks dan beragam alur data asinkron yang perlu dikelola secara efisien dan terpisah dari tampilan (UI).

Diperlukan arsitektur yang mampu:
- Memisahkan tanggung jawab antar komponen aplikasi.
- Mempermudah pengujian unit secara independen.
- Mendukung pengembangan fitur yang scalable.

## Decision
Kami memutuskan untuk menggunakan pola arsitektur **MVVM (Model-View-ViewModel)** dalam aplikasi LokaIlmu. Dengan pola ini:

- **Model** bertanggung jawab atas data dan logika bisnis tingkat rendah.
- **ViewModel** bertindak sebagai jembatan antara View dan Model, mengelola state serta menyediakan data dan logika presentasi ke View.
- **View** hanya bertanggung jawab menampilkan UI berdasarkan state yang diberikan oleh ViewModel.

## Consequences
### Keuntungan
- **Separation of Concerns**: Meningkatkan keterbacaan dan maintainability kode.
- **Testability**: ViewModel mudah diuji karena bebas dari kode UI.
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


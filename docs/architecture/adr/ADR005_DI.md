# ADR 005: Pemilihan Dependency Injection Framework

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

LokaIlmu merupakan aplikasi yang akan terus berkembang dengan berbagai service, seperti authentication, API clients, repositories, dan use case yang digunakan lintas fitur. Untuk mendukung prinsip SOLID dan kemudahan testing, aplikasi ini memerlukan dependency injection (DI) framework untuk mengelola pembuatan dan penyediaan objek secara terpusat dan terstruktur.

## Decision  

Kami memilih untuk menggunakan **GetIt** sebagai solusi DI, tanpa tambahan framework seperti `injectable`.
Cocok bagi aplikasi kami yang menggunakan pattern MVVM.

- **GetIt** berfungsi sebagai service locator, yaitu tempat mendaftarkan objek agar bisa digunakan dari mana saja tanpa membuat ulang.
- Pendaftaran dependency dilakukan secara manual, memberi fleksibilitas dan kontrol penuh atas lifecycle objek.
- Solusi ini ringan dan cocok bagi aplikasi kami yang menggunakan pola MVVM atau BLoC secara modular.

## Consequences  

### Keuntungan

- **Decoupling**: Komponen tidak perlu tahu bagaimana dependensinya dibuat.
- **Testability**: Mudah menyuntikkan mock dependencies saat testing.
- **Maintainable**: Konfigurasi DI tersentralisasi dan mudah dilacak.
- **Tanpa code generation**: Tidak perlu menjalankan `build_runner`, lebih ringan dan cepat saat development.

### Risiko  

- Potensi meningkatnya boilerplate saat jumlah dependency bertambah banyak.
- Manual registration bisa menimbulkan error jika tidak terorganisir dengan baik.

### Mitigasi  

- Menyediakan dokumentasi internal tentang standar penamaan dan struktur folder untuk registrasi dependency.
- Setup `GetIt` dilakukan di satu titik (`locator.dart`) yang terstruktur dan diuji sejak awal pengembangan.

## Alternatives Considered  

- **Injectable** + GetIt: Mengurangi boilerplate melalui anotasi, namun menambah kompleksitas melalui proses code generation.
- **Manual injection** (tanpa framework): Kurang scalable dan mudah menyebabkan tight coupling.
- **Provider-based DI**: Cocok untuk proyek kecil, namun kurang fleksibel untuk skala besar dan modular.

# ADR 005: Pemilihan Dependency Injection Framework

## Status
Accepted

## Date
06/05/2025

## Decider 
Ketua Tim -@KingPublic

## Informed
@veryepiccindeed
@alicialisal
@Calvinrichie

## Context

LokaIlmu merupakan aplikasi yang akan terus berkembang dengan berbagai service, seperti authentication, API clients, repositories, dan use case yang akan digunakan lintas fitur. Untuk mendukung prinsip SOLID dan kemudahan testing, aplikasi ini memerlukan dependency injection (DI) framework untuk mengelola pembuatan dan penyediaan objek secara terpusat dan terstruktur.

## Decision

Kami memilih untuk menggunakan **GetIt** dikombinasikan dengan **injectable** sebagai solusi DI.

* **GetIt** berfungsi sebagai service locator, yaitu tempat mendaftarkan objek agar bisa digunakan dari mana saja tanpa membuat ulang.
* **injectable** memungkinkan konfigurasi otomatis dan deklaratif dengan anotasi `@injectable`, sehingga mengurangi boilerplate.

## Consequences

### Keuntungan

* **Decoupling**: Komponen tidak perlu tahu bagaimana dependensinya dibuat.
* **Testability**: Mudah menyuntikkan mock dependencies saat testing.
* **Maintainable**: Konfigurasi DI tersentralisasi dan mudah dilacak.

### Risiko

* **Learning curve** terkait penggunaan anotasi dan proses code generation.

### Mitigasi

* Dokumentasi internal dan perintah generator (`flutter pub run build_runner build`) disediakan sejak awal.

## Alternatives Considered

* Manual injection: lebih rawan kesalahan dan tidak scalable.
* Provider-based DI: cocok untuk proyek kecil, namun kurang fleksibel untuk modularisasi besar.
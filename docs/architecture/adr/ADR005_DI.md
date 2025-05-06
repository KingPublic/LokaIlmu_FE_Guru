# ADR 005: Pemilihan Dependency Injection Framework

## Status

Accepted

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






# ADR 006: Strategi Offline & Caching

## Status

Deferred

## Context

Meskipun sebagian konten seperti pelatihan dan perpustakaan bisa saja diakses secara offline di masa depan, saat ini fokus pengembangan masih berbasis online. Fitur offline akan dipertimbangkan kembali setelah versi awal rilis.

## Decision

Strategi offline dan caching **ditunda** untuk saat ini.

## Consequences

### Keuntungan

* Fokus pengembangan ke fitur utama terlebih dahulu.

### Risiko

* Pengguna di daerah dengan koneksi buruk mungkin mengalami kendala.

### Mitigasi

* Modul offline akan dirancang kemudian, terutama untuk perpustakaan digital.

---

# ADR 007: Strategi Penanganan Error & Monitoring

## Status

Deferred

## Context

Aplikasi menggunakan backend Laravel dan tidak terintegrasi langsung dengan Firebase. Oleh karena itu, solusi seperti Crashlytics belum diprioritaskan. Error saat ini ditangani secara lokal saat development.

## Decision

Penanganan error dan monitoring **ditunda**, dengan opsi untuk menggunakan log lokal (misalnya package `logger`) selama tahap awal.

## Consequences

### Keuntungan

* Pengembangan tetap ringan dan tidak tergantung tool eksternal.

### Risiko

* Tidak ada pelaporan error otomatis dari pengguna produksi.

### Mitigasi

* Fitur log upload atau feedback manual bisa dirancang di masa depan.

---

# ADR 008: Strategi Testing & CI/CD

## Status

Deferred

## Context

Saat ini pengujian aplikasi dilakukan secara manual menggunakan perangkat Android pribadi. CI/CD pipeline belum dibutuhkan, dan repository hanya digunakan untuk versioning dengan GitHub.

## Decision

CI/CD dan testing otomatis **ditunda**. Pengujian dilakukan manual sambil membangun dasar kode yang stabil.

## Consequences

### Keuntungan

* Proses pengembangan lebih cepat tanpa overhead otomatisasi.

### Risiko

* Rentan terhadap human error jika tidak ada testing otomatis.

### Mitigasi

* Rencana untuk menambahkan testing unit dan widget secara bertahap setelah versi MVP.

# ADR 010: Strategi Testing & CI/CD

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

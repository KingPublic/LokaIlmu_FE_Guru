# ADR 012: Back-End Programming Language & Framework

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

Tim perlu menentukan bahasa pemrograman dan framework untuk pengembangan back-end. Pertimbangan utama meliputi ketersediaan sumber daya, kemudahan dokumentasi, komunitas yang besar, dan kestabilan jangka panjang untuk pengembangan aplikasi.

## Decision

Diputuskan untuk menggunakan PHP sebagai bahasa pemrograman back-end, dan Laravel sebagai framework utamanya.

## Consequences

### Keuntungan

* Laravel memiliki ekosistem yang matang dan dokumentasi yang lengkap, mempermudah pengembangan dan debugging.
* PHP memiliki kurva belajar yang relatif rendah dan banyak developer yang familiar dengannya.
* Laravel mendukung struktur MVC yang telah disepakati dalam ADR 010, memperkuat konsistensi arsitektur proyek.
* Tersedia banyak package open-source yang dapat menghemat waktu pengembangan.

### Risiko

* PHP bukan bahasa modern yang paling optimal dalam hal performa untuk kasus tertentu.
* Laravel dapat terasa “opinionated” dan kompleks untuk developer baru yang belum familiar.

### Mitigasi

* Karena tim telah memiliki pengalaman menggunakan Laravel dari proyek sebelumnya, proses onboarding dan adaptasi akan lebih cepat. MVC.

## Alternatives Considered

- **Springboot (Java)**: Pengembangan dengan Spring Boot dinilai lebih kompleks dan membutuhkan waktu lebih untuk setup dan konfigurasi. Selain itu, mayoritas tim lebih familiar dengan PHP dibanding Java untuk pengembangan backend.

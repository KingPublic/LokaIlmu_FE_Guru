# ADR 006: Pemilihan Solusi Navigasi & Routing

## Status
Accepted

## Date
06/05/2025

## Decider 
Ketua Tim - @KingPublic

## Informed
@veryepiccindeed
@alicialisal
Calvin Richie

## Context

LokaIlmu memiliki beberapa flow user (guru dan mentor), serta fitur yang memerlukan nested navigation dan deep linking (misalnya ke forum diskusi tertentu atau detail pelatihan). Untuk mengelola ini dengan baik, dibutuhkan routing system yang fleksibel dan scalable.

## Decision

Kami memilih menggunakan **go\_router** sebagai solusi navigasi utama.

## Consequences

### Keuntungan

* **Declarative Routing**: Routing dideklarasikan di satu tempat, mudah dikelola.
* **Built-in Deep Linking**: Mendukung navigasi langsung ke halaman tertentu.
* **Nested Navigation**: Mudah membuat navigasi bertingkat (misalnya: tab di dalam tab).

### Risiko

* Perlu pembiasaan jika tim terbiasa dengan `Navigator.push` secara imperative.

### Mitigasi

* Template route dan dokumentasi internal disediakan sejak awal.

## Alternatives Considered

* Navigator 2.0 langsung: lebih fleksibel tapi terlalu verbose.
* AutoRoute: serupa, namun `go_router` lebih resmi dan terintegrasi dengan ekosistem Flutter.
* Manual routing dengan Navigator.push dan MaterialPageRoute: Cocok untuk aplikasi kecil, namun tidak scalable. Susah dikelola saat aplikasi tumbuh dan tidak mendukung deep linking/nested route secara deklaratif. (Bagus jika tidak mau repot diawal)
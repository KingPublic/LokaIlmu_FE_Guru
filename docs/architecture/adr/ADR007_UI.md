# ADR 007: Pendekatan Theming dan Styling UI

## Status

Accepted

## Context

LokaIlmu ditujukan untuk lintas platform (Android dan iOS). Saat ini pengujian dilakukan di Android, namun kompatibilitas dengan iOS tetap menjadi pertimbangan untuk masa depan. UI perlu tetap konsisten dan dapat disesuaikan dengan kebutuhan branding.

## Decision

Kami menggunakan pendekatan berbasis **Material Design** sebagai fondasi sistem UI, namun **tidak menggunakan ColorScheme otomatis dari Material 3**. Kami lebih memilih untuk menentukan warna secara eksplisit menggunakan color palette kustom. Hal ini karena tim kmai merasa lebih efisien mengatur styling langsung per elemen (misalnya tombol, teks) daripada menyesuaikan atau mengoverride sistem warna otomatis yang dimana sistem otomatis tersebut kebanyakan masih ada belum sesuai sekaligus menambah beban di tahap awal jika menggunakannya. (harus di deklarasikan semua warna yang kemungkinan digunakan)

## Consequences

### Keuntungan

* **Kontrol penuh** atas palet warna, karena tidak bergantung pada warna sistem.
* **Kompatibilitas lintas platform**: Material Design tetap memberikan dasar tampilan yang konsisten baik di Android maupun iOS.
* **Fleksibel**: Memungkinkan override styling secara langsung dan eksplisit.

### Risiko

* Tidak menggunakan fitur seperti dynamic theming dari OS (misalnya Android 12) yang bisa menghemat waktu.

### Mitigasi

* Struktur theming diatur dengan custom `AppTheme` dan `ThemeData` agar tetap rapi dan scalable.

## Alternatives Considered

* Cupertino: cocok untuk tampilan iOS, tapi terlalu terbatas dan tidak lintas platform.
* Full custom design system: akan lebih sulit untuk tahap awal.

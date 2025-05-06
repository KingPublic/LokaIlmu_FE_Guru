# ADR 002: Pemilihan BLoC untuk State Management

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

Aplikasi LokaIlmu membutuhkan manajemen state yang konsisten dan terstruktur, terutama untuk:

- Fitur real-time seperti forum diskusi.
- Proses asynchronous seperti progress pelatihan dan pengambilan materi.
- Interaksi kompleks antar komponen UI.

Flutter menawarkan berbagai pendekatan manajemen state seperti Provider, Riverpod, Redux, dan BLoC. Kami perlu memilih pendekatan yang paling sesuai dengan kebutuhan arsitektur MVVM yang telah dipilih sebelumnya.

## Decision

Kami memutuskan untuk menggunakan **BLoC (Business Logic Component)** sebagai solusi utama untuk manajemen state.

- BLoC akan diintegrasikan dalam layer **ViewModel** sebagai pengelola state dan event.
- Menggunakan pendekatan berbasis event dan stream untuk memisahkan alur logika dan representasi state UI secara jelas.

## Consequences

### Keuntungan

- **Predictable State Management**: Setiap perubahan state didasarkan pada event eksplisit.
- **Separation of Logic**: Logika bisnis dapat dipisahkan dari View dan dipusatkan dalam satu tempat.
- **Testable & Reusable**: BLoC dapat diuji dengan mudah dan digunakan ulang di berbagai ViewModel.

### Potensi Risiko

- **Verbosity**: Cenderung memerlukan lebih banyak kode boilerplate.
- **Learning Curve**: Membutuhkan pemahaman terhadap konsep stream dan event-state lifecycle.

### Mitigasi

- Menggunakan tools dan library tambahan seperti `flutter_bloc` untuk menyederhanakan boilerplate.
- Membangun template BLoC untuk mempermudah replikasi dan penggunaan oleh tim.

## Alternatives Considered

- **Provider**: Lebih ringan tapi tidak cocok untuk aplikasi dengan interaksi kompleks dan banyak state async.
- **Riverpod**: Lebih fleksibel, namun saat ini BLoC lebih dikenal dan terdokumentasi baik untuk kebutuhan MVVM.

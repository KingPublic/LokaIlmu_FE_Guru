# Integration Plan - Aplikasi Lokailmu

## 1. Arsitektur Diagram

![Arsitektur Lokailmu](./assets/lokailmu-architecture.png)

**Penjelasan:**
- UI (View) berkomunikasi dengan `Bloc`/`Cubit` yang mengelola state.
- Bloc berinteraksi dengan `Repository Layer` (Service).
- Repository mengelola API Call menggunakan Dio.
- Response dikembalikan ke Bloc, lalu UI menampilkan state sesuai hasil.

---

## 2. State Management Strategy

### Pendekatan: **BLoC / Cubit**

**Alasan Pemilihan**:
- **BLoC** cocok untuk aplikasi seperti **Lokailmu** yang:
  - Butuh **aliran data yang terstruktur dan dapat diuji**.
  - Memiliki banyak interaksi pengguna (login, membuka modul, mengirim komentar).
  - Memerlukan **pemisahan logika bisnis dari UI** secara jelas.

**Justifikasi**:
- Dengan BLoC, Lokailmu dapat mengelola state kompleks seperti loading, error, success dengan konsisten.
- Cocok digunakan di fitur-fitur seperti:
  - Autentikasi pengguna.
  - Pengambilan data modul.
  - Forum diskusi & komentar.
  - Notifikasi real-time (jika memakai WebSocket).

### Contoh Bloc:
- `AuthBloc` → Login, Logout
- `ModulBloc` → Ambil daftar modul
- `KomentarBloc` → Tambah komentar, lihat diskusi

---

## 3. API Strategy

### Library: [`Dio`](https://pub.dev/packages/dio)

**Kelebihan**:
- Dukungan interceptor (untuk token)
- Middleware-friendly (logging, error handling)
- Integrasi mudah dengan repository dalam arsitektur BLoC

### Autentikasi
- Skema: **Bearer Token**
- Penyimpanan: `flutter_secure_storage`
- Otomatisasi: Interceptor akan menambahkan token pada setiap request.

### Sample Endpoint

#### 1. `POST /api/v1/login`

```json
Request:
{
  "email": "guru@lokailmu.id",
  "password": "rahasia123"
}

Response:
{
  "token": "abc123def456",
  "user": {
    "id": 5,
    "name": "Ibu Sari",
    "role": "guru"
  }
}

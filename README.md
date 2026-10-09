# CRUD Mahasiswa

Aplikasi Flutter untuk materi Navigasi Flutter & Implementasi.

## Fitur

- Daftar mahasiswa dan pencarian nama, NIM, atau program studi.
- Tambah mahasiswa dengan validasi kolom wajib dan NIM unik.
- Detail mahasiswa, edit data, dan hapus dengan konfirmasi.
- Navigasi antar halaman menggunakan `Navigator.push`, `MaterialPageRoute`,
  dan `Navigator.pop` dengan hasil data; Drawer untuk daftar/tambah mahasiswa.

Data awal berupa tiga mahasiswa contoh. Data disimpan dalam memori selama
aplikasi berjalan, tanpa backend/database. Restart aplikasi mengembalikan data awal.

## Menjalankan

```sh
flutter pub get
flutter run
```

## Verifikasi

```sh
flutter analyze
flutter test
```

Kode dipisah menjadi model (`lib/models/mahasiswa.dart`) dan halaman daftar,
form tambah/edit, serta detail (`lib/pages/`).

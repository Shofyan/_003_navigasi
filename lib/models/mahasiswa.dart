import 'dart:typed_data';

class Mahasiswa {
  final String nim, nama, prodi, panggilan, email, noHp, password;
  final String jenisKelamin, tempatLahir, agama, kelas, status, alamat;
  final String provinsi, kota;
  final DateTime? tanggalLahir;
  final int semester, warnaProfil;
  final double ipk;
  final bool beasiswa, magang, persetujuan;
  final List<String> minat;
  final Uint8List? foto, dokumen;
  final String? namaDokumen;

  const Mahasiswa({
    required this.nim,
    required this.nama,
    required this.prodi,
    this.panggilan = '',
    this.email = '',
    this.noHp = '',
    this.password = '',
    this.jenisKelamin = 'Laki-laki',
    this.tempatLahir = '',
    this.agama = 'Islam',
    this.kelas = 'A',
    this.status = 'Aktif',
    this.alamat = '',
    this.provinsi = 'Jawa Barat',
    this.kota = 'Bogor',
    this.tanggalLahir,
    this.semester = 1,
    this.warnaProfil = 0xff6750a4,
    this.ipk = 0,
    this.beasiswa = false,
    this.magang = false,
    this.persetujuan = false,
    this.minat = const [],
    this.foto,
    this.dokumen,
    this.namaDokumen,
  });
}

const wilayah = {
  'Jawa Barat': ['Bogor', 'Depok', 'Bandung', 'Bekasi'],
  'DKI Jakarta': [
    'Jakarta Pusat',
    'Jakarta Selatan',
    'Jakarta Timur',
    'Jakarta Barat',
    'Jakarta Utara',
  ],
  'Banten': ['Tangerang', 'Tangerang Selatan', 'Serang'],
  'Jawa Tengah': ['Semarang', 'Surakarta', 'Magelang'],
  'Jawa Timur': ['Surabaya', 'Malang', 'Kediri'],
};
const warnaPilihan = [
  0xff6750a4,
  0xff1565c0,
  0xff00897b,
  0xffef6c00,
  0xffc2185b,
];
String formatTanggal(DateTime? date) => date == null
    ? 'Belum diisi'
    : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

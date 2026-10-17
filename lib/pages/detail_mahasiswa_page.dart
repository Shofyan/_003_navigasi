import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';
import 'form_mahasiswa_page.dart';

class DetailResult {
  final Mahasiswa? mahasiswa;
  const DetailResult.updated(Mahasiswa this.mahasiswa);
  const DetailResult.deleted() : mahasiswa = null;
}

class DetailMahasiswaPage extends StatefulWidget {
  final Mahasiswa mahasiswa;
  final Set<String> nimLain;

  const DetailMahasiswaPage({
    super.key,
    required this.mahasiswa,
    required this.nimLain,
  });

  @override
  State<DetailMahasiswaPage> createState() => _DetailMahasiswaPageState();
}

class _DetailMahasiswaPageState extends State<DetailMahasiswaPage> {
  Future<void> _edit() async {
    final result = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMahasiswaPage(
          mahasiswa: widget.mahasiswa,
          nimTerpakai: widget.nimLain,
        ),
      ),
    );
    if (!mounted || result == null) return;
    Navigator.pop(context, DetailResult.updated(result));
  }

  Future<void> _hapus() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus mahasiswa?'),
        content: Text(
          'Data ${widget.mahasiswa.nama} (${widget.mahasiswa.nim}) akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    Navigator.pop(context, const DetailResult.deleted());
  }

  @override
  Widget build(BuildContext context) {
    final mahasiswa = widget.mahasiswa;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mahasiswa')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(mahasiswa.warnaProfil),
                  backgroundImage: mahasiswa.fotoProfil == null
                      ? null
                      : MemoryImage(mahasiswa.fotoProfil!),
                  child: mahasiswa.fotoProfil == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Nama Lengkap'),
                subtitle: Text(mahasiswa.nama),
              ),
              ListTile(title: const Text('NIM'), subtitle: Text(mahasiswa.nim)),
              ListTile(
                title: const Text('Program Studi'),
                subtitle: Text(mahasiswa.prodi),
              ),
              ListTile(
                title: const Text('Nomor Telepon'),
                subtitle: Text(mahasiswa.phone),
              ),
              for (final entry in <String, String>{
                'Nama Panggilan': mahasiswa.namaPanggilan,
                'Jenis Kelamin': mahasiswa.jenisKelamin,
                'Tempat Lahir': mahasiswa.tempatLahir,
                'Tanggal Lahir': mahasiswa.tanggalLahir == null
                    ? ''
                    : '${mahasiswa.tanggalLahir!.day}/${mahasiswa.tanggalLahir!.month}/${mahasiswa.tanggalLahir!.year}',
                'Agama': mahasiswa.agama,
                'Semester': '${mahasiswa.semester}',
                'Kelas': mahasiswa.kelas,
                'Status Mahasiswa': mahasiswa.status,
                'IPK': mahasiswa.ipk.toStringAsFixed(2),
                'Penerima Beasiswa': mahasiswa.beasiswa ? 'Ya' : 'Tidak',
                'Bersedia Magang': mahasiswa.bersediaMagang ? 'Ya' : 'Tidak',
                'Email': mahasiswa.email,
                'Alamat': mahasiswa.alamat,
                'Provinsi': mahasiswa.provinsi,
                'Kota/Kabupaten': mahasiswa.kota,
                'Minat': mahasiswa.minat.join(', '),
                'Dokumen/KTM': mahasiswa.namaDokumen ?? '',
                'Persetujuan Data': mahasiswa.persetujuan
                    ? 'Setuju'
                    : 'Belum disetujui',
              }.entries)
                ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value.isEmpty ? '—' : entry.value),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Data'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _hapus,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

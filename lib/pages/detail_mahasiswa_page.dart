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
              const Icon(Icons.school_outlined, size: 72),
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

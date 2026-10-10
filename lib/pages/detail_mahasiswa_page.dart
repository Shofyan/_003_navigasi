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
    Widget item(String label, String value, IconData icon) => Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value.isEmpty ? 'Belum diisi' : value),
      ),
    );
    Widget panel(List<Widget> children) =>
        ListView(padding: const EdgeInsets.all(20), children: children);
    String yes(bool value) => value ? 'Ya' : 'Tidak';
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Mahasiswa'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.person_outline), text: 'Pribadi'),
              Tab(icon: Icon(Icons.school_outlined), text: 'Akademik'),
              Tab(icon: Icon(Icons.location_on_outlined), text: 'Alamat'),
              Tab(icon: Icon(Icons.folder_outlined), text: 'Lampiran'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(mahasiswa.warnaProfil),
                        backgroundImage: mahasiswa.foto == null
                            ? null
                            : MemoryImage(mahasiswa.foto!),
                        child: mahasiswa.foto == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mahasiswa.nama,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text('${mahasiswa.nim} • ${mahasiswa.prodi}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      panel([
                        item(
                          'Nama Lengkap',
                          mahasiswa.nama,
                          Icons.person_outline,
                        ),
                        item('NIM', mahasiswa.nim, Icons.badge_outlined),
                        item(
                          'Nama Panggilan',
                          mahasiswa.panggilan,
                          Icons.face_outlined,
                        ),
                        item('Email', mahasiswa.email, Icons.email_outlined),
                        item('No. HP', mahasiswa.noHp, Icons.phone_outlined),
                        item(
                          'Password Portal',
                          mahasiswa.password.isEmpty ? '' : '••••••••',
                          Icons.lock_outline,
                        ),
                        item(
                          'Jenis Kelamin',
                          mahasiswa.jenisKelamin,
                          Icons.people_outline,
                        ),
                        item(
                          'Tanggal Lahir',
                          formatTanggal(mahasiswa.tanggalLahir),
                          Icons.calendar_month,
                        ),
                        item(
                          'Tempat Lahir',
                          mahasiswa.tempatLahir,
                          Icons.place_outlined,
                        ),
                        item('Agama', mahasiswa.agama, Icons.diversity_3),
                      ]),
                      panel([
                        item(
                          'Program Studi',
                          mahasiswa.prodi,
                          Icons.school_outlined,
                        ),
                        item(
                          'Semester',
                          '${mahasiswa.semester}',
                          Icons.numbers,
                        ),
                        item('Kelas', mahasiswa.kelas, Icons.class_outlined),
                        item(
                          'Status Mahasiswa',
                          mahasiswa.status,
                          Icons.verified_outlined,
                        ),
                        item(
                          'IPK',
                          mahasiswa.ipk.toStringAsFixed(2),
                          Icons.star_outline,
                        ),
                        item(
                          'Penerima Beasiswa',
                          yes(mahasiswa.beasiswa),
                          Icons.workspace_premium_outlined,
                        ),
                        item(
                          'Bersedia Magang',
                          yes(mahasiswa.magang),
                          Icons.work_outline,
                        ),
                        item(
                          'Minat',
                          mahasiswa.minat.join(', '),
                          Icons.interests_outlined,
                        ),
                      ]),
                      panel([
                        item('Alamat', mahasiswa.alamat, Icons.home_outlined),
                        item(
                          'Provinsi',
                          mahasiswa.provinsi,
                          Icons.map_outlined,
                        ),
                        item(
                          'Kota/Kabupaten',
                          mahasiswa.kota,
                          Icons.location_city,
                        ),
                      ]),
                      panel([
                        if (mahasiswa.foto != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              mahasiswa.foto!,
                              height: 240,
                              fit: BoxFit.contain,
                            ),
                          )
                        else
                          item(
                            'Foto Profil',
                            'Belum ada foto',
                            Icons.photo_outlined,
                          ),
                        item(
                          'Dokumen/KTM',
                          mahasiswa.namaDokumen ?? 'Belum ada dokumen',
                          Icons.attach_file,
                        ),
                        if (mahasiswa.dokumen != null)
                          item(
                            'Ukuran dokumen',
                            '${(mahasiswa.dokumen!.length / 1024).toStringAsFixed(1)} KB',
                            Icons.description_outlined,
                          ),
                        Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.palette_outlined,
                              color: Color(mahasiswa.warnaProfil),
                            ),
                            title: const Text('Warna Profil'),
                            trailing: CircleAvatar(
                              backgroundColor: Color(mahasiswa.warnaProfil),
                              radius: 16,
                            ),
                          ),
                        ),
                        item(
                          'Persetujuan Data',
                          yes(mahasiswa.persetujuan),
                          Icons.fact_check_outlined,
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _edit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Data'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _hapus,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Hapus Data'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

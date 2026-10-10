import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';
import 'detail_mahasiswa_page.dart';
import 'form_mahasiswa_page.dart';

class ListMahasiswaPage extends StatefulWidget {
  const ListMahasiswaPage({super.key});

  @override
  State<ListMahasiswaPage> createState() => _ListMahasiswaPageState();
}

class _ListMahasiswaPageState extends State<ListMahasiswaPage> {
  final _search = TextEditingController();
  final _mahasiswa = <Mahasiswa>[
    const Mahasiswa(
      nim: '2026001',
      nama: 'Andi Pratama',
      prodi: 'Teknik Informatika',
    ),
    const Mahasiswa(
      nim: '2026002',
      nama: 'Siti Aisyah',
      prodi: 'Sistem Informasi',
    ),
    const Mahasiswa(nim: '2026003', nama: 'Budi Santoso', prodi: 'Manajemen'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Set<String> _nimTerpakai([Mahasiswa? except]) => _mahasiswa
      .where((item) => item != except)
      .map((item) => item.nim.toLowerCase())
      .toSet();

  void _pesan(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _tambah() async {
    final result = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMahasiswaPage(nimTerpakai: _nimTerpakai()),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _mahasiswa.add(result));
    _pesan('Data mahasiswa berhasil ditambahkan');
  }

  Future<void> _detail(Mahasiswa mahasiswa) async {
    final result = await Navigator.push<DetailResult>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMahasiswaPage(
          mahasiswa: mahasiswa,
          nimLain: _nimTerpakai(mahasiswa),
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      final index = _mahasiswa.indexOf(mahasiswa);
      if (result.mahasiswa == null) {
        _mahasiswa.removeAt(index);
      } else {
        _mahasiswa[index] = result.mahasiswa!;
      }
    });
    _pesan(
      result.mahasiswa == null
          ? 'Data mahasiswa berhasil dihapus'
          : 'Data mahasiswa berhasil diperbarui',
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyword = _search.text.trim().toLowerCase();
    final filtered = _mahasiswa
        .where(
          (item) =>
              item.nama.toLowerCase().contains(keyword) ||
              item.nim.toLowerCase().contains(keyword) ||
              item.prodi.toLowerCase().contains(keyword),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Data Mahasiswa')),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(child: Text('Manajemen Mahasiswa')),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Daftar Mahasiswa'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person_add_outlined),
                title: const Text('Tambah Mahasiswa'),
                onTap: () {
                  Navigator.pop(context);
                  _tambah();
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Cari nama, NIM, atau program studi',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(_search.clear),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filtered.length} dari ${_mahasiswa.length} mahasiswa',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          _mahasiswa.isEmpty
                              ? 'Belum ada mahasiswa. Tambahkan data baru.'
                              : 'Mahasiswa tidak ditemukan.',
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final mahasiswa = filtered[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person_outline),
                            ),
                            title: Text(mahasiswa.nama),
                            subtitle: Text(
                              '${mahasiswa.nim} • ${mahasiswa.prodi}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _detail(mahasiswa),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mahasiswa'),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';

class FormMahasiswaPage extends StatefulWidget {
  final Mahasiswa? mahasiswa;
  final Set<String> nimTerpakai;

  const FormMahasiswaPage({
    super.key,
    this.mahasiswa,
    required this.nimTerpakai,
  });

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nim;
  late final TextEditingController _nama;
  late final TextEditingController _prodi;

  @override
  void initState() {
    super.initState();
    _nim = TextEditingController(text: widget.mahasiswa?.nim);
    _nama = TextEditingController(text: widget.mahasiswa?.nama);
    _prodi = TextEditingController(text: widget.mahasiswa?.prodi);
  }

  @override
  void dispose() {
    _nim.dispose();
    _nama.dispose();
    _prodi.dispose();
    super.dispose();
  }

  String? _wajib(String? value, String label) {
    return value == null || value.trim().isEmpty
        ? '$label tidak boleh kosong'
        : null;
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Mahasiswa(
        nim: _nim.text.trim(),
        nama: _nama.text.trim(),
        prodi: _prodi.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: _nim,
                  decoration: const InputDecoration(labelText: 'NIM'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final error = _wajib(value, 'NIM');
                    if (error != null) return error;
                    if (widget.nimTerpakai.contains(
                      value!.trim().toLowerCase(),
                    )) {
                      return 'NIM sudah digunakan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nama,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (value) => _wajib(value, 'Nama'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prodi,
                  decoration: const InputDecoration(labelText: 'Program Studi'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  validator: (value) => _wajib(value, 'Program studi'),
                  onFieldSubmitted: (_) => _simpan(),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan Data'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

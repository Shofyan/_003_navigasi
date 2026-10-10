import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

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

class _FormMahasiswaPageState extends State<FormMahasiswaPage>
    with SingleTickerProviderStateMixin {
  final _keys = List.generate(4, (_) => GlobalKey<FormState>());
  final _controllers = <String, TextEditingController>{};
  late final TabController _tabs;
  late String _gender, _agama, _prodi, _kelas, _status, _provinsi, _kota;
  late int _semester, _warna;
  late double _ipk;
  late bool _beasiswa, _magang, _setuju;
  bool _passwordVisible = false, _busy = false;
  DateTime? _lahir;
  Uint8List? _foto, _dokumen;
  String? _namaDokumen;
  late Set<String> _minat;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    final m = widget.mahasiswa;
    final values = {
      'NIM': m?.nim,
      'Nama Lengkap': m?.nama,
      'Nama Panggilan': m?.panggilan,
      'Email': m?.email,
      'No. HP': m?.noHp,
      'Password Portal': m?.password,
      'Tempat Lahir': m?.tempatLahir,
      'Alamat': m?.alamat,
    };
    for (final e in values.entries) {
      _controllers[e.key] = TextEditingController(text: e.value);
    }
    _gender = m?.jenisKelamin ?? 'Laki-laki';
    _agama = m?.agama ?? 'Islam';
    _prodi = m?.prodi ?? 'Teknik Informatika';
    _kelas = m?.kelas ?? 'A';
    _status = m?.status ?? 'Aktif';
    _provinsi = m?.provinsi ?? 'Jawa Barat';
    _kota = m?.kota ?? 'Bogor';
    _semester = m?.semester ?? 1;
    _warna = m?.warnaProfil ?? warnaPilihan.first;
    _ipk = m?.ipk ?? 0;
    _beasiswa = m?.beasiswa ?? false;
    _magang = m?.magang ?? false;
    _setuju = m?.persetujuan ?? false;
    _lahir = m?.tanggalLahir;
    _foto = m?.foto;
    _dokumen = m?.dokumen;
    _namaDokumen = m?.namaDokumen;
    _minat = {...?m?.minat};
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _text(String name) => _controllers[name]!.text.trim();
  void _pesan(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _simpan() {
    for (var i = 0; i < _keys.length; i++) {
      if (_keys[i].currentState?.validate() == false) {
        _tabs.animateTo(i);
        return;
      }
    }
    // All tab forms stay mounted so validation also covers unvisited tabs.
    final nim = _text('NIM');
    final nama = _text('Nama Lengkap');
    if (nim.isEmpty ||
        nama.isEmpty ||
        widget.nimTerpakai.contains(nim.toLowerCase())) {
      _tabs.animateTo(0);
      _keys[0].currentState?.validate();
      return;
    }
    if (!_setuju) {
      _tabs.animateTo(3);
      _pesan('Setujui penggunaan data sebelum menyimpan.');
      return;
    }
    Navigator.pop(
      context,
      Mahasiswa(
        nim: nim,
        nama: nama,
        prodi: _prodi,
        panggilan: _text('Nama Panggilan'),
        email: _text('Email'),
        noHp: _text('No. HP'),
        password: _text('Password Portal'),
        jenisKelamin: _gender,
        tanggalLahir: _lahir,
        tempatLahir: _text('Tempat Lahir'),
        agama: _agama,
        semester: _semester,
        kelas: _kelas,
        status: _status,
        ipk: _ipk,
        beasiswa: _beasiswa,
        magang: _magang,
        minat: _minat.toList(),
        alamat: _text('Alamat'),
        provinsi: _provinsi,
        kota: _kota,
        foto: _foto,
        dokumen: _dokumen,
        namaDokumen: _namaDokumen,
        warnaProfil: _warna,
        persetujuan: _setuju,
      ),
    );
  }

  Future<void> _pilihFoto(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _foto = bytes);
    } catch (_) {
      if (mounted) {
        _pesan('Foto tidak dapat diakses. Periksa izin kamera atau galeri.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pilihDokumen() async {
    setState(() => _busy = true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (file == null) return;
      final size = await file.length();
      if (size != null && size > 10 * 1024 * 1024) {
        if (mounted) _pesan('Ukuran dokumen maksimal 10 MB.');
        return;
      }
      final bytes = await file.readAsBytes();
      if (bytes.length > 10 * 1024 * 1024) {
        if (mounted) _pesan('Ukuran dokumen maksimal 10 MB.');
        return;
      }
      if (mounted) {
        setState(() {
          _dokumen = bytes;
          _namaDokumen = file.name;
        });
      }
    } catch (_) {
      if (mounted) _pesan('Dokumen tidak dapat dipilih. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(
    String name,
    IconData icon, {
    bool required = false,
    TextInputType? keyboard,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      key: ValueKey(name),
      controller: _controllers[name],
      keyboardType: keyboard,
      maxLines: lines,
      obscureText: name == 'Password Portal' && !_passwordVisible,
      decoration: InputDecoration(
        labelText: name,
        prefixIcon: Icon(icon),
        suffixIcon: name == 'Password Portal'
            ? IconButton(
                tooltip: _passwordVisible
                    ? 'Sembunyikan password'
                    : 'Tampilkan password',
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) {
          return '${name == 'Nama Lengkap' ? 'Nama' : name} tidak boleh kosong';
        }
        if (name == 'NIM' && widget.nimTerpakai.contains(text.toLowerCase())) {
          return 'NIM sudah digunakan';
        }
        if (name == 'Email' &&
            text.isNotEmpty &&
            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
          return 'Format email tidak valid';
        }
        return null;
      },
    ),
  );
  Widget _dropdown<T>(
    String label,
    IconData icon,
    T value,
    List<T> items,
    ValueChanged<T> change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      key: ValueKey('$label$value'),
      isExpanded: true,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: items
          .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => change(v));
      },
    ),
  );
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
  Widget _panel(int index, List<Widget> children) => Form(
    key: _keys[index],
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa',
      ),
      bottom: TabBar(
        controller: _tabs,
        isScrollable: true,
        tabs: const [
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
        child: AnimatedBuilder(
          animation: _tabs,
          builder: (context, _) => IndexedStack(
            index: _tabs.index,
            children: [
              _panel(0, [
                _field('NIM', Icons.badge_outlined, required: true),
                _field('Nama Lengkap', Icons.person_outline, required: true),
                _field('Nama Panggilan', Icons.face_outlined),
                _field(
                  'Email',
                  Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                ),
                _field(
                  'No. HP',
                  Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),
                _field('Password Portal', Icons.lock_outline),
                _label('Jenis Kelamin'),
                RadioGroup<String>(
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v!),
                  child: Column(
                    children: ['Laki-laki', 'Perempuan']
                        .map((v) => RadioListTile(value: v, title: Text(v)))
                        .toList(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Tanggal Lahir'),
                  subtitle: Text(formatTanggal(_lahir)),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _lahir ?? DateTime(now.year - 18),
                      firstDate: DateTime(1900),
                      lastDate: now,
                    );
                    if (mounted && date != null) setState(() => _lahir = date);
                  },
                ),
                const SizedBox(height: 16),
                _field('Tempat Lahir', Icons.place_outlined),
                _dropdown('Agama', Icons.diversity_3, _agama, [
                  'Islam',
                  'Kristen',
                  'Katolik',
                  'Hindu',
                  'Buddha',
                  'Konghucu',
                ], (v) => _agama = v),
              ]),
              _panel(1, [
                _dropdown(
                  'Program Studi',
                  Icons.school_outlined,
                  _prodi,
                  {
                    ...[
                      'Teknik Informatika',
                      'Sistem Informasi',
                      'Teknologi Rekayasa Multimedia',
                      'Manajemen',
                      'Akuntansi',
                      'TRM',
                      'TI',
                      'SI',
                    ],
                    _prodi,
                  }.toList(),
                  (v) => _prodi = v,
                ),
                _dropdown(
                  'Semester',
                  Icons.numbers,
                  _semester,
                  List.generate(8, (i) => i + 1),
                  (v) => _semester = v,
                ),
                _label('Kelas'),
                SegmentedButton<String>(
                  segments: ['A', 'B', 'C']
                      .map((v) => ButtonSegment(value: v, label: Text(v)))
                      .toList(),
                  selected: {_kelas},
                  onSelectionChanged: (v) => setState(() => _kelas = v.first),
                ),
                _label('Status Mahasiswa'),
                Wrap(
                  spacing: 8,
                  children: ['Aktif', 'Cuti', 'Lulus']
                      .map(
                        (v) => ChoiceChip(
                          label: Text(v),
                          selected: _status == v,
                          onSelected: (_) => setState(() => _status = v),
                        ),
                      )
                      .toList(),
                ),
                _label('IPK: ${_ipk.toStringAsFixed(2)}'),
                Slider(
                  value: _ipk,
                  min: 0,
                  max: 4,
                  divisions: 400,
                  label: _ipk.toStringAsFixed(2),
                  onChanged: (v) => setState(() => _ipk = v),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.workspace_premium_outlined),
                  title: const Text('Penerima Beasiswa'),
                  value: _beasiswa,
                  onChanged: (v) => setState(() => _beasiswa = v),
                ),
                CheckboxListTile(
                  secondary: const Icon(Icons.work_outline),
                  title: const Text('Bersedia Magang'),
                  value: _magang,
                  onChanged: (v) => setState(() => _magang = v!),
                ),
                _label('Minat'),
                Wrap(
                  spacing: 8,
                  children: ['Mobile', 'Web', 'AI', 'UI/UX', 'Data']
                      .map(
                        (v) => FilterChip(
                          label: Text(v),
                          selected: _minat.contains(v),
                          onSelected: (selected) => setState(() {
                            selected ? _minat.add(v) : _minat.remove(v);
                          }),
                        ),
                      )
                      .toList(),
                ),
              ]),
              _panel(2, [
                _field('Alamat', Icons.home_outlined, lines: 4),
                _dropdown(
                  'Provinsi',
                  Icons.map_outlined,
                  _provinsi,
                  wilayah.keys.toList(),
                  (v) {
                    _provinsi = v;
                    _kota = wilayah[v]!.first;
                  },
                ),
                _dropdown(
                  'Kota/Kabupaten',
                  Icons.location_city,
                  _kota,
                  wilayah[_provinsi]!,
                  (v) => _kota = v,
                ),
              ]),
              _panel(3, [
                Center(
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Color(_warna),
                    backgroundImage: _foto == null ? null : MemoryImage(_foto!),
                    child: _foto == null
                        ? const Icon(
                            Icons.person,
                            size: 56,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                _label('Foto Profil'),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _pilihFoto(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Kamera'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _pilihFoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeri'),
                    ),
                    if (_foto != null)
                      IconButton(
                        tooltip: 'Hapus foto',
                        onPressed: _busy
                            ? null
                            : () => setState(() => _foto = null),
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
                _label('Dokumen/KTM'),
                Text(_namaDokumen ?? 'Belum ada dokumen'),
                const Text('PDF atau gambar, maksimal 10 MB'),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pilihDokumen,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Pilih Dokumen'),
                ),
                if (_namaDokumen != null)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _dokumen = null;
                            _namaDokumen = null;
                          }),
                    child: const Text('Hapus dokumen'),
                  ),
                if (_busy) const LinearProgressIndicator(),
                _label('Warna Profil'),
                Wrap(
                  spacing: 12,
                  children: warnaPilihan
                      .map(
                        (v) => Semantics(
                          label: 'Warna profil ${warnaPilihan.indexOf(v) + 1}',
                          selected: _warna == v,
                          child: InkWell(
                            onTap: () => setState(() => _warna = v),
                            borderRadius: BorderRadius.circular(24),
                            child: CircleAvatar(
                              backgroundColor: Color(v),
                              child: _warna == v
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Saya menyetujui penggunaan data profil ini',
                  ),
                  value: _setuju,
                  onChanged: (v) => setState(() => _setuju = v!),
                ),
              ]),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _busy ? null : _simpan,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Simpan Data'),
        ),
      ),
    ),
  );
}

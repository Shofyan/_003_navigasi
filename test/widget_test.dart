import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_003_navigasi/main.dart';

Future<void> isiForm(
  WidgetTester tester,
  String nim,
  String nama,
  String prodi,
) async {
  await tester.enterText(find.byKey(const ValueKey('NIM')), nim);
  await tester.enterText(find.byKey(const ValueKey('Nama Lengkap')), nama);
  await tester.tap(find.text('Akademik'));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownButtonFormField<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(prodi).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Lampiran'));
  await tester.pumpAndSettle();
  final consent = find.widgetWithText(
    CheckboxListTile,
    'Saya menyetujui penggunaan data profil ini',
  );
  await tester.ensureVisible(consent);
  if (!(tester.widget<CheckboxListTile>(consent).value ?? false)) {
    await tester.tap(consent);
  }
  await tester.tap(find.text('Simpan Data'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Tambah, baca detail, edit, dan hapus mahasiswa', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Mahasiswa'));
    await tester.pumpAndSettle();
    await isiForm(tester, '2026004', 'Dewi Lestari', 'Akuntansi');
    expect(find.text('Dewi Lestari'), findsOneWidget);

    await tester.tap(find.text('Dewi Lestari'));
    await tester.pumpAndSettle();
    expect(find.text('2026004'), findsOneWidget);
    await tester.tap(find.text('Akademik'));
    await tester.pumpAndSettle();
    expect(find.text('Akuntansi'), findsOneWidget);
    await tester.tap(find.text('Edit Data'));
    await tester.pumpAndSettle();
    await isiForm(tester, '2026004', 'Dewi Putri', 'Manajemen');
    expect(find.text('Dewi Putri'), findsOneWidget);
    expect(find.text('Dewi Lestari'), findsNothing);

    await tester.tap(find.text('Dewi Putri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Dewi Putri'), findsNWidgets(2));
    await tester.tap(find.text('Hapus Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Dewi Putri'), findsNothing);
    expect(find.text('3 dari 3 mahasiswa'), findsOneWidget);
  });

  testWidgets('Form menolak data kosong dan NIM duplikat', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Mahasiswa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Data'));
    await tester.pumpAndSettle();
    expect(find.text('NIM tidak boleh kosong'), findsOneWidget);
    expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
    await isiForm(tester, '2026001', 'Nama Baru', 'Sistem Informasi');
    expect(find.text('NIM sudah digunakan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('3 dari 3 mahasiswa'), findsOneWidget);
  });

  testWidgets('Validasi lintas tab dan persetujuan data', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Mahasiswa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('NIM')), '2026010');
    await tester.enterText(find.byKey(const ValueKey('Nama Lengkap')), 'Nadia');
    final email = find.byKey(const ValueKey('Email'));
    await tester.ensureVisible(email);
    await tester.enterText(email, 'email-salah');
    await tester.tap(find.text('Akademik'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Data'));
    await tester.pumpAndSettle();
    expect(find.text('Format email tidak valid'), findsOneWidget);
    await tester.ensureVisible(email);
    await tester.enterText(email, 'nadia@kampus.ac.id');
    await tester.tap(find.text('Simpan Data'));
    await tester.pumpAndSettle();
    expect(
      find.text('Setujui penggunaan data sebelum menyimpan.'),
      findsOneWidget,
    );
    expect(find.text('Kamera'), findsOneWidget);
    expect(find.text('Galeri'), findsOneWidget);
    final consent = find.widgetWithText(
      CheckboxListTile,
      'Saya menyetujui penggunaan data profil ini',
    );
    await tester.ensureVisible(consent);
    await tester.tap(consent);
    await tester.tap(find.text('Simpan Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nadia'));
    await tester.pumpAndSettle();
    final savedEmail = find.text('nadia@kampus.ac.id');
    await tester.scrollUntilVisible(
      savedEmail,
      150,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(savedEmail, findsOneWidget);
    await tester.tap(find.text('Edit Data'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('Email')))
          .controller!
          .text,
      'nadia@kampus.ac.id',
    );
  });

  testWidgets('Pencarian nama, NIM, prodi dan keadaan kosong', (tester) async {
    await tester.pumpWidget(const MyApp());
    final search = find.byType(TextField);
    await tester.enterText(search, '  SITI  ');
    await tester.pumpAndSettle();
    expect(find.text('Siti Aisyah'), findsOneWidget);
    expect(find.text('Andi Pratama'), findsNothing);
    await tester.enterText(search, '2026001');
    await tester.pumpAndSettle();
    expect(find.text('Andi Pratama'), findsOneWidget);
    await tester.enterText(search, 'manajemen');
    await tester.pumpAndSettle();
    expect(find.text('Budi Santoso'), findsOneWidget);
    await tester.enterText(search, 'tidak ada');
    await tester.pumpAndSettle();
    expect(find.text('Mahasiswa tidak ditemukan.'), findsOneWidget);
    await tester.tap(find.byTooltip('Hapus pencarian'));
    await tester.pumpAndSettle();
    expect(find.text('3 dari 3 mahasiswa'), findsOneWidget);
  });
}

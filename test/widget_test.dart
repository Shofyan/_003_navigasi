import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_003_navigasi/main.dart';

Future<void> isiForm(
  WidgetTester tester,
  String nim,
  String nama,
  String prodi,
) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), nim);
  await tester.enterText(fields.at(1), nama);
  await tester.enterText(fields.at(2), prodi);
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
    expect(find.text('Dewi Putri'), findsOneWidget);
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
    await isiForm(tester, ' ', ' ', ' ');
    expect(find.text('NIM tidak boleh kosong'), findsOneWidget);
    expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
    expect(find.text('Program studi tidak boleh kosong'), findsOneWidget);
    await isiForm(tester, '2026001', 'Nama Baru', 'Prodi Baru');
    expect(find.text('NIM sudah digunakan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('3 dari 3 mahasiswa'), findsOneWidget);
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

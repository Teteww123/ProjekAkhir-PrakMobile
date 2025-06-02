import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_projek/main.dart';

// Ini contoh test sederhana untuk aplikasi utama kamu.
void main() {
  testWidgets('MyApp menampilkan judul dan pesan', (WidgetTester tester) async {
    // Build aplikasi dan trigger frame.
   await tester.pumpWidget(MyApp());

    // Verifikasi apakah ada teks judul dan pesan pada tampilan awal.
    expect(find.text('Gadget Catalog'), findsOneWidget);
    expect(find.text('Hello, Gadget!'), findsOneWidget);
  });
}
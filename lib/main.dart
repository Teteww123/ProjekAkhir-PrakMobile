import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/gadget.dart';
import 'views/gadget_list_page.dart';
import 'auth/login_page.dart'; // Tambahkan import untuk login_page.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive
  await Hive.initFlutter();

  // Register adapter
  Hive.registerAdapter(GadgetAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gadget Catalog',
      home: const LoginPage(), // Ubah halaman awal menjadi LoginPage
    );
  }
}
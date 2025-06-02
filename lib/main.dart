import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/gadget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GadgetAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gadget Catalog',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Gadget Catalog')),
        body: Center(
          child: Text('Hello, Gadget!'), // Ganti dengan halaman utama kamu nanti
        ),
      ),
    );
  }
}
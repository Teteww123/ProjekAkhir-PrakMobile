import 'package:flutter/material.dart';
import 'views/gadget_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gadget Catalog',
      home: Scaffold(
        appBar: AppBar(title: const Text('Gadget Catalog')),
        body: const GadgetListPage(),
      ),
    );
  }
}
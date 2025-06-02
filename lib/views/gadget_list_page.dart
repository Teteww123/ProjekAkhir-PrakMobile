import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/gadget.dart';

class GadgetListPage extends StatefulWidget {
  const GadgetListPage({super.key});

  @override
  State<GadgetListPage> createState() => _GadgetListPageState();
}

class _GadgetListPageState extends State<GadgetListPage> {
  List<Gadget> _gadgets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Coba ambil dari Hive lebih dulu (offline)
      final box = await Hive.openBox<Gadget>('gadgets');
      final localGadgets = box.values.toList();

      if (localGadgets.isNotEmpty) {
        setState(() {
          _gadgets = localGadgets;
          _isLoading = false;
        });
      }

      // Ambil dari API (online)
      final response = await http.get(Uri.parse('https://example.com/api/gadgets')); // Ganti endpoint!
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Gadget> gadgetsApi = data.map((json) => Gadget.fromJson(json)).toList();

        // Simpan ke Hive untuk cache offline
        await box.clear();
        await box.addAll(gadgetsApi);

        setState(() {
          _gadgets = gadgetsApi;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load from API: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_gadgets.isEmpty) {
      return const Center(child: Text('Tidak ada gadget.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _gadgets.length,
        itemBuilder: (context, index) {
          final gadget = _gadgets[index];
          return ListTile(
            title: Text(gadget.name),
            subtitle: Text(gadget.data?['CPU model']?.toString() ?? ''),
            // Tampilkan data lain sesuai kebutuhan
          );
        },
      ),
    );
  }
}
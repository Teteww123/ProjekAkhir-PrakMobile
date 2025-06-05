import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gadget.dart';
import '../core/api/api_service.dart';
import 'gadget_form_page.dart';
import '/auth/login_page.dart';

class GadgetListPage extends StatefulWidget {
  const GadgetListPage({super.key});

  @override
  State<GadgetListPage> createState() => _GadgetListPageState();
}

class _GadgetListPageState extends State<GadgetListPage> {
  List<Gadget> remoteGadgets = [];
  List<Gadget> localGadgets = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchFromApi();
    _loadLocalGadgets();
  }

  Future<void> _fetchFromApi() async {
    try {
      final apiData = await apiService.fetchGadgets();
      setState(() {
        remoteGadgets = apiData;
      });
    } catch (e) {
      // handle error
    }
  }

  Future<void> _loadLocalGadgets() async {
    final box = await Hive.openBox<Gadget>('gadgets');
    setState(() {
      localGadgets = box.values.toList();
    });
  }

  Future<void> _editLocalGadget(int index, Gadget editedGadget) async {
    final box = await Hive.openBox<Gadget>('gadgets');
    final key = box.keyAt(index);
    await box.put(key, editedGadget);
    await _loadLocalGadgets();
  }

  Future<void> _deleteLocalGadget(int index) async {
    final box = await Hive.openBox<Gadget>('gadgets');
    final key = box.keyAt(index);
    await box.delete(key);
    await _loadLocalGadgets();
  }

  void _addLocalGadget(Gadget gadget) async {
    final box = await Hive.openBox<Gadget>('gadgets');
    await box.add(gadget);
    await _loadLocalGadgets();
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showGadgetDetailDialog(BuildContext context, Gadget gadget) {
    final filteredEntries = gadget.data.entries
        .where((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(gadget.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gadget.imagePath != null && gadget.imagePath!.isNotEmpty && File(gadget.imagePath!).existsSync())
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(gadget.imagePath!),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              if (filteredEntries.isEmpty)
                const Text("Tidak ada data detail yang tersedia."),
              ...filteredEntries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${entry.key} : ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(entry.value?.toString() ?? "-"),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Tutup'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple;
    final allGadgets = [
      ...remoteGadgets,
      ...localGadgets.where((local) => !remoteGadgets.any((api) => api.id == local.id))
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Daftar Gadget", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GadgetFormPage(
                onSubmit: (gadget) {
                  _addLocalGadget(gadget);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Tambah", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: allGadgets.isEmpty
          ? const Center(child: Text('Belum ada data gadget.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: allGadgets.length,
              itemBuilder: (context, index) {
                final gadget = allGadgets[index];
                final data = gadget.data;
                final String? imagePath = gadget.imagePath;
                final bool hasImage = imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();

                String subtitleText = data['price']?.toString().trim().isNotEmpty == true
                    ? data['price'].toString()
                    : data.entries.firstWhere(
                        (e) => e.key != 'price' && e.value.toString().trim().isNotEmpty,
                        orElse: () => const MapEntry('info', '-'),
                      ).value.toString();

                final bool isLocal = localGadgets.any((local) => local.id == gadget.id);
                final int localIndex = isLocal ? localGadgets.indexWhere((local) => local.id == gadget.id) : -1;

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(imagePath!),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 32),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: primaryColor.withAlpha((0.12 * 255).round()),
                            child: const Icon(Icons.devices, color: Colors.deepPurple),
                          ),
                    title: Text(gadget.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subtitleText, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => _showGadgetDetailDialog(context, gadget),
                    trailing: isLocal
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final edited = await Navigator.push<Gadget>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GadgetFormPage(
                                        gadget: gadget,
                                        onSubmit: (editedGadget) {
                                          Navigator.pop(context, editedGadget);
                                        },
                                      ),
                                    ),
                                  );
                                  if (edited != null) {
                                    await _editLocalGadget(localIndex, edited);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Hapus',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Hapus Gadget'),
                                      content: const Text('Yakin ingin menghapus gadget ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _deleteLocalGadget(localIndex);
                                  }
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
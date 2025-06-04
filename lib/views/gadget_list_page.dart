import 'package:flutter/material.dart';
import '../models/gadget.dart';
import '../core/db/gadget_database.dart';
import '../presenters/gadget_list_presenter.dart';
import '../views/gadget_form_page.dart';
import '../views/gadget_list_view.dart';
import '../auth/login_page.dart'; // Tambahkan import untuk LoginPage

class GadgetListPage extends StatefulWidget {
  const GadgetListPage({super.key});

  @override
  State<GadgetListPage> createState() => _GadgetListPageState();
}

class _GadgetListPageState extends State<GadgetListPage> implements GadgetListView {
  late GadgetListPresenter presenter;
  List<Gadget> gadgets = [];
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  @override
  void initState() {
    super.initState();
    presenter = GadgetListPresenter(this, GadgetDatabase());

    // Cek data Hive, kalau kosong sync dari API
    GadgetDatabase().getAllGadgets().then((data) {
      if (data.isEmpty) {
        presenter.syncFromApi();
      } else {
        presenter.loadGadgets();
      }
    });
  }

  @override
  void showGadgets(List<Gadget> gadgets) {
    setState(() {
      this.gadgets = gadgets;
      isLoading = false;
      errorMessage = null;
      successMessage = null;
    });
  }

  @override
  void showLoading() {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      isLoading = false;
      errorMessage = message;
    });
  }

  @override
  void showSuccess(String message) {
    setState(() {
      isLoading = false;
      successMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addGadget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GadgetFormPage(
          onSubmit: (gadget) {
            presenter.addGadget(gadget);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _editGadget(Gadget gadget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GadgetFormPage(
          gadget: gadget,
          onSubmit: (g) {
            presenter.updateGadget(g);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false, // Hapus semua rute sebelumnya
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Gadget"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              presenter.syncFromApi();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGadget,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text("Error: $errorMessage"))
              : ListView.builder(
                  itemCount: gadgets.length,
                  itemBuilder: (context, index) {
                    final gadget = gadgets[index];
                    final data = gadget.data;

                    String? subtitleText;
                    if (data['price'] != null && data['price'].toString().isNotEmpty) {
                      subtitleText = data['price'].toString();
                    } else {
                      final alt = data.entries.firstWhere(
                        (e) => e.key != 'price' && e.value != null && e.value.toString().isNotEmpty,
                        orElse: () => const MapEntry('', null),
                      );
                      subtitleText = (alt.value != null) ? alt.value.toString() : '-';
                    }

                    return ListTile(
                      title: Text(gadget.name),
                      subtitle: Text(subtitleText ?? '-'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editGadget(gadget),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => presenter.deleteGadget(gadget.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

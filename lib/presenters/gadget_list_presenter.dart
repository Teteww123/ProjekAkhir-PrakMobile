import '../views/gadget_list_view.dart';
import '../core/db/gadget_database.dart';
import '../models/gadget.dart';
import '../core/api/api_service.dart'; // Tambahkan import ini

class GadgetListPresenter {
  final GadgetListView view;
  final GadgetDatabase db;

  GadgetListPresenter(this.view, this.db);

  void loadGadgets() async {
    view.showLoading();
    try {
      final gadgets = await db.getAllGadgets();
      view.showGadgets(gadgets);
    } catch (e) {
      view.showError(e.toString());
    }
  }

  /// Fungsi baru: sinkronisasi dari API ke Hive
  Future<void> syncFromApi() async {
    view.showLoading();
    try {
      final apiGadgets = await ApiService().fetchGadgets();
      final box = await db.openBoxDirect();
      await box.clear();
      for (final gadget in apiGadgets) {
        await box.put(gadget.id, gadget);
      }
      loadGadgets();
      view.showSuccess('Berhasil sinkronisasi dari API');
    } catch (e) {
      view.showError('Gagal sinkronisasi dari API: $e');
    }
  }

  void addGadget(Gadget gadget) async {
    view.showLoading();
    try {
      await db.addGadget(gadget);
      loadGadgets();
      view.showSuccess('Gadget berhasil ditambahkan');
    } catch (e) {
      view.showError(e.toString());
    }
  }

  void updateGadget(Gadget gadget) async {
    view.showLoading();
    try {
      await db.updateGadget(gadget);
      loadGadgets();
      view.showSuccess('Gadget berhasil diubah');
    } catch (e) {
      view.showError(e.toString());
    }
  }

  void deleteGadget(String id) async {
    view.showLoading();
    try {
      await db.deleteGadget(id);
      loadGadgets();
      view.showSuccess('Gadget berhasil dihapus');
    } catch (e) {
      view.showError(e.toString());
    }
  }
}
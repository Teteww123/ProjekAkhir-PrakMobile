import 'package:hive/hive.dart';
import '../../models/gadget.dart';

class GadgetDatabase {
  static const String boxName = 'gadgets';

  Future<Box<Gadget>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Gadget>(boxName);
    }
    return await Hive.openBox<Gadget>(boxName);
  }

  // Tambahkan fungsi ini agar bisa diakses langsung dari presenter
  Future<Box<Gadget>> openBoxDirect() => _openBox();

  Future<List<Gadget>> getAllGadgets() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> addGadget(Gadget gadget) async {
    final box = await _openBox();
    await box.put(gadget.id, gadget);
  }

  Future<void> updateGadget(Gadget gadget) async {
    final box = await _openBox();
    await box.put(gadget.id, gadget);
  }

  Future<void> deleteGadget(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<Gadget?> getGadgetById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }
}
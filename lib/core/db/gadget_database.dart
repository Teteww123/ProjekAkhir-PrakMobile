import 'package:hive/hive.dart';
import '../../models/gadget.dart';

class GadgetDatabase {
  static const String boxName = 'gadgets';

  Future<Box<Gadget>> openBox() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GadgetAdapter());
    }
    return await Hive.openBox<Gadget>(boxName);
  }

  Future<void> insertGadget(Gadget gadget) async {
    final box = await openBox();
    await box.put(gadget.id, gadget);
  }

  Future<List<Gadget>> getAllGadgets() async {
    final box = await openBox();
    return box.values.toList();
  }

  Future<void> updateGadget(Gadget gadget) async {
    final box = await openBox();
    await box.put(gadget.id, gadget);
  }

  Future<void> deleteGadget(String id) async {
    final box = await openBox();
    await box.delete(id);
  }
}
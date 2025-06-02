import '../models/gadget.dart';

abstract class GadgetListView {
  void showGadgets(List<Gadget> gadgets);
  void showLoading();
  void showError(String message);
}
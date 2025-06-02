import '../views/gadget_list_view.dart';
import '../core/api/api_service.dart';

class GadgetListPresenter {
  final GadgetListView view;
  final ApiService apiService;

  GadgetListPresenter(this.view, this.apiService);

  void loadGadgets() async {
    view.showLoading();
    try {
      final gadgets = await apiService.fetchGadgets();
      view.showGadgets(gadgets);
    } catch (e) {
      view.showError(e.toString());
    }
  }
}
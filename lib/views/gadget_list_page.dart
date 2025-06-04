import 'package:flutter/material.dart';
import '../core/api/api_service.dart';
import '../models/gadget.dart';

class GadgetListPage extends StatefulWidget {
  const GadgetListPage({Key? key}) : super(key: key);

  @override
  State<GadgetListPage> createState() => _GadgetListPageState();
}

class _GadgetListPageState extends State<GadgetListPage> {
  late Future<List<Gadget>> _futureGadgets;

  @override
  void initState() {
    super.initState();
    _futureGadgets = ApiService().fetchGadgets();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Gadget>>(
      future: _futureGadgets,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No gadgets found."));
        } else {
          final gadgets = snapshot.data!;
          return ListView.builder(
            itemCount: gadgets.length,
            itemBuilder: (context, index) {
              final gadget = gadgets[index];
              return ListTile(
                title: Text(gadget.name ?? 'No Name'),
                subtitle: Text(gadget.id ?? 'No ID'),
              );
            },
          );
        }
      },
    );
  }
}
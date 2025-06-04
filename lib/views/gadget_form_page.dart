import 'package:flutter/material.dart';
import '../models/gadget.dart';

class GadgetFormPage extends StatefulWidget {
  final Gadget? gadget;
  final void Function(Gadget gadget) onSubmit;

  const GadgetFormPage({super.key, this.gadget, required this.onSubmit});

  @override
  State<GadgetFormPage> createState() => _GadgetFormPageState();
}

class _GadgetFormPageState extends State<GadgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gadget?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final gadget = Gadget(
        id: widget.gadget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        data: {},
      );
      widget.onSubmit(gadget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gadget == null ? "Tambah Gadget" : "Edit Gadget")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Gadget'),
                validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.gadget == null ? "Tambah" : "Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}